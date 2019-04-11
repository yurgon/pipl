defmodule Pipl.MixProject do
  use Mix.Project

  def project do
    [
      app: :pipl,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      escript: [main_module: Pipl],
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :xlsxir]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:httpoison, "~> 1.4"},
      {:remix, "~> 0.0.1", only: :dev},
      {:xlsxir, github: "jsonkenl/xlsxir"},
      {:poison, "~> 3.1"},
      {:csv, "~> 2.3"}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
    ]
  end
end
