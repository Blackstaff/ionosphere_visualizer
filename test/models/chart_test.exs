defmodule IonosphereVisualizer.ChartTest do
  use IonosphereVisualizer.ModelCase

  alias IonosphereVisualizer.Chart

  @valid_attrs %{parameter_type: "some content", stations: ["some content"], date_from: "2010-04-17", date_to: "2010-04-17"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Chart.changeset(%Chart{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Chart.changeset(%Chart{}, @invalid_attrs)
    refute changeset.valid?
  end
end
