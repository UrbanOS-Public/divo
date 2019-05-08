defmodule Divo.MixProject do
  use Mix.Project

  def project do
    [
      app: :divo,
      version: "1.1.4",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      docs: docs(),
      description: description(),
      source_url: "https://github.com/smartcitiesdata/divo"
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:credo, "~> 1.0", only: [:dev, :test], runtime: false},
      {:jason, "~> 1.1"},
      {:placebo, "~> 1.2", only: [:dev, :test]},
      {:ex_doc, "~> 0.19", only: :dev},
      {:patiently, "~> 0.2"},
      {:temporary_env, "~> 2.0", only: [:dev, :test]}
    ]
  end

  defp description do
    "A library for easily constructing integration service dependencies in docker and orchestrating with mix."
  end

  defp docs do
    [
      main: "readme",
      source_url: "https://github.com/smartcitiesdata/divo",
      extras: [
        "README.md",
        "docs/docker-compose.md",
        "docs/additional-configuration.md"
      ]
    ]
  end

  defp package do
    [
      maintainers: ["smartcitiesdata"],
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => "https://github.com/smartcitiesdata/divo"}
    ]
  end
end
