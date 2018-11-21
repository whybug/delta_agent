defmodule DeltaAgent.Collector do
  @moduledoc """
  Collects batches of data grouped by operation.

  A forwarder can pick up the data and send it to a backend when needed.
  If that doesn't happen, the data will be discarded after reaching a max size.
  """
  require Logger
  use GenServer, restart: :permanent

  alias DeltaAgent.Operation

  def start_link() do
    GenServer.start_link(__MODULE__, [])
  end

  def init(_state) do
    init_ets()

    {:ok, []}
  end

  def collect(data) do
    with {:ok, operation} <- Operation.decode(data),
         {:ok} <- insert(operation) do
      {:ok}
    else
      {:error, :decode, message} ->
        Logger.warn("Parsing failed", data: data, message: message)
        {:error, "#{message}: #{data}"}

      {:error, message} ->
        Logger.warn("Collect failed", data: data, message: message)
        {:error, message}
    end
  end

  def flush_buffer() do
    buffer = %{
      operations: Enum.into(:ets.tab2list(:operations), %{}),
      counts: Enum.into(:ets.tab2list(:operation_counts), %{})
    }

    :ets.delete_all_objects(:operations)
    :ets.delete_all_objects(:operation_counts)

    {:ok, buffer}
  end

  defp insert(%Operation{} = operation) do
    :ets.insert(:operations, {operation.hash, operation})
    :ets.update_counter(:operation_counts, operation.hash, {2, 1}, {operation.hash, 0})

    {:ok}
  end

  defp init_ets() do
    # Operations are buffered in ETS, an in-memory key/value store.
    ets_options = [
      :set,
      :named_table,
      # all processes can read and write
      :public,
      read_concurrency: true,
      write_concurrency: true
    ]

    :ets.new(:operations, ets_options)
    :ets.new(:operation_counts, ets_options)
  end
end
