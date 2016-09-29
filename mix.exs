defmodule IonosphereVisualizer.Mixfile do
  use Mix.Project

  def project do
    [app: :ionosphere_visualizer,
     version: "0.0.1",
     elixir: "~> 1.3",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix, :gettext] ++ Mix.compilers,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [mod: {IonosphereVisualizer, []},
     applications: [:phoenix, :phoenix_pubsub, :phoenix_html, :cowboy, :logger, :phoenix_ecto,
      :postgrex, :httpoison, :tzdata, :quantum, :timex, :floki, :gettext, :geo]]
  end

  # Specifies which paths to compile per environment
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]

  defp aliases do
    ["ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      "test": ["ecto.create --quiet", "ecto.migrate", "test"]]
  end

  # Specifies your project dependencies
  #
  # Type `mix help deps` for examples and options
  defp deps do
    [{:phoenix, "~> 1.2"},
     {:phoenix_pubsub, "~> 1.0"},
     {:phoenix_ecto, "~> 3.0"},
     {:postgrex, ">= 0.0.0"},
     {:phoenix_html, "~> 2.6"},
     {:phoenix_live_reload, "~> 1.0", only: :dev},
     {:cowboy, "~> 1.0"},
     {:httpoison, "~> 0.7.2"},
     {:csv, "~> 1.2.0"},
     {:sweet_xml, "~> 0.5.0"},
     {:floki, "~> 0.5.0"},
     {:geo, "~> 1.1"},
     #{:valid_field, "~> 0.2.0", only: :test},
     {:timex, "~> 1.0.0-rc2"},
     {:pipe, "~> 0.0.2"},
     {:geocalc, "~> 0.4.0"},
     {:quantum, ">= 1.6.1"},
     {:exrm, "~> 1.0.0-rc7", override: true},
     {:conform, "~> 1.0.0-rc8", override: true},
     {:conform_exrm, "~> 0.2.0"},
     {:gettext, "~> 0.9"}]
  end
end
