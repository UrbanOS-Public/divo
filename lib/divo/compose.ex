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
  alias Divo.{File, Helper}

  def run(opts \\ []) do
    ["up", "--detach"] ++ opts
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
    app = Helper.fetch_name()

    file =
      Helper.fetch_config()
      |> File.ensure_file()

    args =
      ["--project-name", app, "--file", file] ++ [action]
      |> List.flatten()

    System.cmd("docker-compose", args, stderr_to_stdout: true)
  end

  defp await() do
    fetch_containers
    |> Enum.filter(&health_defined/1)
    |> Enum.map(&await_healthy/1)
  end

  defp await_healthy(container) do
    Patiently.wait_for!(
      check_health(container),
      dwell: 500,
      max_retries: 50
    )
  end

  defp check_health(container) do
    fn ->
      Logger.info("Checking #{container} is healthy...")
      health_status(container)
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
    {containers, _} = System.cmd("docker", ["ps", "--quit"])

    String.split(containers, "\n", trim: true)
  end

  defp health_defined?(container) do
    {health, _} = System.cmd("docker", ["inspect", "--format", "{{json .State.Health}}", container])

    Jason.decode!(health)
    |> case do
      nil -> false
      _   -> true
    end
  end

  defp health_status(container) do
    {status, _} = System.cmd("docker", ["inspect", "--format", "{{json .State.Health.Status}}", container])

    Jason.decode!(status)
  end
end
