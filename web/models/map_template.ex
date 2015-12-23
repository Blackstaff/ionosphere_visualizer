defmodule IonosphereVisualizer.MapTemplate do
  @default_lat {-80, 80}
  @default_lon {-179, 179}
  @default_step 1

  def get({from_lat, to_lat}, {from_lon, to_lon}, step) do
    Stream.iterate(from_lat, &(&1 + step))
    |> Enum.take_while(&(&1 <= to_lat))
    |> Enum.flat_map(fn(x) ->
      Stream.iterate(from_lon, &(&1 + step))
      |> Enum.take_while(&(&1 <= to_lon))
      |> Enum.map(fn(y)->
        %{latitude: x, longitude: y}
      end)
    end)
  end
end
