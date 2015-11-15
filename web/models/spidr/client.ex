defmodule IonosphereVisualizer.SPIDR.Client do
  use HTTPoison.Base

  alias IonosphereVisualizer.SPIDR.Parser

  @spidr "http://spidr.ngdc.noaa.gov"
  @spidr_data_prefix "/spidr/servlet/GetData?format=csv"
  @spidr_metadata_prefix "/spidr/servlet/GetMetadata?"
  @spidr_station_list_prefix "/spidr/servlet/GetMetadata?describe&"

  def get_data(param, date_from, date_to) do
    get!("#{@spidr_data_prefix}&param=#{param}&dateFrom=#{date_from}&dateTo=#{date_to}")
    |> process_response(:measurements)
  end

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
