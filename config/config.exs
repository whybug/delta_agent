use Mix.Config

config :delta_agent,
  host: "https://delta.whybug.com",
  udp_port: 2135,
  api_key: "",
  flush_interval: 10_000,
  buffer_size: 5_000

config :logger,
  backends: [:console],
  compile_time_purge_matching: [
    [level_lower_than: :debug]
  ]

config :logger, :console, metadata: [:idempotency_key]
