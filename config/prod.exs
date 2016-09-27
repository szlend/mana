use Mix.Config

config :mana, Mana.Endpoint,
  http: [ip: {0, 0, 0, 0}, port: 80],
  url: [scheme: "http", host: "localhost", port: 80],
  server: true,
  version: Mix.Project.config[:version],
  secret_key_base: "",
  root: ".",
  cache_static_manifest: "priv/static/manifest.json"

config :mana, Mana.Repo,
  adapter: Ecto.Adapters.Postgres,
  hostname: "localhost",
  database: "mana_production",
  username: "mana",
  password: "",
  pool_size: 20

config :kernel,
  sync_nodes_optional: [],
  sync_nodes_timeout: 10000

config :logger, level: :info
