defmodule IonosphereVisualizer.ChartView do
  use IonosphereVisualizer.Web, :view

  def render("chart.json",  %{chart: chart, parameter_type: parameter_type, unit: unit}) do
    %{data: render_many(chart, IonosphereVisualizer.ChartView, "data_series.json", as: :data_series),
      parameter_type: parameter_type, unit: unit}
  end

  def render("data_series.json", %{data_series: data_series}) do
    %{station: station, measurements: measurements} = data_series
    %{station: render_one(station, IonosphereVisualizer.StationView, "station.json"),
      measurements: render_many(measurements, IonosphereVisualizer.MeasurementView, "measurement.json")}
  end

  def to_code_name_tuples(stations) do
  	for station <- stations, do: {station.name, station.code}
  end
end
