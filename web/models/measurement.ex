defmodule IonosphereVisualizer.Measurement do
  use IonosphereVisualizer.Web, :model

  schema "measurements" do
    field :value, :float
    field :measured_at, Ecto.DateTime
    field :parameter_type, :string
    field :last_accessed, Ecto.DateTime
    belongs_to :station, IonosphereVisualizer.Station

    timestamps
  end

  @required_fields ~w(value measured_at parameter_type)
  @optional_fields ~w(last_accessed)
  @parameter_types ~w(foF2 foE hpF hmF2)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> Ecto.Model.Timestamps.put_timestamp(:last_accessed, Ecto.DateTime, false)
    |> validate_inclusion(:parameter_type, @parameter_types)
  end
end
