use Mix.Config

config :delta_agent,
       version: System.get_env("APP_VERSION") || "dev",
       api_host: System.get_env("API_HOST") || "https://delta.whybug.com",
       udp_port: String.to_integer(System.get_env("UDP_PORT") || "2135"),
       http_port: String.to_integer(System.get_env("HTTP_PORT") || "2135"),
       flush_interval_ms: String.to_integer(System.get_env("FLUSH_INTERVAL_MS") || "10000"),
       buffer_size_kb: String.to_integer(System.get_env("BUFFER_SIZE_KB") || "10000")

config :logger,
       backends: [:console],
       compile_time_purge_matching: [
         [level_lower_than: :debug]
       ]

config :logger, :console,
       metadata: [:idempotency_key, :data, :message],
       format: "$time $metadata[$level] $levelpad$message\n"

