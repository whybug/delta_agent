defmodule DeltaAgent.Operation do
  @derive Jason.Encoder
  @enforce_keys [:hash, :body, :timestamp]
  defstruct [:hash, :body, :timestamp, metadata: []]

  def decode(data) do
    case Jason.decode(data) do
      {:ok, parsed} ->
        {:ok, map(parsed)}

      {:error, error} ->
        {:error, :parse, error}
    end
  end

  defp map(parsed) do
    %__MODULE__{
      hash: hash(parsed["body"]),
      body: parsed["body"],
      metadata: parsed["metadata"] || [],
      timestamp: :os.system_time(:seconds)
    }
  end

  defp hash(graphql) do
    :crypto.hash(:sha256, graphql)
    |> Base.encode16()
    |> String.downcase()
  end
end
