defmodule DeltaAgent.Config do
  def find(key) do
    Application.get_env(:delta_agent, key)
  end

  def validate() do
    api_key = find(:api_key)

    case api_key do
      nil ->
        {:error, "API key is not set"}

      "" ->
        {:error, "API key is empty"}

      _ ->
        {:ok}
    end
  end
end
