defmodule IonosphereVisualizer.MeasurementView do
  use IonosphereVisualizer.Web, :view

  def render("index.json", %{measurements: measurements}) do
    %{data: render_many(measurements, IonosphereVisualizer.MeasurementView, "measurement.json")}
  end

  def render("show.json", %{measurement: measurement}) do
    %{data: render_one(measurement, IonosphereVisualizer.MeasurementView, "measurement.json")}
  end

  def render("measurement.json", %{measurement: measurement}) do
    %{id: measurement.id,
      value: measurement.value,
      measured_at: measurement.measured_at,
      parameter_type: measurement.parameter_type,
      last_accessed: measurement.last_accessed,
      station_id: measurement.station_id}
  end
end
