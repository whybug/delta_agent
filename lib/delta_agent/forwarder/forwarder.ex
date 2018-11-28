defmodule DeltaAgent.Forwarder do
  @moduledoc """
  Forwards collected data on a scheduled interval to a backend.

  If the backend fails, forwarding will be retried as long as
  the collector can keep the data size within its limits.
  """
  require Logger
  use Retry
  alias DeltaAgent.{Collector, Config}
  alias DeltaAgent.Collector.{Batch}
  alias DeltaAgent.Forwarder.HttpBackend

  # 2h
  @backend_expiry 120 * 60_000

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(_state) do
    schedule_next_flush()
    Logger.info("Forwarder ready ▶️")

    {:ok, []}
  end

  def handle_info(:flush, _state) do
    {:ok, batch} = Collector.flush()
    schedule_next_flush()

    Task.start(fn ->
      retry with: exponential_backoff() |> expiry(@backend_expiry), atoms: [:retry] do
        forward_batch(batch)
      after
        result -> result
      else
        {:error, message} ->
          Logger.error(message)
      end
    end)

    {:noreply, []}
  end

  defp forward_batch(%Batch{usages: usages}) when usages == %{} do
    Logger.debug("Nothing to forward")

    {:ok}
  end

  defp forward_batch(batch), do: HttpBackend.forward(batch)

  defp schedule_next_flush do
    Process.send_after(self(), :flush, Config.find(:flush_interval_ms))
  end
end
