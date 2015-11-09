defmodule IonosphereVisualizer.SPIDR.Parser do
  import SweetXml

  @_DATA_HEADERS_ [:time, :value, :qualifier, :description]

  def parse_data(raw_data, :measurements) do
    raw_data
    |> StringIO.open
    |> elem(1)
    |> IO.stream(:line)
    |> Stream.reject(&(String.first(&1) == "#" || &1 == "\n"))
    |> Enum.to_list
    |> Stream.map(&(String.replace(&1, "/", "")))
    |> CSV.decode(headers: @_DATA_HEADERS_, num_pipes: 1)
    |> Enum.map(&(Map.update!(&1, :value, fn(value) -> String.to_float(value) end)))
    #consider Stream
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
    |> Map.update!(:location, &(%Geo.Point{ coordinates: { String.to_float(&1.longitude),
      String.to_float(&1.latitude) }, srid: nil }))
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
    #consider Stream
  end
end
