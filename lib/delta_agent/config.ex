defmodule DeltaAgent.Config do
  @moduledoc """
  Access and validate config values.
  """

  def find(key) do
    Application.get_env(:delta_agent, key)
  end

  def validate do
    {:ok}
  end
end
