defmodule IonosphereVisualizer.MapController do
  use IonosphereVisualizer.Web, :controller

  import Map, only: [update: 4]

  alias IonosphereVisualizer.Map
  alias IonosphereVisualizer.Station
  alias IonosphereVisualizer.Repo
  alias IonosphereVisualizer.Measurement
  alias IonosphereVisualizer.MapGenerator
  alias IonosphereVisualizer.ParameterType
  alias IonosphereVisualizer.SPIDR.Client
  alias Ecto.Model

  plug :scrub_params, "map" when action in [:create, :update]

  def index(conn, _params) do
    changeset = Map.changeset(%Map{})
    types = ParameterType.get_types
    render(conn, "index.html", changeset: changeset, types: types)
  end

  def create(conn, %{"map" => map_params}) do
    #changeset = Map.changeset(%Map{}, map_params)
    #map = changeset.changes
    #TODO rewrite
    {:ok, datetime} = map_params["datetime"] |> parse_datetime
    {:ok, time_from} = Ecto.DateTime.cast(%{datetime | hour: 0, min: 0})
    {:ok, time_to} = Ecto.DateTime.cast(%{time_from | hour: 23, min: 30})
    date = Ecto.DateTime.to_date(datetime)

    samples = (Repo.all from m in Measurement,
      join: s in assoc(m, :station),
      where:  is_nil(s.date_to) and m.measured_at >= ^time_from
        and m.measured_at <= ^time_to
        and m.parameter_type == ^map_params["parameter_type"],
      preload: [station: s])

    missing_stations = (Repo.all from s in Station,
      where: is_nil(s.date_to))
    |> Enum.filter(fn(station) ->
      #OPTIMIZE worst case ~ n^2 :-(
      samples
      |> Enum.find(&(&1.station.code == station.code))
      |> is_nil
    end)

    missing_measurements = missing_stations
    |> Enum.map(fn(station) ->
      %{station: station.code, parameter_type: map_params["parameter_type"]}
    end)
    |> Client.get_data(date, date)
    |> Enum.filter_map(&(!Enum.empty?(&1.measurements)), fn(measurements) ->
      station = missing_stations
      |> Enum.find(&(&1.code == measurements.station))
      %{measurements | station: station}
    end)
    |> persist_measurements
    |> Stream.flat_map(fn(elem) ->
      elem.measurements
    end)
    |> Enum.filter(&(&1.measured_at == datetime))
    |> Repo.preload(:station)

    values = (for sample <- samples, sample.measured_at == datetime, do: sample)
      ++ missing_measurements
    |> Enum.map(fn(measurement) ->
      {longitude, latitude} = measurement.station.location.coordinates
      %{value: measurement.value,
        location: %{latitude: latitude, longitude: longitude}}
    end)
    |> MapGenerator.generate({-80, 80}, {-179, 179}, 3)

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

  defp parse_datetime(date_string) do
    #TODO Consider using ISOString
    captures = ~r/^(?<day>\d{2})\/(?<month>\d{2})\/(?<year>\d{4})\s(?<hour>\d{2}):(?<min>\d{2})/mx
    |> Regex.named_captures(date_string)
    %{day: captures["day"], month: captures["month"],
        year: captures["year"],
        hour: captures["hour"], min: captures["min"]} |> Ecto.DateTime.cast
  end

  #Copied from ChartController
  defp persist_measurements(data) do
    #TODO check for duplicates
    data
    |> Enum.map(fn(elem = %{station: station, measurements: measurements,
      parameter_type: parameter_type}) ->
      {:ok, measurements} = Repo.transaction(fn ->
        measurements
        |> Enum.map(fn(measurement) ->
          measurement = Model.build(station, :measurements,
            Dict.put_new(measurement, :parameter_type, parameter_type))
          Repo.insert!(measurement)
        end)
      end)
      %{elem | measurements: measurements}
    end)
  end
end
