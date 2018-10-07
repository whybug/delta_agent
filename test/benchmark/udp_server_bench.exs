Logger.configure(level: :warn)
{:ok, socket} = :gen_udp.open(0, [:binary])

inputs = %{
  "Small (1 Thousand)" => Enum.to_list(1..1_000),
  "Middle (100 Thousand)" => Enum.to_list(1..100_000),
  "Big (10 Million)" => Enum.to_list(1..10_000_000)
}

Benchee.run(
  %{
    "udp_server" => fn -> :gen_udp.send(socket, '127.0.0.1', 2135, '{"body": "test"}') end
  },
  parallel: 1
)

# inputs: inputs

# Async task, json parsing, insert ets
# Name                 ips        average  deviation         median         99th %
# udp_server       11.08 K       90.22 μs   ±235.91%          76 μs         224 μs
