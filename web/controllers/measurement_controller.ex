defmodule IonosphereVisualizer.MeasurementController do
  use IonosphereVisualizer.Web, :controller

  alias IonosphereVisualizer.Measurement

  plug :scrub_params, "measurement" when action in [:create, :update]

  def index(conn, _params) do
    measurements = Repo.all(Measurement)
    render(conn, "index.json", measurements: measurements)
  end

  def create(conn, %{"measurement" => measurement_params}) do
    changeset = Measurement.changeset(%Measurement{}, measurement_params)

    case Repo.insert(changeset) do
      {:ok, measurement} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", measurement_path(conn, :show, measurement))
        |> render("show.json", measurement: measurement)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(IonosphereVisualizer.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    measurement = Repo.get!(Measurement, id)
    render(conn, "show.json", measurement: measurement)
  end

  def update(conn, %{"id" => id, "measurement" => measurement_params}) do
    measurement = Repo.get!(Measurement, id)
    changeset = Measurement.changeset(measurement, measurement_params)

    case Repo.update(changeset) do
      {:ok, measurement} ->
        render(conn, "show.json", measurement: measurement)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(IonosphereVisualizer.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    measurement = Repo.get!(Measurement, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(measurement)

    send_resp(conn, :no_content, "")
  end
end
