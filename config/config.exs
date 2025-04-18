# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :code_reviewer, CodeReviewer.Repo,
  database: System.get_env("DB_NAME"),
  username: System.get_env("DB_USERNAME"),
  password: System.get_env("DB_PASSWORD"),
  hostname: System.get_env("DB_HOSTNAME"),
  port: 6543,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10,
  pool_mode: :transaction

config :code_reviewer, ecto_repos: [CodeReviewer.Repo]

config :ecto_shorts,
  repo: CodeReviewer.Repo,
  error_module: EctoShorts.Actions.Error

config :code_reviewer,
  generators: [timestamp_type: :utc_datetime]

# Configures the endpoint
config :code_reviewer, CodeReviewerWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: CodeReviewerWeb.ErrorHTML, json: CodeReviewerWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: CodeReviewer.PubSub,
  live_view: [signing_salt: "R1S9znMd"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :code_reviewer, CodeReviewer.Mailer, adapter: Swoosh.Adapters.Local

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  code_reviewer: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.4.3",
  code_reviewer: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
