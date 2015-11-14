defmodule IonosphereVisualizer.Router do
  use IonosphereVisualizer.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", IonosphereVisualizer do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end

  scope "/api", IonosphereVisualizer do
    pipe_through :api

    get "/measurements", MeasurementController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", IonosphereVisualizer do
  #   pipe_through :api
  # end
end
