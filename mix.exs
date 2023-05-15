defmodule Divo.MixProject do
  use Mix.Project

  def project do
    [
      app: :divo,
      version: "2.0.0",
      elixir: "~> 1.14.4",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      docs: docs(),
      description: description(),
      source_url: "https://github.com/smartcitiesdata/divo",
      dialyzer: [plt_add_apps: [:mix], plt_file: {:no_warn, "cache/dialyzer.plt"}]
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
      {:jason, "~> 1.4"},
      {:patiently, "~> 0.2"},
      {:placebo, "~> 2.0", only: :test},
      {:temporary_env, "~> 2.0", only: :test},
      {:credo, "~> 1.7", only: :dev, runtime: false},
      {:dialyxir, "~> 1.3", only: :dev, runtime: false},
      {:ex_doc, "~> 0.29", only: :dev, runtime: false}
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
