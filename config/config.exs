use Mix.Config

config :logger,
  backends: [:console],
  compile_time_purge_matching: [
    [level_lower_than: :debug]
  ]

config :logger, :console,
  metadata: [:idempotency_key, :data, :message],
  format: "$time $metadata[$level] $levelpad$message\n"

import_config "../rel/config/config.exs"

import_config "#{Mix.env()}.exs"
