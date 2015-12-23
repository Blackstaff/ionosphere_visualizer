defmodule IonosphereVisualizer.MapView do
  use IonosphereVisualizer.Web, :view

  def render("map.json", %{map: values, classes: classes}) do
    map = values
    |> into_feature_collection
    %{map: map, value_classes: classes}
  end

  defp into_feature_collection(values) do
    features = values
    |> Enum.map(fn(%{value: value, geometry: geometry}) ->
      %{type: "Feature", geometry: Geo.JSON.encode(geometry), properties: %{value: value}}
    end)
    %{type: "FeatureCollection", features: features,
      crs: %{type: "name", properties: %{name: "EPSG:4326"}}}
  end
end