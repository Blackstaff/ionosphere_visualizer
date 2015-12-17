defmodule IonosphereVisualizer.SPIDR.Parser do
  alias Ecto.DateTime

  import SweetXml

  @data_headers [:measured_at, :value, :qualifier, :description]

  def parse_data(raw_data, :measurements) do
    raw_data
    |> StringIO.open
    |> elem(1)
    |> IO.stream(:line)
    |> Stream.reject(&(&1 == "\n"))
    |> Enum.to_list
    |> split_csv_data
    |> Stream.map(fn(csv) -> parse_single_csv(csv) end)
  end

  def parse_data(raw_data, :metadata) do
    raw_data
    |> xpath(~x"//metadata",
      code: ~x"//title/text()"s, name: ~x"//title/text()"s,
      date_from: ~x"//begdate/text()"s, date_to: ~x"//enddate/text()"s,
      location: [
        ~x"//bounding",
        longitude: ~x"./westbc/text()"s,
        latitude: ~x"./northbc/text()"s ])
    #TODO move to Station model
    |> Map.update!(:location, &(%Geo.Point{ coordinates: { String.to_float(&1.latitude),
      String.to_float(&1.longitude) }, srid: nil }))
    ###############################################3
    |> Map.update!(:date_from, &(&1 <> "-12-31"))
    |> Map.update!(:date_to, &(case &1 do
        "Present" -> nil
        _ -> &1 <> "-01-01"
      end))
    |> Map.update!(:code, &(Regex.run(~r/\((.*?)\)/, &1) |> List.last))
    |> Map.update!(:name, &(Regex.replace(~r/\s*\((.*?)\)/, &1, "")))
  end

  def parse_data(raw_data, :station_list) do
    raw_data
    |> Floki.find("table a")
    |> Stream.map(&Floki.FlatText.get/1)
    |> Enum.take_every(2)
    #OPTIMIZE consider Stream
  end

  defp split_csv_data(csv_data) do
    {tl, hd, _} = csv_data
    |> List.foldl({[], [], ""}, fn(line, {acc, tmp, prev_line}) ->
      case {String.first(line), line, prev_line} do
        {_, "#>\n", "#yyyy-MM-dd HH:mm,value,qualifier,description\n"} ->
          {[[] | acc], [], line}
        {"#", _, _} when length(tmp) == 0 ->
          {acc, tmp, line}
        {"#", _, _} when length(tmp) > 0 ->
          {[tmp | acc], [], line}
        {_, _, _} ->
          {acc, [line | tmp], line}
      end
    end)

    [hd | tl]
    |> Enum.reverse
  end

  defp parse_single_csv(csv) do
    csv
    |> Stream.map(&(String.replace(&1, "/", "")))
    |> CSV.decode(headers: @data_headers, num_pipes: 1)
    |> Stream.map(&(Map.update!(&1, :value, fn(value) -> String.to_float(value) end)))
    |> Enum.map(&(Map.update!(&1, :measured_at, fn(mt) -> cast_to_ecto_datetime(mt) end)))
    #OPTIMIZE consider Stream
  end

  defp cast_to_ecto_datetime(datetime) do
    {:ok, dt} = DateTime.cast(datetime <> ":00")
    dt
  end
end
