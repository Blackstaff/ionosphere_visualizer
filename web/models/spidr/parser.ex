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
      full_name: ~x"//title/text()"s,
      begin_date: ~x"//begdate/text()"s, end_date: ~x"//enddate/text()"s,
      progress: ~x"//progress/text()"s, coordinates: [
        ~x"//bounding",
        longitude: ~x"./westbc/text()"s,
        latitude: ~x"./northbc/text()"s ])
    |> Map.update!(:coordinates, &(%{longitude: String.to_float(&1.longitude),
      latitude: String.to_float(&1.latitude)}))
  end

  def parse_data(raw_data, :station_list) do
    raw_data
    |> Floki.find("table a")
    |> Stream.map(&Floki.FlatText.get/1)
    |> Enum.take_every(2)
    #consider Stream
  end
end
