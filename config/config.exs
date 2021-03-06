# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :ionosphere_visualizer, IonosphereVisualizer.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "9vPw36v4sDBSUL2GOY9s5j4YY0p+UMlwOWdOrw1Cod6viNnCMm1HPTc/YstiYB0J",
  render_errors: [accepts: ~w(html json)],
  pubsub: [name: IonosphereVisualizer.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

# Configure phoenix generators
config :phoenix, :generators,
  migration: true,
  binary_id: false

# Cronjobs
config :quantum, cron: [
  "*/15 * * * * IonosphereVisualizer.QuantumJobs.Measurements.fetch"
]

config :ionosphere_visualizer, ecto_repos: [IonosphereVisualizer.Repo]
