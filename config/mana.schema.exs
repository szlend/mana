@moduledoc """
A schema is a keyword list which represents how to map, transform, and validate
configuration values parsed from the .conf file. The following is an explanation of
each key in the schema definition in order of appearance, and how to use them.

## Import

A list of application names (as atoms), which represent apps to load modules from
which you can then reference in your schema definition. This is how you import your
own custom Validator/Transform modules, or general utility modules for use in
validator/transform functions in the schema. For example, if you have an application
`:foo` which contains a custom Transform module, you would add it to your schema like so:

`[ import: [:foo], ..., transforms: ["myapp.some.setting": MyApp.SomeTransform]]`

## Extends

A list of application names (as atoms), which contain schemas that you want to extend
with this schema. By extending a schema, you effectively re-use definitions in the
extended schema. You may also override definitions from the extended schema by redefining them
in the extending schema. You use `:extends` like so:

`[ extends: [:foo], ... ]`

## Mappings

Mappings define how to interpret settings in the .conf when they are translated to
runtime configuration. They also define how the .conf will be generated, things like
documention, @see references, example values, etc.

See the moduledoc for `Conform.Schema.Mapping` for more details.

## Transforms

Transforms are custom functions which are executed to build the value which will be
stored at the path defined by the key. Transforms have access to the current config
state via the `Conform.Conf` module, and can use that to build complex configuration
from a combination of other config values.

See the moduledoc for `Conform.Schema.Transform` for more details and examples.

## Validators

Validators are simple functions which take two arguments, the value to be validated,
and arguments provided to the validator (used only by custom validators). A validator
checks the value, and returns `:ok` if it is valid, `{:warn, message}` if it is valid,
but should be brought to the users attention, or `{:error, message}` if it is invalid.

See the moduledoc for `Conform.Schema.Validator` for more details and examples.
"""
[
  extends: [],
  import: [],
  mappings: [
    "phoenix.generators.migration": [
      commented: false,
      datatype: :atom,
      default: true,
      doc: "Provide documentation for phoenix.generators.migration here.",
      hidden: false,
      to: "phoenix.generators.migration"
    ],
    "phoenix.generators.binary_id": [
      commented: false,
      datatype: :atom,
      default: false,
      doc: "Provide documentation for phoenix.generators.binary_id here.",
      hidden: false,
      to: "phoenix.generators.binary_id"
    ],
    "mana.ecto_repos": [
      commented: false,
      datatype: [
        list: :atom
      ],
      default: [
        Mana.Repo
      ],
      doc: "Provide documentation for mana.ecto_repos here.",
      hidden: false,
      to: "mana.ecto_repos"
    ],
    "mana.Elixir.Mana.Endpoint.render_errors.accepts": [
      commented: false,
      datatype: [
        list: :binary
      ],
      default: [
        "html",
        "json"
      ],
      doc: "Provide documentation for mana.Elixir.Mana.Endpoint.render_errors.accepts here.",
      hidden: false,
      to: "mana.Elixir.Mana.Endpoint.render_errors.accepts"
    ],
    "mana.Elixir.Mana.Endpoint.pubsub.name": [
      commented: false,
      datatype: :atom,
      default: Mana.PubSub,
      doc: "Provide documentation for mana.Elixir.Mana.Endpoint.pubsub.name here.",
      hidden: false,
      to: "mana.Elixir.Mana.Endpoint.pubsub.name"
    ],
    "mana.Elixir.Mana.Endpoint.pubsub.adapter": [
      commented: false,
      datatype: :atom,
      default: Phoenix.PubSub.PG2,
      doc: "Provide documentation for mana.Elixir.Mana.Endpoint.pubsub.adapter here.",
      hidden: false,
      to: "mana.Elixir.Mana.Endpoint.pubsub.adapter"
    ],
    "mana.Elixir.Mana.Endpoint.http.ip": [
      commented: false,
      datatype: :binary,
      doc: "Provide documentation for mana.Elixir.Mana.Endpoint.http.ip here.",
      hidden: false,
      to: "mana.Elixir.Mana.Endpoint.http.ip"
    ],
    "mana.Elixir.Mana.Endpoint.http.port": [
      commented: false,
      datatype: :integer,
      default: 80,
      doc: "Provide documentation for mana.Elixir.Mana.Endpoint.http.port here.",
      hidden: false,
      to: "mana.Elixir.Mana.Endpoint.http.port"
    ],
    "mana.Elixir.Mana.Endpoint.url.scheme": [
      commented: false,
      datatype: :binary,
      default: "http",
      doc: "Provide documentation for mana.Elixir.Mana.Endpoint.url.scheme here.",
      hidden: false,
      to: "mana.Elixir.Mana.Endpoint.url.scheme"
    ],
    "mana.Elixir.Mana.Endpoint.url.host": [
      commented: false,
      datatype: :binary,
      default: "localhost",
      doc: "Provide documentation for mana.Elixir.Mana.Endpoint.url.host here.",
      hidden: false,
      to: "mana.Elixir.Mana.Endpoint.url.host"
    ],
    "mana.Elixir.Mana.Endpoint.url.port": [
      commented: false,
      datatype: :integer,
      default: 80,
      doc: "Provide documentation for mana.Elixir.Mana.Endpoint.url.port here.",
      hidden: false,
      to: "mana.Elixir.Mana.Endpoint.url.port"
    ],
    "mana.Elixir.Mana.Endpoint.server": [
      commented: false,
      datatype: :atom,
      default: true,
      doc: "Provide documentation for mana.Elixir.Mana.Endpoint.server here.",
      hidden: false,
      to: "mana.Elixir.Mana.Endpoint.server"
    ],
    "mana.Elixir.Mana.Endpoint.version": [
      commented: false,
      datatype: :binary,
      default: "0.0.1",
      doc: "Provide documentation for mana.Elixir.Mana.Endpoint.version here.",
      hidden: false,
      to: "mana.Elixir.Mana.Endpoint.version"
    ],
    "mana.Elixir.Mana.Endpoint.secret_key_base": [
      commented: false,
      datatype: :binary,
      doc: "Provide documentation for mana.Elixir.Mana.Endpoint.secret_key_base here.",
      hidden: false,
      to: "mana.Elixir.Mana.Endpoint.secret_key_base"
    ],
    "mana.Elixir.Mana.Endpoint.root": [
      commented: false,
      datatype: :binary,
      default: ".",
      doc: "Provide documentation for mana.Elixir.Mana.Endpoint.root here.",
      hidden: false,
      to: "mana.Elixir.Mana.Endpoint.root"
    ],
    "mana.Elixir.Mana.Endpoint.cache_static_manifest": [
      commented: false,
      datatype: :binary,
      default: "priv/static/manifest.json",
      doc: "Provide documentation for mana.Elixir.Mana.Endpoint.cache_static_manifest here.",
      hidden: false,
      to: "mana.Elixir.Mana.Endpoint.cache_static_manifest"
    ],
    "mana.Elixir.Mana.Repo.adapter": [
      commented: false,
      datatype: :atom,
      default: Ecto.Adapters.Postgres,
      doc: "Provide documentation for mana.Elixir.Mana.Repo.adapter here.",
      hidden: false,
      to: "mana.Elixir.Mana.Repo.adapter"
    ],
    "mana.Elixir.Mana.Repo.hostname": [
      commented: false,
      datatype: :binary,
      default: "localhost",
      doc: "Provide documentation for mana.Elixir.Mana.Repo.hostname here.",
      hidden: false,
      to: "mana.Elixir.Mana.Repo.hostname"
    ],
    "mana.Elixir.Mana.Repo.database": [
      commented: false,
      datatype: :binary,
      default: "mana_production",
      doc: "Provide documentation for mana.Elixir.Mana.Repo.database here.",
      hidden: false,
      to: "mana.Elixir.Mana.Repo.database"
    ],
    "mana.Elixir.Mana.Repo.username": [
      commented: false,
      datatype: :binary,
      default: "mana",
      doc: "Provide documentation for mana.Elixir.Mana.Repo.username here.",
      hidden: false,
      to: "mana.Elixir.Mana.Repo.username"
    ],
    "mana.Elixir.Mana.Repo.password": [
      commented: false,
      datatype: :binary,
      doc: "Provide documentation for mana.Elixir.Mana.Repo.password here.",
      hidden: false,
      to: "mana.Elixir.Mana.Repo.password"
    ],
    "mana.Elixir.Mana.Repo.pool_size": [
      commented: false,
      datatype: :integer,
      default: 20,
      doc: "Provide documentation for mana.Elixir.Mana.Repo.pool_size here.",
      hidden: false,
      to: "mana.Elixir.Mana.Repo.pool_size"
    ],
    "kernel.sync_nodes_optional": [
      commented: false,
      datatype: [
        list: :atom
      ],
      default: [],
      doc: "Provide documentation for kernel.sync_nodes_optional here.",
      hidden: false,
      to: "kernel.sync_nodes_optional"
    ],
    "kernel.sync_nodes_timeout": [
      commented: false,
      datatype: :integer,
      default: 10000,
      doc: "Provide documentation for kernel.sync_nodes_timeout here.",
      hidden: false,
      to: "kernel.sync_nodes_timeout"
    ],
    "logger.console.format": [
      commented: false,
      datatype: :binary,
      default: """
      $time $metadata[$level] $message
      """,
      doc: "Provide documentation for logger.console.format here.",
      hidden: false,
      to: "logger.console.format"
    ],
    "logger.console.metadata": [
      commented: false,
      datatype: [
        list: :atom
      ],
      default: [
        :request_id
      ],
      doc: "Provide documentation for logger.console.metadata here.",
      hidden: false,
      to: "logger.console.metadata"
    ],
    "logger.level": [
      commented: false,
      datatype: :atom,
      default: :info,
      doc: "Provide documentation for logger.level here.",
      hidden: false,
      to: "logger.level"
    ]
  ],
  transforms: [],
  validators: []
]
