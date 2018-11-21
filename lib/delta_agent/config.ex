defmodule DeltaAgent.Config do
  def find(key) do
    Application.get_env(:delta_agent, key)
  end

  def validate do
    {:ok}
  end
end
