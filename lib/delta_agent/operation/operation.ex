defmodule DeltaAgent.Operation do
  @derive Jason.Encoder
  @enforce_keys [:hash, :body, :timestamp]
  defstruct [:hash, :body, :timestamp, metadata: []]

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

  defp validate(%{"body" => _body} = data), do: {:ok, data}
  defp validate(_), do: {:error, "Please provide a 'body' property"}

  defp map(data) do
    {:ok,
     %__MODULE__{
       hash: hash(data["body"]),
       body: data["body"],
       metadata: data["metadata"] || [],
       timestamp: :os.system_time(:seconds)
     }}
  end

  defp hash(graphql) do
    :sha256
    |> :crypto.hash(graphql)
    |> Base.encode16()
    |> String.downcase()
  end
end
