defmodule IonosphereVisualizer.StationTest do
  use IonosphereVisualizer.ModelCase

  import ValidField

  alias IonosphereVisualizer.Station

  test "station changeset date_from validations" do
    with_changeset(%Station{})
    |> assert_valid_field(:date_from, ["1958-01-01"])
    |> assert_invalid_field(:date_from, [nil, "1958"])
  end

  test "station changeset date_to validations" do
    with_changeset(%Station{})
    |> assert_valid_field(:date_to, ["2015-08-11", nil])
    |> assert_invalid_field(:date_to, ["2015"])
  end

  test "station changeset location validations" do
    with_changeset(%Station{})
    |> assert_valid_field(:location, [%Geo.Point{ coordinates: { -105.2697, 39.9918 }, srid: nil }])
    |> assert_invalid_field(:location, [nil])
  end

  test "station changeset code validations" do
    with_changeset(%Station{})
    |> assert_valid_field(:code, ["BC840"])
    |> assert_invalid_field(:code, [nil])
  end

  test "station changeset name validations" do
    with_changeset(%Station{})
    |> assert_valid_field(:name, ["Boulder"])
    |> assert_invalid_field(:name, [nil])
  end
end
