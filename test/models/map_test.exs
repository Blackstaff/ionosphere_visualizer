defmodule IonosphereVisualizer.MapTest do
  use IonosphereVisualizer.ModelCase

  alias IonosphereVisualizer.Map

  @valid_attrs %{data: %{}, datetime: "2010-04-17 14:00:00", parameter_type: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Map.changeset(%Map{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Map.changeset(%Map{}, @invalid_attrs)
    refute changeset.valid?
  end
end
