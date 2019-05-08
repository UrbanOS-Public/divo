[![Master](https://travis-ci.org/smartcitiesdata/divo.svg?branch=master)](https://travis-ci.org/smartcitiesdata/divo)
[![Hex.pm Version](http://img.shields.io/hexpm/v/divo.svg?style=flat)](https://hex.pm/packages/divo)

# Getting Started

Easily run Elixir integration tests with docker-compose.
Provide Divo with docker-compose configuration, add `use Divo` to your integration tests, and run with `mix test.integration`.

## Installation

The package can be installed by adding `divo` to your list of dependencies in `mix.exs`:

```elixir
def deps() do
  [
    {:divo, "~> 1.1.4", only: [:dev, :integration]}
  ]
end
```

The docs can be found at [https://hexdocs.pm/divo](https://hexdocs.pm/divo).

## Configuration

### Docker
Define services in your mix configuration file to define the dockerized service(s) you want to run as a dependency of your Elixir app.
Define divo config in one of the following three ways:

#### Method 1 - Compose file
In your config, include the path to the yaml or json-formatted compose file
```elixir
#config/config.exs
config :myapp,
  divo: "test/support/docker-compose.yaml,
  divo_wait: [dwell: 700, max_tries: 50]
```

```yaml
#test/support/docker-compose.yaml
version: '3'
services:
  redis:
    image: redis
    ports:
      - "6379:6379"
    healthcheck:
      test: ["CMD", "redis-cli", "PING"]
      interval: 5s,
      timeout: 10s,
      retries: 3
```

#### Method 2 - Pre-existing module
In your mix file, include the additional dependency
```elixir
#mix.exs
def deps() do
  [
    {:divo, "~> 1.1.4", only: [:dev, :integration]},
    {:divo_redis, "~> 0.1.0", only: [:dev, :integration]}
  ]
```
And in your config, include the imported dependency module(s) as a list of tuples along with any environment variables the stack takes as a keyword list
```elixir
#config/config.exs
config :myapp,
  divo: [
    {DivoRedis, [initial_key: "myapp:secret"]}
  ],
  divo_wait: [dwell: 700, max_tries: 50]
```

#### Method 3 - Elixir map
```elixir
#config/config.exs
config :myapp,
  divo: %{
    version: "3",
    services: %{
      redis: %{
        image: "redis:latest",
        ports: [
          "6379:6379"
        ],
        healthcheck: %{
          test: ["CMD", "redis-cli", "PING"],
          interval: "5s",
          timeout: "10s",
          retries: 3
        }
      }
    }
  },
  divo_wait: [dwell: 700, max_tries: 50]
```

### Split Unit and Integration Tests
You will need to move any existing unit tests into a sub directory.  We recommend the following structure:
```
myapp
  └── test
      ├── integration
      │   ├── myapp_test.exs
      │   └── test_helper.exs
      └── unit
          ├── module_a_test.exs
          ├── module_b_test.exs
          └── test_helper.exs
```
NOTE: `test_helper.exs` must be included in the root of both integration and unit tests.

### Test Paths
Add this to your mix.exs to ensure that your unit and integration tests run in isolation from each other.
```elixir
#mix.exs

def project do
  [
    # ...
    test_paths: test_paths(Mix.env())
  ]
end

# ...

defp test_paths(:integration), do: ["test/integration"]
defp test_paths(_), do: ["test/unit"]
```

### Use Divo in an Integration Test

In each integration module add:

`use Divo`

Divo will then take care of running `docker-compose up` before running your tests
and then run `docker-compose down` after they've completed.

NOTE: Divo will start and stop docker-compose for every integration test module.

Example Integration Test Module using [redix](https://hex.pm/packages/redix):
```elixir
defmodule MyAppTest do
  use ExUnit.Case
  use Divo

  test "persisting and reading from redis" do
    {:ok, conn} = Redix.start_link(host: "localhost", port: 6379)
    Redix.command(conn, ["SET", "mykey", "foo"])
    {:ok, result} = Redix.command(conn, ["GET", "mykey"])
    assert result === "foo"
  end
end
```

## Running Integration Tests

Integration tests are executed by running:

`mix test.integration`

## License
Released under [Apache 2 license](https://github.com/SmartColumbusOS/divo/blob/master/LICENSE).
