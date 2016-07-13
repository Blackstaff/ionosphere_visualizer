defmodule Seeds do
  alias IonosphereVisualizer.Repo
  alias IonosphereVisualizer.Station
  alias IonosphereVisualizer.Measurement
  alias IonosphereVisualizer.SPIDR.Client

  def populate do
    Repo.delete_all(Measurement)
    Repo.delete_all(Station)

    Client.get_station_list("iono")
    |> Stream.map(fn(station) ->
      try do
        Client.get_metadata("iono.#{station}")
      rescue
        _ -> :error
      end
    end)
    |> Stream.filter(&(&1 != :error))
    |> Stream.map(&(Station.changeset(%Station{}, &1)))
    |> Enum.map(&(Repo.insert!(&1)))
  end
end
