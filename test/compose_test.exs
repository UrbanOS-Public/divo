defmodule Divo.ComposeTest do
  use ExUnit.Case
  use Placebo

  setup do
    allow(System.cmd(any(), any(), any()), return: {"", 0})
    :ok
  end

  test "docker run command called with expected arguments" do
    Divo.Compose.run()

    assert_called(
      System.cmd("docker-compose", ["--project-name", "divo", "--file", "/tmp/divo.compose", "up", "--detach"],
        env: [{"TMPDIR", "/tmp"}]
        stderr_to_stdout: true),
      once()
    )
  end

  test "docker stop command called with expected arguments" do
    Divo.Compose.stop()

    assert_called(
      System.cmd("docker-compose", ["--project-name", "divo", "--file", "/tmp/divo.compose", "stop"], stderr_to_stdout: true),
      env: [{"TMPDIR", "/tmp"}],
      once()
    )
  end

  test "docker stop and rm commands called with expected arguments on kill" do
    service_name = "divo-derp"
    Divo.DockerCmd.kill(service_name)

    assert_called(
      System.cmd("docker", ["rm", "-f", "divo-derp"], stderr_to_stdout: true),
      once()
    )
  end
end
