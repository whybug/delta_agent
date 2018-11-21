defmodule DeltaAgent.MixProject do
  use Mix.Project
  @version System.get_env("APP_VERSION") || "0.0.0"

  def project do
    [
      app: :delta_agent,
      version: @version,
      elixir: "~> 1.7",
      dialyzer: [
        flags: [:unmatched_returns, :error_handling, :race_conditions, :underspecs],
        ignore_warnings: "dialyzer.ignore-warnings"
      ],
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
      {:cowboy, "~> 2.5"},
      {:credo, "~> 0.9", only: [:dev, :test]},
      {:distillery, "~> 2.0"},
      {:httpoison, "~> 1.0"},
      {:jason, "~> 1.1"},
      {:plug, "~> 1.7"},
      {:plug_cowboy, "~> 2.0"},
      {:retry, "~> 0.10"}
    ]
  end
end
