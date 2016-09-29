defmodule IonosphereVisualizer.SPIDR do
  @callback get_data(params :: Map.t, date_from :: String.t, date_to :: String.t) :: List.t
  @callback get_metadata(param :: String.t) :: Map.t
  @callback get_station_list(param :: String.t) :: List.t
end
