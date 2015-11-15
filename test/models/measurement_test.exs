defmodule IonosphereVisualizer.MeasurementTest do
  use IonosphereVisualizer.ModelCase

  import ValidField

  alias IonosphereVisualizer.Measurement

  test "measurement changeset measured_at validations" do
    with_changeset(%Measurement{})
    |> assert_valid_field(:measured_at, ["1958-01-01 00:00:00"])
    |> assert_invalid_field(:measured_at, [nil, "1958", ""])
  end

  test "measurement changeset parameter_type validations" do
    with_changeset(%Measurement{})
    |> assert_valid_field(:parameter_type, ["foF2"])
    |> assert_invalid_field(:parameter_type, [nil, "1958", "type", ""])
  end

  test "measurement changeset value validations" do
    with_changeset(%Measurement{})
    |> assert_valid_field(:value, [3.45])
    |> assert_invalid_field(:value, [nil, "string", ""])
  end
end
