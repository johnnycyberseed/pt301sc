defmodule Pt301sc.MixProject do
  use Mix.Project

  def project do
    [
      app: :pt301sc,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Pt301sc.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # Web server dependencies
      {:plug, "~> 1.14"},
      {:bandit, "~> 1.0"},
      {:jason, "~> 1.4"} # For JSON handling
    ]
  end
end
