defmodule DeltaAgent.MixProject do
  use Mix.Project

  def project do
    [
      app: :delta_agent,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {DeltaAgent, []},
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:benchee, "~> 0.11", only: :dev},
      {:distillery, "~> 2.0"},
      {:httpoison, "~> 1.0"},
      {:jason, "~> 1.1"},
      {:retry, "~> 0.10"}
    ]
  end
end
