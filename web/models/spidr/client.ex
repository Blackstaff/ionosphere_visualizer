defmodule IonosphereVisualizer.SPIDR.Client do
  use HTTPoison.Base

  alias IonosphereVisualizer.SPIDR.Parser
  alias Ecto.DateTime.Utils, as: Utils

  @spidr "http://spidr.ngdc.noaa.gov"
  @spidr_data_prefix "/spidr/servlet/GetData?format=csv"
  @spidr_metadata_prefix "/spidr/servlet/GetMetadata?"
  @spidr_station_list_prefix "/spidr/servlet/GetMetadata?describe&"

  def get_data(params, date_from, date_to) do
    param_string = to_param_string(params)
    date_from = convert_date(date_from)
    date_to = convert_date(date_to)
    get!("#{@spidr_data_prefix}&param=#{param_string}&dateFrom=#{date_from}&dateTo=#{date_to}")
    |> process_response(:measurements)
    |> Stream.zip(params)
    |> Enum.map(fn({data, %{param_type: pt, station: s}}) ->
      %{param_type: pt, station: s, measurements: data}
    end)
  end

  defp to_param_string(params) do
    (for param <- params, do: "#{param.param_type}.#{param.station}")
    |> Enum.reduce(fn(param, acc) -> acc <> ";#{param}" end)
  end

  defp convert_date(%Ecto.Date{year: year, month: month, day: day}),
    do: Utils.zero_pad(year, 4) <> Utils.zero_pad(month, 2)
      <> Utils.zero_pad(day, 2)
  defp convert_date(date), do: date

  def get_metadata(param) do
    get!(@spidr_metadata_prefix <> "param=#{param}")
    |> process_response(:metadata)
  end

  def get_station_list(param) do
    get!(@spidr_station_list_prefix <> "param=#{param}")
    |> process_response(:station_list)
  end

  defp process_url(url) do
    @spidr <> url
  end

  defp process_response(%{ body: body, status_code: 200 }, format) do
    body |> Parser.parse_data(format)
  end
end
