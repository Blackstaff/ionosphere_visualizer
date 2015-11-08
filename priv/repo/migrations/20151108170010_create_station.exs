defmodule IonosphereVisualizer.Repo.Migrations.CreateStation do
  use Ecto.Migration

  def change do
    create table(:stations) do
      add :name, :string
      add :full_name, :string
      add :date_from, :date
      add :date_to, :date
      add :location, :geography

      timestamps
    end

  end
end
