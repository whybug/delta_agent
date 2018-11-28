defmodule DeltaAgent.Collector.Batch do
  @moduledoc """
  Data structure holding aggregated data that can be forwarded.
  """

  @derive Jason.Encoder
  @enforce_keys [:idempotency_key, :operations, :aggregates, :usages]
  defstruct [
    :idempotency_key,
    :operations,
    :aggregates,
    :usages
  ]

  def new(attributes) do
    struct!(__MODULE__, [{:idempotency_key, idempotency_key(16)} | attributes])
  end

  defp idempotency_key(length) do
    length
    |> :crypto.strong_rand_bytes()
    |> Base.url_encode64()
    |> binary_part(0, length)
  end
end
