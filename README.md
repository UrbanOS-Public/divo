# Divo

Docker Integration, Validation, and Operation framework for integration testing
Elixir apps via docker services, orchestrated via custom mix tasks.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `divo` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:divo, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/divo](https://hexdocs.pm/divo).

## Usage

Define services in your mix configuration file (typically under a `config/integration.exs` file)
to define the dockerized service(s) you want to run as a dependency of your Elixir app.

```
config :myapp,
  divo: [
    kafka: %{
      image: "kafka:latest",
      env: [
        val1: "foo",
        val2: "bar"
      ],
      ports: [
        {9092, 9092}
      ]
    },
    redis: %{
      image: "redis:1.2",
      command: "redis start --foreground",
      ports: [
        {6379, 6379}
      ],
      volumes: [
        {"/tmp", "/opt/redis"}
      ]
    }
  ]
```
=======
# divo
A library for easily constructing integration service dependencies in docker and orchestrating with mix
