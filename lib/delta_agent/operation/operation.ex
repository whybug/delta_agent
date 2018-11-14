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
      {:error, message} -> {:error, :decode, message}
    end
  end

  defp validate(%{"body" => body} = data), do: {:ok, data}
  defp validate(_), do: {:error, "Invalid data. Please provide a 'body' property."}

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
    :crypto.hash(:sha256, graphql)
    |> Base.encode16()
    |> String.downcase()
  end
end
