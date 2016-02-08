defmodule IonosphereVisualizer.ParameterType do
  import IonosphereVisualizer.Gettext

  defstruct name: "", long_name: "", unit: ""

  @types [
    %{
      name: "foF2",
      long_name: gettext("F2 layer critical frequency"),
      unit: "MHz"
    },
    %{
      name: "foE",
      long_name: gettext("E layer critical frequency"),
      unit: "MHz"
    },
    %{
      name: "hpF",
      long_name: gettext("Minimum virtual height of F trace"),
      unit: "km"
    },
    %{
      name: "hmF2",
      long_name: gettext("Peak height of F2 layer"),
      unit: "km"
    },
    %{
      name: "MUF3000",
      long_name: gettext("Maximum usable frequency"),
      unit: "MHz"
    }
  ]

  def get_names do
    for type <- @types, do: type.name
  end

  def get_types do
    for type <- @types, do: struct(__MODULE__, Map.put(type, :long_name,
      Gettext.gettext(IonosphereVisualizer.Gettext, type.long_name)))
  end

  def get(name) do
    type = @types
    |> Enum.find(&(&1.name == name))
    struct(__MODULE__, Map.put(type, :long_name,
      Gettext.gettext(IonosphereVisualizer.Gettext, type.long_name)))
  end
end
