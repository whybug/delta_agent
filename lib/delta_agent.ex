defmodule DeltaAgent do
  use Application

  alias DeltaAgent.Config
  alias DeltaAgent.Collector
  alias DeltaAgent.Collector.UdpServer
  alias DeltaAgent.Forwarder

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(Collector, []),
      worker(UdpServer, [Config.find(:udp_port)]),
      worker(Forwarder, [])
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: DeltaAgent.Supervisor)
  end
end
