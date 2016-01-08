defmodule IonosphereVisualizer.MapView do
  use IonosphereVisualizer.Web, :view

  def render("map.json", %{map: map, classes: classes, parameter_type: type}) do
    map = map
    |> into_feature_collection
    %{map: map, value_classes: classes, parameter_type: type}
  end

  defp into_feature_collection(map) do
    features = map
    |> Enum.map(fn(%{"value" => value, "geometry" => geometry}) ->
      %{type: "Feature", geometry: geometry, properties: %{value: value}}
    end)
    %{type: "FeatureCollection", features: features,
      crs: %{type: "name", properties: %{name: "EPSG:4326"}}}
  end
end
