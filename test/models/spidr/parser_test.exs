defmodule IonosphereVisualizer.SPIDR.ParserTest do
  use ExUnit.Case, async: true

  import List, only: [last: 1]

  alias IonosphereVisualizer.SPIDR.Parser

  test "Parser.parse_data parses valid SPIDR csv data" do
    test_data = File.read!("./test/models/spidr/data/foF2.BC840_20071225_20080101.csv")
    expected_result = [%{time: "2008-01-01 23:45", value: 3.75, qualifier: "", description: ""}, %{time: "2007-12-25 00:00", value: 3.8, qualifier: "", description: ""}]
    parsed_data = test_data
    |> Parser.parse_data(:measurements)
    |> Enum.to_list
    |> hd
    result = [hd(parsed_data), last(parsed_data)]
    assert result == expected_result
  end

  test "Parser.parse_data parses valid SPIDR csv data with multiple params/stations" do
    test_data = File.read!("./test/models/spidr/data/foF2.BC840_foF2.WP937_20071225_20080101.csv")
    expected_result = [%{time: "2008-01-01 23:45", value: 3.75, qualifier: "", description: ""}, %{time: "2007-12-25 00:00", value: 3.8, qualifier: "", description: ""},
      %{time: "2008-01-01 23:45", value: 2.7, qualifier: "", description: ""}, %{time: "2007-12-25 00:00", value: 3.1, qualifier: "", description: ""}]
    [head | tail] = test_data
    |> Parser.parse_data(:measurements)
    |> Enum.to_list
    tail  = hd(tail)
    result = [hd(head), last(head), hd(tail), last(tail)]
    assert result == expected_result
  end

  test "Parser.parse_data parses valid SPIDR xml metadata" do
    test_data = File.read!("./test/models/spidr/data/iono.BC840_metadata.xml")
    expected_result = %{ code: "BC840", name: "Boulder", date_from: "1958-12-31", date_to: nil,
      location: %Geo.Point{ coordinates: { -105.2697, 39.9918 }, srid: nil } }
    result = test_data
    |> Parser.parse_data(:metadata)
    assert result == expected_result
  end

  test "Parser.parse_data parses station list defined in html" do
    test_data = File.read!("./test/models/spidr/data/iono_foF2.htm")
    expected_result = ["09429", "AA343", "AD651", "AFJ49", "AH223"]
    result = test_data
    |> Parser.parse_data(:station_list)
    |> Enum.take(5)
    assert result == expected_result
  end
end
