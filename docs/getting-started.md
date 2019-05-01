# Basic Usage

Incorporating Divo into your integration tests is as simple providing a docker-compose
through your testing configuration and adding `use Divo` to your test module.

## Configure docker-compose

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

## Add Divo

In each integration module add:

`use divo`

Divo will then take care of running docker-compose up before running your tests
and then run docker-compose down after they've completed.

## Run Integration

To run all integration tests using Divo, run the mix task:

`mix test.integration`
