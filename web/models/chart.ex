defmodule IonosphereVisualizer.Chart do
  use IonosphereVisualizer.Web, :model

  schema "charts" do
    field :parameter_type, :string
    field :stations, {:array, :string}
    field :date_range, :string
    field :date_from, Ecto.Date
    field :date_to, Ecto.Date
    field :time_from, Ecto.DateTime
    field :time_to, Ecto.DateTime
  end

  @required_fields ~w(parameter_type stations date_range)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> put_dates
    |> put_times
  end

  defp put_dates(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true} ->
        {date_from, date_to} = changeset.changes.date_range |> parse_date_range
        case {date_from, date_to} do
          {{:ok, x}, {:ok, y}} ->
            changeset
            |> put_change(:date_from, x)
            |> put_change(:date_to, y)
          {{:ok, _}, _} -> changeset
            |> Ecto.Changeset.add_error(:date_to, "invalid")
          {_, {:ok, _}} -> changeset
            |> Ecto.Changeset.add_error(:date_from, "invalid")
          {_, _} -> changeset
            |> Ecto.Changeset.add_error(:date_from, "invalid")
            |> Ecto.Changeset.add_error(:date_to, "invalid")
        end
      _ -> changeset
    end
  end

  defp parse_date_range(date_range) do
    captures = ~r/^(?<day_fr>\d{2})\/(?<month_fr>\d{2})\/(?<year_fr>\d{4})\s
      -\s(?<day_to>\d{2})\/(?<month_to>\d{2})\/(?<year_to>\d{4})/mx
    |> Regex.named_captures(date_range)
    { %{day: captures["day_fr"], month: captures["month_fr"],
        year: captures["year_fr"]} |> Ecto.Date.cast,
      %{day: captures["day_to"], month: captures["month_to"],
        year: captures["year_to"]} |> Ecto.Date.cast }
  end

  defp put_times(changeset) do
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
