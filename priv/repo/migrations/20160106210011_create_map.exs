defmodule IonosphereVisualizer.Repo.Migrations.CreateMap do
  use Ecto.Migration

  def change do
    create table(:maps) do
      add :data, {:array, :map}
      add :datetime, :datetime
      add :parameter_type, :string

      timestamps
    end
  end
end
