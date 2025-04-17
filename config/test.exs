import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :code_reviewer, CodeReviewerWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "8xKq8cM5ESMAfCfnQ39SjsLLbhKE0dYwGOd9oXwVaCXYulpXfEjPzQV0jTc7Bo7g",
  server: false

config :code_reviewer, CodeReviewer.Repo,
  database: "postgres",
  username: "postgres",
  password: "postgres",
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

config :code_reviewer, ecto_repos: [CodeReviewer.Repo]

config :ecto_shorts,
  repo: CodeReviewer.Repo,
  error_module: EctoShorts.Actions.Error

# In test we don't send emails
config :code_reviewer, CodeReviewer.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Enable helpful, but potentially expensive runtime checks
config :phoenix_live_view,
  enable_expensive_runtime_checks: true
