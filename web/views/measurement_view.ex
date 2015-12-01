defmodule IonosphereVisualizer.MeasurementView do
  use IonosphereVisualizer.Web, :view

  def render("measurement.json", %{measurement: measurement}) do
    %{id: measurement.id,
      value: measurement.value,
      measured_at: measurement.measured_at}
  end
end
