defmodule IonosphereVisualizer.Repo.Migrations.CreateMeasurement do
  use Ecto.Migration

  def change do
    create table(:measurements) do
      add :value, :float
      add :measured_at, :datetime
      add :parameter_type, :string
      add :last_accessed, :datetime
      add :station_id, references(:stations)

      timestamps
    end
    create index(:measurements, [:station_id])

  end
end
