defmodule DeltaAgent do
  use Application

  require Logger

  alias DeltaAgent.Config
  alias DeltaAgent.Collector
  alias DeltaAgent.Collector.UdpServer
  alias DeltaAgent.Collector.HttpServer
  alias DeltaAgent.Forwarder

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    Logger.info("Agent starting (version #{Config.find(:version)})")

    children = [
      worker(Collector, []),
      worker(UdpServer, [Config.find(:udp_port)]),
      worker(HttpServer, [Config.find(:http_port)]),
      worker(Forwarder, [])
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: DeltaAgent.Supervisor)
  end
end
