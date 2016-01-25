defmodule MUF do
  use HTTPoison.Base

  import SweetXml

  @spidr_wsdl_url "http://spidr.ngdc.noaa.gov/spidr/services/SpidrService?wsdl"
  @type_name "MUF3000"

  def get_data(parameters, start_date, stop_date) when is_list(parameters) do
    stations = for param <- parameters, param.parameter_type == @type_name,
      do: param.station
    data = stations
    |> Enum.map(fn(station) ->
      data = get_data(station, start_date, stop_date)
      %{data: data, parameter_type: @type_name, station: station}
    end)
  end

  def get_data(station, start_date, stop_date) do
    request_body = ~s(
      <x:Envelope xmlns:x="http://schemas.xmlsoap.org/soap/envelope/"
        xmlns:apachesoap="http://xml.apache.org/xml-soap"
        xmlns:impl="http://spidr.ngdc.noaa.gov/spidr/services/SpidrService"
        xmlns:intf="http://spidr.ngdc.noaa.gov/spidr/services/SpidrService"
        xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/"
        xmlns:tns1="urn:DataService" xmlns:wsdl="http://schemas.xmlsoap.org/wsdl/"
        xmlns:wsdlsoap="http://schemas.xmlsoap.org/wsdl/soap/"
        xmlns:xsd="http://www.w3.org/2001/XMLSchema"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
        <x:Body>
            <mns:getDataStream xmlns:mns="http://export.spidr" x:encodingstyle="http://schemas.xmlsoap.org/soap/encoding/">
                <spidrTable xsi:type="xsd:string">Iono</spidrTable>
                <element xsi:type="xsd:string">MUF3000F2</element>
    ) <>
                "<station xsi:type=\"xsd:string\">#{station}</station>
                <startDayAndTime xsi:type=\"xsd:string\">#{start_date}</startDayAndTime>
                <stopDayAndTime xsi:type=\"xsd:string\">#{stop_date}</stopDayAndTime>"
                <> ~s(
                <format xsi:type="xsd:string">ASCII</format>
                <samplingRate xsi:type="xsd:string">15</samplingRate>
                </mns:getDataStream>
        </x:Body>
      </x:Envelope>
    )
    post!(@spidr_wsdl_url, request_body, [{"Accept", "text/xml"},
        {"Content-type", "text/xml"}, {"SOAPAction", ""}])
    |> process_response
  end

  defp process_response(%{ body: body, status_code: 200 }) do
    %{csv: csv} = body
    #|> String.replace("&quot;", "")
    |> xpath(~x"//soapenv:Body", csv: ~x"//getDataStreamReturn/text()"l)
    csv
    #|> Stream.map()
    |> Enum.join
    # TODO consider using sampling rate
    |> String.replace(~r/\s9999.00/, ",9999.00")
    |> String.replace(~r/\s\s[\s]*/, ",")
  end
end
