defmodule IonosphereVisualizer.MapGenerator do
  alias IonosphereVisualizer.Interpolator.IDW
  alias IonosphereVisualizer.MapTemplate

  def generate(samples, lat, lon, step) do
    MapTemplate.get(lat, lon, step)
    |> IDW.interpolate(samples)
    |> polygonize(step)
  end

  defp polygonize(values, step) do
    values
    |> Enum.map(fn(%{value: value, location: location}) ->
      %{"value" => value, "geometry" => point_to_polygon(location, step)}
    end)
  end

  defp point_to_polygon(%{latitude: lat, longitude: lon}, step),
    do: point_to_polygon(lat, lon, step)
  defp point_to_polygon(lat, lon, step) do
    offset = step / 2
    upper_l = {lon - offset, lat + offset}
    upper_r = {lon + offset, lat + offset}
    bottom_r = {lon + offset, lat - offset}
    bottom_l = {lon - offset, lat - offset}
    %Geo.Polygon{coordinates: [[upper_l, upper_r, bottom_r, bottom_l, upper_l]]}
    |> Geo.JSON.encode
    #TODO maybe create Polygon struct and get rid of geo library completely?
  end
end
