defmodule DeltaAgent.Collector.UdpServer do
  @moduledoc """
  UDP server which sends received data to a collector.
  """
  use GenServer, restart: :permanent

  require Logger
  alias DeltaAgent.Collector

  def start_link(port) do
    GenServer.start_link(__MODULE__, port)
  end

  def init(port) do
    :gen_udp.open(port, [:binary, active: true])

    Logger.info("Listening on UDP port #{port} 🎉")

    {:ok, port}
  end

  def handle_info({:udp, _socket, _ip, _port, data}, state) do
    # "Fire and forget" task to not block the client
    Task.start(fn ->
      Logger.debug("Received UDP data: " <> inspect(data))
      {:ok} = Collector.collect(data)
    end)

    {:noreply, state}
  end

  def handle_info(_, state) do
    {:noreply, state}
  end
end
