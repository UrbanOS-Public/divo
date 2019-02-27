defmodule Divo.DockerCmd do
  @moduledoc """
  Implements the  basic docker-equivalent commands for running from
  your mix tasks. Run creates and starts the container services. Stop
  will only stop the containers but leave them present on the system
  for debugging and introspection if needed. Kill will stop any running
  containers and remove all containers regardless of their current state.

  These operations only apply to services managed by Divo, i.e. defined in
  your Mix.env file under the :myapp, :divo key.
  """

  def run(parameters) do
    {parameters, System.cmd("docker", ["run", "-d"] ++ parameters, stderr_to_stdout: true)}
  end

  def stop(name) do
    System.cmd("docker", ["stop", name], stderr_to_stdout: true)
  end

  def kill(name) do
    System.cmd("docker", ["rm", "-f", name], stderr_to_stdout: true)
  end
end
