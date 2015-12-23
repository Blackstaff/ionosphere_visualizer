defmodule IonosphereVisualizer.Interpolator.IDW do
  @behaviour IonosphereVisualizer.Interpolator
  @p 4

  def interpolate(locations, samples) when is_list(locations) do
    #OPTIMIZE
    locations
    #|> Enum.map(&Task.async(fn -> interpolate(&1, samples) end))
    #|> Enum.map(&(Task.await(&1)))
    |> Enum.map(&(interpolate(&1, samples)))
  end

  def interpolate(location, samples) when is_map(location) do
    {val_dist, dist} = samples
    |> Enum.reduce_while({0, 0}, fn(sample, {val_dist, dist}) ->
      %{value: val, location: sample_loc} = sample
      dist_pow = :math.pow(Geocalc.distance_between(location, sample_loc), @p)
      if dist_pow == 0 do
        {:halt, {val, 1}}
      else
        {:cont, {val_dist + val / dist_pow, dist + 1 / dist_pow}}
      end
    end)
    %{value: val_dist / dist, location: location}
  end
end
