defmodule DeltaAgent.Operation do
  @moduledoc """
  Data structure of an operation.

  Either a hash or a body is needed to identify the operation.
  """

  @derive Jason.Encoder
  @enforce_keys [:hash, :body, :schema, :timestamp]
  defstruct [
    :hash,
    :body,
    :schema,
    :timestamp,
    :client_os,
    :client_version,
    metadata: []
  ]

  def decode(data) do
    with {:ok, parsed} <- Jason.decode(data),
         {:ok, validated} <- validate(parsed),
         {:ok, mapped} <- map(validated) do
      {:ok, mapped}
    else
      {:error, _error = %Jason.DecodeError{}} ->
        {:error, :decode, "Invalid JSON"}

      {:error, message} ->
        {:error, :decode, message}
    end
  end

  defp validate(%{"timestamp" => timestamp} = data) when timestamp < 1_543_397_551,
    do: {:error, "Timestamp '#{timestamp}' should be realistic"}

  defp validate(%{"schema" => nil} = data), do: {:error, "Please provide a 'schema' property"}
  defp validate(%{"body" => _body, "schema" => _schema} = data), do: {:ok, data}
  defp validate(%{"hash" => _hash, "schema" => _schema} = data), do: {:ok, data}
  defp validate(_), do: {:error, "Please provide a 'body' or 'hash' property"}

  defp map(data) do
    {:ok,
     %__MODULE__{
       hash: data["hash"] || hash(data["body"]),
       body: data["body"],
       schema: data["schema"],
       metadata: data["metadata"] || [],
       timestamp: data["timestamp"] || :os.system_time(:seconds),
       client_os: data["client"]["os"],
       client_version: data["client"]["version"]
     }}
  end

  defp hash(graphql) do
    :sha256
    |> :crypto.hash(graphql)
    |> Base.encode16()
    |> String.downcase()
  end
end
