defmodule Divo.ComposeTest do
  use ExUnit.Case
  use Placebo

  setup do
    allow(System.cmd(any(), any()), meck_options: [:passthrough])
    allow(System.get_env(any()), return: "/tmp")
    allow(System.cmd(any(), any(), any()), return: {"", 0})
    :ok
  end

  test "docker run command called with expected arguments" do
    Divo.Compose.run()

    assert_called(
      System.cmd("docker-compose", ["--project-name", "divo", "--file", "/tmp/divo.compose", "up", "--detach"],
        stderr_to_stdout: true
      ),
      once()
    )
  end

  test "docker stop command called with expected arguments" do
    Divo.Compose.stop()

    assert_called(
      System.cmd("docker-compose", ["--project-name", "divo", "--file", "/tmp/divo.compose", "stop"],
        stderr_to_stdout: true
      ),
      once()
    )
  end

  test "docker stop and rm commands called with expected arguments on kill" do
    Divo.Compose.kill()

    assert_called(
      System.cmd("docker-compose", ["--project-name", "divo", "--file", "/tmp/divo.compose", "down"],
        stderr_to_stdout: true
      ),
      once()
    )
  end
end
