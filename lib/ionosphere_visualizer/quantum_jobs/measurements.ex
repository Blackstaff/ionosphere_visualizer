defmodule IonosphereVisualizer.QuantumJobs.Measurements do
  use Timex

  import Ecto.Query, only: [from: 2]

  alias IonosphereVisualizer.Repo
  alias IonosphereVisualizer.Measurement
  alias IonosphereVisualizer.Station
  alias IonosphereVisualizer.ParameterType
  alias IonosphereVisualizer.SPIDR.Client
  alias Ecto.Model

  def fetch do
    {:ok, date} = Date.now
    |> Ecto.Date.cast
    stations = (Repo.all from s in Station,
      where: is_nil(s.date_to))
    |> Enum.into(%{}, fn(station) -> {station.code, station} end)
    types = ParameterType.get_names
    measurements = Client.get_data({types, Dict.keys(stations)}, date)

    time_from = date
    |> Ecto.DateTime.from_date
    time_to = %{time_from | hour: 23, min: 59}

    persisted_measurements = (Repo.all from m in Measurement,
      join: s in assoc(m, :station),
      select: %{parameter_type: m.parameter_type,
        measured_at: m.measured_at, station: s.code},
      where: m.measured_at >= ^time_from
        and m.measured_at <= ^time_to
        and m.parameter_type in ^types)
    |> Enum.into(MapSet.new)

    Repo.transaction(fn ->
      measurements
      |> Stream.map(fn(elem) ->
        measurements = elem.measurements
        |> Enum.filter(fn(m) ->
          m = %{parameter_type: elem.parameter_type,
            measured_at: m.measured_at, station: elem.station}
          !Set.member?(persisted_measurements, m)
        end)
        %{elem | measurements: measurements, station: stations[elem.station]}
      end)
      |> Enum.filter(&(length(&1.measurements) > 0))
      |> Measurement.build
      |> Stream.flat_map(&(&1))
      |> Enum.map(fn(measurement) -> Repo.insert!(measurement) end)
    end)
  end
end
