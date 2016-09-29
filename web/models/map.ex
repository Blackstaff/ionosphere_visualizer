defmodule IonosphereVisualizer.Map do
  use IonosphereVisualizer.Web, :model

  schema "maps" do
    field :data, {:array, :map}
    field :datetime, Ecto.DateTime
    field :parameter_type, :string

    timestamps
  end

  @required_fields ~w(data datetime parameter_type)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end
