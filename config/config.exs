use Mix.Config

config :delta_agent,
  api_host: "https://delta.whybug.com",
  udp_port: System.get_env("UDP_PORT") || 2135,
  http_port: System.get_env("HTTP_PORT") || 2135,
  flush_interval_ms: System.get_env("FLUSH_INTERVAL_MS") || 10_000,
  buffer_size_kb: System.get_env("BUFFER_SIZE_KB") || 10_000

config :logger,
  backends: [:console],
  compile_time_purge_matching: [
    [level_lower_than: :debug]
  ]

config :logger, :console,
  metadata: [:idempotency_key],
  format: "$time $metadata[$level] $levelpad$message\n"
