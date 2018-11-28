defmodule DeltaAgent.Operation do
  @moduledoc """
  Data structure of an operation.

  Either a hash or a body is needed to identify the operation.
  Also a schema in form of a schema version needs to be passed in.
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

  defp validate(%{"timestamp" => timestamp}) when timestamp < 1_543_397_551,
    do: {:error, "Timestamp '#{timestamp}' should be realistic"}

  defp validate(%{"schema" => schema}) when schema == "" or is_nil(schema),
    do: {:error, "'Schema' property is empty"}

  defp validate(%{"body" => body, "schema" => _schema} = data) when body != "" and not is_nil(body),
    do: {:ok, data}

  defp validate(%{"hash" => hash, "schema" => _schema} = data) when hash != "" and not is_nil(hash),
    do: {:ok, data}

  defp validate(_), do: {:error, "Please provide a 'body' or 'hash' and a 'schema' property"}

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
