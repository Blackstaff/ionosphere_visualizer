defmodule IonosphereVisualizer.SPIDR.ParserTest do
  use ExUnit.Case, async: true

  alias IonosphereVisualizer.SPIDR.Parser

  test "Parser.parse_data parses valid SPIDR csv data" do
    test_data = File.read!("./test/models/spidr/data/foF2.BC840_20071225_20080101.csv")
    expected_result = [%{time: "2007-12-25 00:00", value: 3.8, qualifier: "", description: ""}, %{time: "2007-12-25 00:15", value: 3.45, qualifier: "", description: ""}]
    result = test_data
    |> Parser.parse_data(:measurements)
    |> Enum.take(2)
    assert result == expected_result
  end

  test "Parser.parse_data parses valid SPIDR xml metadata" do
    test_data = File.read!("./test/models/spidr/data/iono.BC840_metadata.xml")
    expected_result = %{ full_name: "Boulder (BC840)", begin_date: "1958", end_date: "Present",
      coordinates: %{ longitude: -105.2697, latitude: 39.9918 }, progress: "In work" }
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
