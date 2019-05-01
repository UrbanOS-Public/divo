# Divo

Docker Integration, Validation, and Operation framework for integration testing
Elixir apps via docker services, orchestrated via custom mix tasks.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `divo` to your list of dependencies in `mix.exs`:

```elixir
def deps() do
  [
    {:divo, "~> 1.1.0", only: [:dev, :integration], organization: "smartcolumbus_os"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/divo](https://hexdocs.pm/divo).

## Usage

Define services in your mix configuration file (typically under a `config/integration.exs` file)
to define the dockerized service(s) you want to run as a dependency of your Elixir app. Define divo config in one of three ways"

### Method 1 - Pre-existing definition from a behaviour-derived module stack
In your mix file, include the additional dependency
```elixir
def deps() do
  [
    {:divo, "~> 1.1.0", only: [:dev, :integration], organization: "smartcolumbus_os"},
    {:divo_redis, "~> 0.1.0", only: [:dev, :integration], organization: "smartcolumbus_os"}
  ]
```
And in your environment config, include the imported dependency module(s) as a list of tuples along with any environment variables the stack takes as a keyword list
```elixir
config :myapp,
  divo: [
    {DivoRedis, [initial_key: "myapp:secret"]}
  ]
```

### Method 2 - Pre-existing definition from a supplied compose file on the file system
In your environment config, include the path to the yaml- or json-formatted compose file
```elixir
config :myapp,
  divo: "test/support/docker-compose.yaml
```

### Method 3 - Define the custom compose file as an elixir map directly in your config
```elixir
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

## Compose File Definition

Docker Compose instructions are passed to the `docker-compose` binary on your Docker engine host as either a yaml- or json-formatted document with maps defining the container services, networks, and volumes needed to run the services as an interconnected stack of components (as well as a compose file version). The keys in the underlying map structure generally have a one-to-one relationship to the various arguments available to the `docker run` command.

For more details, see the full [docker compose documentation](https://docs.docker.com/compose/compose-file/)

## Divo Wait

Sometimes services take a moment to start up and Elixir apps tend to start (and attempt to run their tests)
too quickly for their dependencies to be ready. For those situations, add the key `:divo_wait` to the app config that defines a wait period in milliseconds and a maximum number of tries to check for the containerized services to be healthy before aborting. In order for the wait to hold execution for the containers to register as healthy with the Docker engine, a [healthcheck](https://docs.docker.com/compose/compose-file/#healthcheck) must be built into the Dockerfile for the image or defined in the compose file.

```elixir
config :myapp,
  divo: "test/support/docker-compose.yaml",
  divo_wait: [dwell: 700, max_tries: 50]
```


## License
Released under [Apache 2 license](https://github.com/SmartColumbusOS/divo/blob/master/LICENSE).
