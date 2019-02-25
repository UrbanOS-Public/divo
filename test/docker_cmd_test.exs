defmodule Divo.RunCmdTest do
  use ExUnit.Case
  use Placebo

  setup do
    allow(System.cmd(any(), any(), any()), return: {"", 0})
    :ok
  end

  test "docker run command called with expected arguments" do

    parameters = ["-p 90:90", "derp:latest", "rm -rf all.all"]
    Divo.DockerCmd.run(parameters)

    assert_called(
      System.cmd("docker", ["run", "-p 90:90", "derp:latest", "rm -rf all.all"], [stderr_to_stdout: true]),
      once()
    )
  end

  test "docker stop command called with expected arguments" do
    service_name = "divo-derp"
    Divo.DockerCmd.stop(service_name)

    assert_called(
      System.cmd("docker", ["stop", "divo-derp"], [stderr_to_stdout: true]),
      once()
    )
  end

  test "docker stop and rm commands called with expected arguments on kill" do
    service_name = "divo-derp"
    Divo.DockerCmd.kill(service_name)

    assert_called(
      System.cmd("docker", ["rm", "-f", "divo-derp"], [stderr_to_stdout: true]),
      once()
    )
  end
end
