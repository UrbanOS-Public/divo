# Additional Configuration

## Divo Wait

Sometimes services take a moment to start up and Elixir apps tend to start (and attempt to run their tests)
too quickly for their dependencies to be ready. For those situations, add the key `:divo_wait` to the app config that defines a wait period in milliseconds and a maximum number of tries to check for the containerized services to be healthy before aborting. In order for the wait to hold execution for the containers to register as healthy with the Docker engine, a [healthcheck](https://docs.docker.com/compose/compose-file/#healthcheck) must be built into the Dockerfile for the image or defined in the compose file.

```elixir
config :myapp,
  divo: "test/support/docker-compose.yaml",
  divo_wait: [dwell: 700, max_tries: 50]
```
