defmodule IonosphereVisualizer.Station do
  use IonosphereVisualizer.Web, :model

  schema "stations" do
    field :name, :string
    field :full_name, :string
    field :date_from, Ecto.Date
    field :date_to, Ecto.Date
    field :location, Geo.Point

    timestamps
  end

  @required_fields ~w(name full_name date_from location)
  @optional_fields ~w(date_to)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end
