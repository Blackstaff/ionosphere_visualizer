defmodule IonosphereVisualizer.Repo.Migrations.CreateStation do
  use Ecto.Migration

  def change do
    create table(:stations) do
      add :code, :string
      add :name, :string
      add :date_from, :date
      add :date_to, :date
      add :location, :geography

      timestamps
    end

  end
end
