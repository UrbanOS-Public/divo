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
## Wait For

Sometimes services take a moment to start up and Elixir apps tend to start (and attempt to run their tests)
too quickly for their dependencies to be ready. For those situations, add the key `:wait_for` to the map
that defines each services that will need to be fully initialized before accepting interactions from your
service-under-test. The value of that key should be a tuple containing a log message to expect from the service
indicating it is ready to accept requests, a interval in seconds to wait between log parsing attempts, and a
number of retries to make the attempt.

```
...
  kafka: %{
    image: ...,
    env: [
      ...
    ],
    wait_for: {"I'm ready, boss", 500, 20}
  }
```
