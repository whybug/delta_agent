defmodule DeltaAgent.Forwarder do
  @moduledoc """
  Forwards collected data on a scheduled interval to a backend.

  If the backend fails, forwarding will be retried as long as
  the collector can keep the data size within its limits.
  """
  require Logger
  use Retry
  alias DeltaAgent.{Collector, Config}
  alias DeltaAgent.Forwarder.HttpBackend

  # 1h
  @backend_expiry 60 * 60_000

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(_state) do
    schedule_next_flush()
    Logger.info("Forwarder ready ▶️")

    {:ok, []}
  end

  def handle_info(:flush, _state) do
    {:ok, buffer} = Collector.flush_buffer()
    idempotency_key = idempotency_key(12)

    schedule_next_flush()

    Task.start(fn ->
      retry with: exponential_backoff() |> expiry(@backend_expiry), atoms: [:retry] do
        forward_buffer(buffer, idempotency_key)
      after
        result -> result
      else
        {:error, message} ->
          Logger.error(message)
      end
    end)

    {:noreply, []}
  end

  defp forward_buffer(%{counts: counts}, _key) when counts == %{} do
    Logger.debug("Nothing to forward")

    {:ok}
  end

  defp forward_buffer(buffer, idempotency_key) do
    HttpBackend.forward(buffer, idempotency_key)
  end

  defp schedule_next_flush do
    Process.send_after(self(), :flush, Config.find(:flush_interval_ms))
  end

  defp idempotency_key(length) do
    length
    |> :crypto.strong_rand_bytes()
    |> Base.url_encode64()
    |> binary_part(0, length)
  end
end
