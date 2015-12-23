defmodule IonosphereVisualizer.Interpolator do
  @callback interpolate(locations :: [{number, number}], samples :: [%{value: number, location: {number, number}}])
  :: [%{location: {number, number}, value: number}]
end
