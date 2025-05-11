defmodule TitanicElixir.MixProject do
  use Mix.Project

  def project do
    [
      app: :titanic_elixir,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {TitanicElixir, []},
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:scholar, "~> 0.3.0"},
      {:exgboost, "~> 0.5.1"},
      {:exla, ">= 0.0.0"},
      {:explorer, "~> 0.10.0"},
      {:nx, "~> 0.9.0"}
    ]
  end
end
