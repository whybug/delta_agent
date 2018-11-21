defmodule DeltaAgent.Collector.UdpServerTest do
  use ExUnit.Case

  alias DeltaAgent.Config

  test "sends invalid UDP data to collector" do
    send('')
  end

  test "sends valid UDP data to collector" do
    send('{"body": "example"}')
  end

  defp send(data) do
    {:ok, socket} = :gen_udp.open(0, [:binary])

    :gen_udp.send(socket, '127.0.0.1', Config.find(:udp_port), data)
  end
end
