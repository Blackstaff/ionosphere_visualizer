defmodule IonosphereVisualizer.SPIDR.Client do
  use HTTPoison.Base

  alias IonosphereVisualizer.SPIDR.Parser

  @_SPIDR "http://spidr.ngdc.noaa.gov"
  @_SPIDR_DATA_PREFIX "/spidr/servlet/GetData?format=csv"
  @_SPIDR_METADATA_PREFIX "/spidr/servlet/GetMetadata?"
  @_SPIDR_STATION_LIST_PREFIX "/spidr/servlet/GetData?describe"

  def get_data(param, date_from, date_to) do
    get!("#{@_SPIDR_DATA_PREFIX}&param=#{param}&dateFrom=#{date_from}&dateTo=#{date_to}")
    |> process_response(:measurements)
  end

  def get_metadata(param) do
    get!(@_SPIDR_METADATA_PREFIX <> "param=#{param}")
    |> process_response(:metadata)
  end

  def get_station_list(param) do
    get!(@_SPIDR_STATION_LIST_PREFIX <> "param=#{param}")
    |> process_response(:station_list)
  end

  defp process_url(url) do
    @_SPIDR <> url
  end

  defp process_response(%{ body: body, status_code: 200 }, format) do
    body |> Parser.parse_data(format)
  end
end
