defmodule IonosphereVisualizer.ParameterType do
  @types ~w(foF2 foE hpF hmF2)
  @units %{"foF2" => "MHz", "foE" => "MHz", "hpF" => "km", "hmF2" => "km"}

  def get_types do
    @types
  end

  def get_unit(type) do
    @units[type]
  end
end
