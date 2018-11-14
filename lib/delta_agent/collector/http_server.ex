defmodule DeltaAgent.Collector.HttpServer do
  @moduledoc """
  HTTP server which sends received data to a collector.
  """

  require Logger

  def start_link(port) do
    GenServer.start_link(__MODULE__, port)
  end

  def init(port) do
    Logger.info("Listening on HTTP port #{port}} 🎉")
  end
end
