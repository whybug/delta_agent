defmodule DeltaAgent.ConfigTest do
  use ExUnit.Case
  doctest DeltaAgent.Config

  alias DeltaAgent.Config

  test "finds default UDP port to use" do
    assert Config.find(:udp_port) == 2135
  end
end
