defmodule IonosphereVisualizer.ChartControllerTest do
  use IonosphereVisualizer.ConnCase

  alias IonosphereVisualizer.Chart
  @valid_attrs %{}
  @invalid_attrs %{}

  setup do
    conn = conn()
    {:ok, conn: conn}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, chart_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing charts"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, chart_path(conn, :new)
    assert html_response(conn, 200) =~ "New chart"
  end

  test "creates resource when data is valid", %{conn: conn} do
    conn = post conn, chart_path(conn, :create), chart: @valid_attrs
    assert redirected_to(conn) == chart_path(conn, :index)
    assert Repo.get_by(Chart, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, chart_path(conn, :create), chart: @invalid_attrs
    assert html_response(conn, 200) =~ "New chart"
  end
end
