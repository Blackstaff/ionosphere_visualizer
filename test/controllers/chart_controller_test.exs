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

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, chart_path(conn, :create), chart: @valid_attrs
    assert redirected_to(conn) == chart_path(conn, :index)
    assert Repo.get_by(Chart, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, chart_path(conn, :create), chart: @invalid_attrs
    assert html_response(conn, 200) =~ "New chart"
  end

  test "shows chosen resource", %{conn: conn} do
    chart = Repo.insert! %Chart{}
    conn = get conn, chart_path(conn, :show, chart)
    assert html_response(conn, 200) =~ "Show chart"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_raise Ecto.NoResultsError, fn ->
      get conn, chart_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    chart = Repo.insert! %Chart{}
    conn = get conn, chart_path(conn, :edit, chart)
    assert html_response(conn, 200) =~ "Edit chart"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    chart = Repo.insert! %Chart{}
    conn = put conn, chart_path(conn, :update, chart), chart: @valid_attrs
    assert redirected_to(conn) == chart_path(conn, :show, chart)
    assert Repo.get_by(Chart, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    chart = Repo.insert! %Chart{}
    conn = put conn, chart_path(conn, :update, chart), chart: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit chart"
  end

  test "deletes chosen resource", %{conn: conn} do
    chart = Repo.insert! %Chart{}
    conn = delete conn, chart_path(conn, :delete, chart)
    assert redirected_to(conn) == chart_path(conn, :index)
    refute Repo.get(Chart, chart.id)
  end
end
