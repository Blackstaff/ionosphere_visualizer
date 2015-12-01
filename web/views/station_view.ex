defmodule IonosphereVisualizer.StationView do
  use IonosphereVisualizer.Web, :view

  def render("station.json", %{station: station}) do
    %{id: station.id,
      code: station.code,
      name: station.name}
  end
end
