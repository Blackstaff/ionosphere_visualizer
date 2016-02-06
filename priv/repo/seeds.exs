# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     IonosphereVisualizer.Repo.insert!(%SomeModel{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias IonosphereVisualizer.Repo
alias IonosphereVisualizer.Station
alias IonosphereVisualizer.Measurement
alias IonosphereVisualizer.Map
alias IonosphereVisualizer.SPIDR.Client

Repo.delete_all(Map)
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
