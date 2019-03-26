# Divo

Docker Integration, Validation, and Operation framework for integration testing
Elixir apps via docker services, orchestrated via custom mix tasks.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `divo` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:divo, "~> 1.0.2", only: [:dev, :integration], organization: "smartcolumbus_os"}
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

## Options

These options can be added to a service definition's config to customize it.

* `image` - the name of the docker image to be started. This is the only required key.

* `env` - a keyword list of environment variables to be set in the started container. Each element is translated to a `--env=VARIABLE=VALUE` option in the run command.

* `ports` - a list of ports to be exposed to the system. Each element is translated to a `--publish=LOCAL:REMOTE` option in the run command.

* `volumes` - a list of tuples of the format `{local_volume, remote_volume}`. Each element is translated to a `--volume=LOCAL:REMOTE` option in the run command

* `command` - a command to be run in the created container. Does not support piping `ls | grep logs` or additional commands `ls && cd ..`

* `net` - a different service defined by Divo that this container needs to be linked to. Translated to `--network=container:APP_NAME-SERVICE_NAME`

* `additional_opts` - a list of strings representing extra options to be passed to `docker run`. This allows for options not explicitly supported by Divo to be used if needed. Any option defined in the (Docker Run)[https://docs.docker.com/engine/reference/commandline/run/] docs can be used.

* `wait_for` - see [Wait For]()


## Wait For

Sometimes services take a moment to start up and Elixir apps tend to start (and attempt to run their tests)
too quickly for their dependencies to be ready. For those situations, add the key `:wait_for` to the map
that defines each services that will need to be fully initialized before accepting interactions from your
service-under-test. The value of that key should be a map containing a log message to expect from the service
indicating it is ready to accept requests, a interval in seconds to wait between log parsing attempts, and a
number of retries to make the attempt.

```
...
  kafka: %{
    image: ...,
    env: [
      ...
    ],
    wait_for: %{
        log: "home",
        dwell: 400,
        max_retries: 10
      }
  }
```
