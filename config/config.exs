# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :chukinas,
  ecto_repos: [Chukinas.Repo]

# Configures the endpoint
config :chukinas, ChukinasWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "zZwwhFZNgMm5ObJ5k7iJAyRH27UZQX4aL+6Cfw54p3jZdUS0K/hg1SYNOA1MPkac",
  render_errors: [view: ChukinasWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Chukinas.PubSub,
  live_view: [signing_salt: "4bfIP8sz"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
