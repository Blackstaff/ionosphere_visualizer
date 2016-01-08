defmodule IonosphereVisualizer.ParameterType do
  defstruct name: "", long_name: "", unit: ""

  @types [
    %{
      name: "foF2",
      long_name: "F2 layer critical frequency",
      unit: "MHz"
    },
    %{
      name: "foE",
      long_name: "E layer critical frequency",
      unit: "MHz"
    },
    %{
      name: "hpF",
      long_name: "Minimum virtual height of F trace",
      unit: "km"
    },
    %{
      name: "hmF2",
      long_name: "Peak height of F2 layer",
      unit: "km"
    }
  ]

  def get_names do
    for type <- @types, do: type.name
  end

  def get_types do
    for type <- @types, do: struct(__MODULE__, type)
  end

  def get(name) do
    type = @types
    |> Enum.find(&(&1.name == name))
    struct(__MODULE__, type)
  end
end
