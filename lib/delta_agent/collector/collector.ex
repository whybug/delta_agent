defmodule DeltaAgent.Collector do
  @moduledoc """
  Collects batches of operation usages.

  A forwarder can flush the collector to get a batch and send
  that to a backend.
  """
  require Logger
  use GenServer, restart: :permanent

  alias DeltaAgent.Operation
  alias DeltaAgent.Collector.{Aggregate, Batch}

  def start_link do
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

  def flush do
    batch =
      Batch.new(
        operations: Enum.into(:ets.tab2list(:operations), %{}),
        aggregates: Enum.into(:ets.tab2list(:aggregates), %{}),
        usages:
          Enum.reduce(:ets.tab2list(:usages), %{}, fn {key, [value]}, acc ->
            Map.update(acc, key, [value], &[value | &1])
          end)
      )

    # todo: Is it worth to delete those? Might not be needed
    :ets.delete_all_objects(:operations)
    :ets.delete_all_objects(:aggregates)

    # todo: Figure out how to prevent possible data loss between tab2list
    # and delete_all_objects. Probably delete object (returns it) one by one.
    :ets.delete_all_objects(:usages)

    {:ok, batch}
  end

  defp insert(%Operation{} = operation) do
    aggregate = Aggregate.from(operation)

    :ets.insert_new(:operations, {operation.hash, operation.body})
    :ets.insert_new(:aggregates, {aggregate.hash, aggregate})
    :ets.insert(:usages, {aggregate.hash, [{operation.timestamp, operation.metadata}]})

    {:ok}
  end

  defp init_ets do
    # Operations are buffered in ETS, an in-memory key/value store.
    ets_options = [
      :named_table,
      # all processes can read and write
      :public,
      read_concurrency: true,
      write_concurrency: true
    ]

    :ets.new(:operations, [:set | ets_options])
    :ets.new(:aggregates, [:set | ets_options])

    # Usages are stored as a list of timestamps (+ metadata).
    # There can be multiple entries with the same timestamp.
    :ets.new(:usages, [:duplicate_bag | ets_options])
  end
end
