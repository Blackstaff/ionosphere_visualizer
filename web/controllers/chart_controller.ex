defmodule IonosphereVisualizer.ChartController do
  use IonosphereVisualizer.Web, :controller
  use Timex
  use Pipe

  alias IonosphereVisualizer.Chart
  alias IonosphereVisualizer.Station
  alias IonosphereVisualizer.Measurement
  alias IonosphereVisualizer.ParameterType
  alias IonosphereVisualizer.SPIDR.Client
  alias Ecto.Model

  plug :scrub_params, "chart" when action in [:create]

  def index(conn, _params) do
    changeset = Chart.changeset(%Chart{})
    stations = Repo.all from s in Station, where: is_nil(s.date_to)#Repo.all(Station)
    types = ParameterType.get_types
    render(conn, "index.html", changeset: changeset, stations: stations, types: types)
  end

  def create(conn, %{"chart" => chart_params}) do
    changeset = Chart.changeset(%Chart{}, chart_params)
    chart = changeset.changes
    measurements = (Repo.all from s in Station,
      join: m in assoc(s, :measurements),
      select: {s, m},
      where: s.code in ^chart.stations and m.measured_at >= ^chart.time_from and m.measured_at <= ^chart.time_to and m.parameter_type == ^chart.parameter_type)
    |> List.foldl(%{}, fn({s, m}, acc) ->
      Map.update(acc, s, [], &([m | &1]))
    end)
    #TODO Prettify
    #OPTIMIZE
    |> (fn(measurements) -> (Repo.all from s in Station, where: s.code in ^chart.stations) |> List.foldl(measurements, fn(station, acc) ->
      if is_nil(acc[station]) do
        Map.put_new(acc, station, [])
      else
        acc
      end
    end) end).()
    ###########################################
    |> Enum.into([], fn({station, measurements}) ->
      %{station: station, measurements: measurements}
    end)
    |> add_missing_measurements(chart.date_from, chart.date_to, chart.stations, chart.parameter_type)
    |> Enum.to_list

    conn
    |> put_status(:created)
    |> render("chart.json", %{chart: measurements,
      parameter_type: ParameterType.get(chart.parameter_type)})

    #case Repo.insert(changeset) do
     # {:ok, measurement} ->
      #  conn
       # |> put_status(:created)
        #|> put_resp_header("location", chart_path(conn, :show, measurement))
        #|> MeasurementView.render("show.json", measurement: measurement)
      #{:error, changeset} ->
       # conn
        #|> put_status(:unprocessable_entity)
        #|> render(IonosphereVisualizer.ChangesetView, "error.json", changeset: changeset)
    #end
  end

  defp add_missing_measurements(data, date_from, date_to, stations, parameter_type) do
    date_from = Date.from(Ecto.Date.to_erl(date_from))
    date_to = Date.from(Ecto.Date.to_erl(date_to))
    dates_list = 0..Date.diff(date_from, date_to, :days)
    |> Enum.map(&(Date.shift(date_from, days: &1)))
    |> Enum.map(&(Ecto.Date.cast({&1.year, &1.month, &1.day}) |> elem(1)))

    missing_measurements = pipe_while fn
        [] -> false
        _ -> true
      end,
      data
      |> Stream.map(&(missing_dates(&1, dates_list)))
      |> Stream.reject(fn({_, dates}) ->
        Enum.empty?(dates)
      end)
      |> Stream.map(fn({station, dates}) ->
        from = dates |> hd
        to = dates |> List.last
        {from, to, [station]}
      end)
      |> Enum.to_list
      |> Enum.reduce(fn({from, to, [station]}, {acc_from, acc_to, stations}) ->
        acc_from = case Ecto.Date.compare(from, acc_from) do
          :lt -> from
          _ -> acc_from
        end
        acc_to = case Ecto.Date.compare(to, acc_to) do
          :gt -> to
          _ -> acc_to
        end
        {acc_from, acc_to, [station | stations]}
      end)
      |> (fn({from, to, stations}) -> {from, to, Enum.reverse(stations)} end).()
      |> get_missing_measurements(parameter_type, data)
      |> Enum.reject(fn
        %{measurements: []} -> true
        _ -> false
      end)
      |> Stream.map(fn(elem = %{measurements: measurements}) ->
        measurements = for measurement <- measurements,
          do: Dict.put_new(measurement, :parameter_type, parameter_type)
        %{elem | measurements: measurements}
      end)

      missing_measurements
      |> add_missing_measurements(data)
  end

  defp add_missing_measurements([], data), do: data
  defp add_missing_measurements(missing_measurements, data) do
    missing_measurements
    |> persist_measurements
    |> merge_measurements(data)
  end

  defp missing_dates(%{station: station, measurements: []}, dates_list),
    do: {station, dates_list}
  defp missing_dates(%{station: station, measurements: measurements}, dates_list) do
    dates = measurements
    |> Enum.into(HashSet.new, &(Ecto.DateTime.to_date(&1.measured_at)))

    missing_dates = dates_list
    |> Enum.reject(&(Set.member?(dates, &1)))
    {station, missing_dates}
  end

  defp get_missing_measurements({date_from, date_to, stations}, parameter_type, data) do
    (for station <- stations,
      do: %{parameter_type: parameter_type, station: station.code})
    |> Client.get_data(date_from, date_to)
    |> Enum.map(fn(elem) ->
      data
      |> Enum.find(&(&1.station.code == elem.station))
      |> filter_measurements(elem)
    end)
  end

  defp filter_measurements(data, %{measurements: measurements}) do
    %{station: station, measurements: persisted_measurements} = data
    filtered_measurements = measurements
    |> Enum.reject(fn(measurement) ->
      persisted_measurements
      |> Enum.find(fn(persisted_m) ->
        Ecto.DateTime.compare(persisted_m.measured_at,
          measurement.measured_at) === :eq
      end)
    end)
    %{data | measurements: filtered_measurements}
  end

  defp persist_measurements(data) do
    #TODO check for duplicates
    data
    |> Enum.map(fn(elem = %{station: station, measurements: measurements}) ->
      {:ok, measurements} = Repo.transaction(fn ->
        measurements
        |> Enum.map(fn(measurement) ->
          measurement = Model.build(station, :measurements, measurement)
          Repo.insert!(measurement)
        end)
      end)
      %{elem | measurements: measurements}
    end)
  end

  defp merge_measurements(missing_data, data) do
    missing_data = missing_data
    |> Enum.reduce(%{}, fn(elem, acc) ->
      Dict.put_new(acc, elem.station, elem.measurements)
    end)

    data
    |> Enum.map(fn(elem) ->
      %{station: station, measurements: measurements} = elem
      %{elem | measurements: measurements ++ Map.get(missing_data, station, [])}
    end)
  end
end
