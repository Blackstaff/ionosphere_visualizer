defmodule IonosphereVisualizer.SPIDR.Client do
  use HTTPoison.Base
  use Pipe

  alias IonosphereVisualizer.SPIDR.Parser
  alias Ecto.DateTime.Utils, as: Utils

  @spidr "http://spidr.ngdc.noaa.gov"
  @spidr_data_prefix "/spidr/servlet/GetData?format=csv"
  @spidr_metadata_prefix "/spidr/servlet/GetMetadata?"
  @spidr_station_list_prefix "/spidr/servlet/GetMetadata?describe&"

  def get_data(params, date), do: get_data(params, date, date)

  def get_data(params, date_from, date_to) do
    params = format_params(params)
    param_string = to_param_string(params)
    date_from = convert_date(date_from)
    date_to = convert_date(date_to)
    additional_data = MUF.get_data(params, date_from, date_to)
    |> process_additional_data(:measurements, :muf)
    data = case param_string do
      [] -> []
      param_string ->
        get!("#{@spidr_data_prefix}&param=#{param_string}&dateFrom=#{date_from}&dateTo=#{date_to}", [], [{:recv_timeout, 30000}])
        |> process_response(:measurements)
        |> Stream.zip(params)
        |> Enum.map(fn({data, %{parameter_type: pt, station: s}}) ->
          %{parameter_type: pt, station: s, measurements: data}
        end)
    end
    data ++ additional_data
  end

  defp format_params({param_types, stations}) do
    stations
    |> Enum.flat_map(fn(station) ->
      for type <- param_types, do: %{parameter_type: type, station: station}
    end)
  end
  defp format_params(params), do: params

  defp to_param_string(params) do
    pipe_while fn
      [] -> false
      _ -> true
    end,
    (for param <- params, param.parameter_type != "MUF3000F2",
      do: "#{param.parameter_type}.#{param.station}")
    |> Enum.reduce(fn(param, acc) -> acc <> ";#{param}" end)
  end

  defp convert_date(%{year: year, month: month, day: day}),
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

  defp process_response(%{body: body, status_code: 200}, format) do
    body
    |> Parser.parse_data(format)
  end

  defp process_additional_data([], _, :muf), do: []
  defp process_additional_data(additional_data, format, :muf) do
    additional_data
    |> Enum.map(fn(elem) ->
      %{station: s, parameter_type: parameter_type, data: data} = elem
      measurements = data
      |> Parser.parse_data(format)
      |> Enum.flat_map(&(&1))
      %{parameter_type: parameter_type, station: s, measurements: measurements}
    end)
  end
end
