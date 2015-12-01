defmodule IonosphereVisualizer.Chart do
  use IonosphereVisualizer.Web, :model

  schema "charts" do
    field :parameter_type, :string
    field :stations, {:array, :string}
    field :date_from, Ecto.Date
    field :date_to, Ecto.Date
    field :time_from, Ecto.DateTime
    field :time_to, Ecto.DateTime
  end

  @required_fields ~w(parameter_type stations date_from date_to)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> add_times
  end

  defp add_times(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true} ->
        date_from = changeset.changes.date_from
        date_to = changeset.changes.date_to
        changeset
        |> put_change(:time_from, Ecto.DateTime.from_date(date_from))
        |> put_change(:time_to, Ecto.DateTime.from_date_and_time(date_to, elem(Ecto.Time.cast("23:59:59"), 1)))
      _ -> changeset
    end
  end
end
