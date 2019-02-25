defmodule Divo.DockerCmd do
  def run(parameters) do
    {parameters, System.cmd("docker", ["run" | parameters], stderr_to_stdout: true)}
  end

  @spec stop(binary()) :: {any(), non_neg_integer()}
  def stop(name) do
    System.cmd("docker", ["stop", name], stderr_to_stdout: true)
  end

  def kill(name) do
    System.cmd("docker", ["rm", "-f", name], stderr_to_stdout: true)
  end
end
