defmodule IonosphereVisualizer.PageController do
  use IonosphereVisualizer.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
