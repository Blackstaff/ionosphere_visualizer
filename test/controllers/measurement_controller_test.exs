defmodule IonosphereVisualizer.MeasurementControllerTest do
  use IonosphereVisualizer.ConnCase

  alias IonosphereVisualizer.Measurement
  @valid_attrs %{last_accessed: "2010-04-17 14:00:00", measured_at: "2010-04-17 14:00:00", parameter_type: "some content", value: "120.5"}
  @invalid_attrs %{}

  setup do
    conn = conn() |> put_req_header("accept", "application/json")
    {:ok, conn: conn}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, measurement_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "shows chosen resource", %{conn: conn} do
    measurement = Repo.insert! %Measurement{}
    conn = get conn, measurement_path(conn, :show, measurement)
    assert json_response(conn, 200)["data"] == %{"id" => measurement.id,
      "value" => measurement.value,
      "measured_at" => measurement.measured_at,
      "parameter_type" => measurement.parameter_type,
      "last_accessed" => measurement.last_accessed,
      "station_id" => measurement.station_id}
  end

  test "does not show resource and instead throw error when id is nonexistent", %{conn: conn} do
    assert_raise Ecto.NoResultsError, fn ->
      get conn, measurement_path(conn, :show, -1)
    end
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    conn = post conn, measurement_path(conn, :create), measurement: @valid_attrs
    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(Measurement, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, measurement_path(conn, :create), measurement: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn} do
    measurement = Repo.insert! %Measurement{}
    conn = put conn, measurement_path(conn, :update, measurement), measurement: @valid_attrs
    assert json_response(conn, 200)["data"]["id"]
    assert Repo.get_by(Measurement, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    measurement = Repo.insert! %Measurement{}
    conn = put conn, measurement_path(conn, :update, measurement), measurement: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen resource", %{conn: conn} do
    measurement = Repo.insert! %Measurement{}
    conn = delete conn, measurement_path(conn, :delete, measurement)
    assert response(conn, 204)
    refute Repo.get(Measurement, measurement.id)
  end
end
