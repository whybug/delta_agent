defmodule DeltaAgent.Collector.Aggregate do
  @moduledoc """
  Data structure to store repeating values per operations.
  """

  alias DeltaAgent.Operation

  @derive Jason.Encoder
  @enforce_keys [:hash, :operation_hash, :schema]
  defstruct [
    :hash,
    :operation_hash,
    :schema,
    :client_os,
    :client_version
  ]

  def from(operation = %Operation{}) do
    %__MODULE__{
      hash: hash_operation(operation),
      operation_hash: operation.hash,
      schema: operation.schema,
      client_os: operation.client_os,
      client_version: operation.client_version
    }
  end

  def hash_operation(operation = %Operation{}) do
    hash_list([
      operation.hash,
      operation.schema,
      operation.client_os,
      operation.client_version
    ])
  end

  defp hash_list(list) do
    list
    |> Enum.filter(&(!is_nil(&1)))
    |> List.to_string()
    |> hash
  end

  defp hash(data) do
    :sha256
    |> :crypto.hash(data)
    |> Base.encode16()
    |> String.downcase()
  end
end
