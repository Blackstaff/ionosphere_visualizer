defmodule IonosphereVisualizer.Station do
  use IonosphereVisualizer.Web, :model

  schema "stations" do
    field :code, :string
    field :name, :string
    field :date_from, Ecto.Date
    field :date_to, Ecto.Date
    field :location, Geo.Point

    has_many :measurements, IonosphereVisualizer.Measurement
    timestamps
  end

  @required_fields ~w(code name date_from location)
  @optional_fields ~w(date_to)

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
