defmodule IonosphereVisualizer.MapController do
  use IonosphereVisualizer.Web, :controller

  alias IonosphereVisualizer.Map
  alias IonosphereVisualizer.Repo
  alias IonosphereVisualizer.Measurement
  alias IonosphereVisualizer.MapGenerator

  plug :scrub_params, "map" when action in [:create, :update]

  def index(conn, _params) do
    #maps = Repo.all(Map)
    render(conn, "index.html")#, maps: maps)
  end

  def create(conn, %{"map" => map_params}) do
    #TODO rewrite
    {:ok, date} = Ecto.DateTime.cast(%{year: 2015, month: 12, day: 21, hour: 23, min: 30})
    samples = (Repo.all from m in Measurement,
      where: m.measured_at == ^date and m.parameter_type == "foF2",
      preload: [:station])
    |> Enum.map(fn(measurement) ->
      {longitude, latitude} = measurement.station.location.coordinates
      %{value: measurement.value,
        location: %{latitude: latitude, longitude: longitude}}
    end)

    values = MapGenerator.generate(samples, {-80, 80}, {-179, 179}, 3)

    classes = (for value <- values, do: value.value)
    |> classify(7)

    conn
    |> put_status(:created)
    |> render("map.json", %{map: values, classes: classes})
    ############################################################################

    #changeset = Map.changeset(%Map{}, map_params)

    #case Repo.insert(changeset) do
    #  {:ok, _map} ->
    #    conn
    #    |> put_flash(:info, "Map created successfully.")
    #    |> redirect(to: map_path(conn, :index))
    #  {:error, changeset} ->
    #    render(conn, "new.html", changeset: changeset)
    #end
  end

  #TODO change name and/or module
  def classify(values, class_count) do
    {min, max} = {Enum.min(values), Enum.max(values)}
    interval = (max - min) / class_count
    1..class_count
    |> Enum.map_reduce(min, fn(x, acc) ->
      if x == class_count do
        {%{from: acc, to: max, class_num: x}, acc}
      else
        {%{from: acc, to: acc + interval, class_num: x}, acc + interval}
      end
    end)
    |> elem(0)
  end
end
