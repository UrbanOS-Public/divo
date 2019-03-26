defmodule Divo.Compose do
  @moduledoc """
  Implements the  basic docker-compose commands for running from
  your mix tasks. Run creates and starts the container services. Stop
  will only stop the containers but leave them present on the system
  for debugging and introspection if needed. Kill will stop any running
  containers and remove all containers regardless of their current state.

  These operations only apply to services managed by Divo, i.e. defined in
  your Mix.env file under the :myapp, :divo key.
  """
  require Logger
  alias Divo.{File, Helper, Validate}

  def run(opts \\ []) do
    services = get_services(opts)

    (["up", "--detach"] ++ services)
    |> execute()

    await()
  end

  def stop() do
    execute("stop")
  end

  def kill() do
    execute("down")
  end

  defp execute(action) do
    file =
      Helper.fetch_config()
      |> File.ensure_file()

    args =
      (["--file", file] ++ [action])
      |> List.flatten()

    Validate.validate(file)

    System.cmd("docker-compose", args, stderr_to_stdout: true)
    |> log_compose()
  end

  defp log_compose({message, 0}), do: Logger.info(message)
  defp log_compose({message, code}), do: Logger.error("Docker Compose exited with code: #{code}. #{message}")

  defp get_services(opts) do
    case Keyword.get(opts, :services) do
      nil -> []
      defined -> Enum.map(defined, &to_string(&1))
    end
  end

  defp await() do
    fetch_containers()
    |> Enum.filter(&health_defined?/1)
    |> Enum.map(&await_healthy/1)
  end

  defp await_healthy(container) do
    wait_config =
      Helper.fetch_name()
      |> Application.get_env(:divo_wait, dwell: 500, max_tries: 10)

    dwell = Keyword.get(wait_config, :dwell)
    tries = Keyword.get(wait_config, :max_tries)

    Patiently.wait_for!(
      check_health(container),
      dwell: dwell,
      max_tries: tries
    )
  end

  defp check_health(container) do
    fn ->
      Logger.info("Checking #{container} is healthy...")

      container
      |> health_status()
      |> case do
        "healthy" ->
          Logger.info("Service #{container} ready!")
          true

        _ ->
          false
      end
    end
  end

  defp fetch_containers() do
    {containers, _} = System.cmd("docker", ["ps", "--quiet"])

    String.split(containers, "\n", trim: true)
  end

  defp health_defined?(container) do
    {health, _} = System.cmd("docker", ["inspect", "--format", "{{json .State.Health}}", container])

    health
    |> Jason.decode!()
    |> case do
      nil -> false
      _ -> true
    end
  end

  defp health_status(container) do
    {status, _} = System.cmd("docker", ["inspect", "--format", "{{json .State.Health.Status}}", container])

    Jason.decode!(status)
  end
end
