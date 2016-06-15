# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :mana,
  ecto_repos: [Mana.Repo]

# Configures the endpoint
config :mana, Mana.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "wlR2fnLnP2Xuw9QFRKueKd6gharfViEFTUO7PYZwrTnUBSl3lFIhEOW1Cq/Twxd1",
  render_errors: [accepts: ~w(html json)],
  pubsub: [name: Mana.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Configure phoenix generators
config :phoenix, :generators,
  migration: true,
  binary_id: false

config :guardian, Guardian,
  allowed_algos: ["HS512"],
  verify_module: Guardian.JWT,
  issuer: "Mana",
  ttl: { 30, :days },
  verify_issuer: true,
  serializer: Mana.GuardianSerializer,
  secret_key: "uyE5qrCDyIPW0nL3q49XSgLuDdqtE7XcMX1yKD4m5b01exJvNoTUwhp52H23L3rf"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
