[![Hex.pm Version](http://img.shields.io/hexpm/v/divo.svg?style=flat)](https://hex.pm/packages/divo)

# Getting Started

Easily run Elixir integration tests with docker-compose.
Provide Divo with docker-compose configuration, add `use Divo` to your integration tests, and run with `mix test.integration`.

## Installation

The package can be installed by adding `divo` to your list of dependencies in `mix.exs`:

```elixir
def deps() do
  [
    {:divo, "~> 1.3.1", only: [:dev, :integration]}
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
      interval: 5s
      timeout: 10s
      retries: 3
```

#### Method 2 - Pre-existing module
In your mix file, include the additional dependency
```elixir
#mix.exs
def deps() do
  [
    {:divo, "~> 1.3.1", only: [:dev, :integration]},
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

##### Known Modules:
- [Kafka](https://github.com/smartcitiesdata/divo_kafka)
- [Redis](https://github.com/smartcitiesdata/divo_redis)
- [Machinebox](https://github.com/joshrotenberg/divo_machinebox)

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

NOTE: Divo will start and stop docker-compose for every integration test module, unless the "DIVO_DOWN" environment variable is set to "DISABLED".

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

## Use Divo for the entire test suite
In your integration or test suite's `test_helper.exs` file add `Divo.Suite.start()` before `ExUnit.start()`
Example:
```elixir
Divo.Suite.start()
...
ExUnit.start()
```

This will make Divo stand up dockers that last the entire run of the test suite (or just a few modules or tests if you specified them in your `mix test.integration` command). It will wire itself up to tear down the dockers if in cases where the tests fail to compile.

Ideally, you will want to NOT have `use Divo` in your tests. However, if you leave `use Divo` in for all of the tests, and still add the start to your `test_helper.exs` the tests will still run as expected, with an additional docker start and stop wrapped around the whole run.

The `Divo.Suite.start` function takes all of the options that `use Divo` does plus a few extras for controlling where the final docker cleanup occurs:
- `auto_cleanup?` - whether or not to cleanup dockers on program exit. Defaults to `true`

Whether or not you choose to let it cleanup after itself, `Divo.Suite.start` will return a zero-arity cleanup hook that you can call when you want to explicitly cleanup the dockers.
```elixir
Divo.Suite.start()
|> on_exit()
```

## Running Integration Tests

Integration tests are executed by running:

`mix test.integration`

## License
Released under [Apache 2 license](https://github.com/smartcitiesdata/divo/blob/master/LICENSE).
