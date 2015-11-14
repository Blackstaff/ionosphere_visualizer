defmodule IonosphereVisualizer.MeasurementTest do
  use IonosphereVisualizer.ModelCase

  alias IonosphereVisualizer.Measurement

  @valid_attrs %{last_accessed: "2010-04-17 14:00:00", measured_at: "2010-04-17 14:00:00", parameter_type: "some content", value: "120.5"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Measurement.changeset(%Measurement{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Measurement.changeset(%Measurement{}, @invalid_attrs)
    refute changeset.valid?
  end
end
