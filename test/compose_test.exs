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
      System.cmd("docker-compose", ["--file", "/tmp/divo.compose", "up", "--detach"], stderr_to_stdout: true),
      once()
    )
  end

  test "docker run command with bad exit is raised as an error" do
    Divo.Compose.run()

    error_message = "Failed to get authorization token: NoCredentialProviders: no valid providers in chain. Deprecated."

    allow(Divo.Validate.validate(any()), return: :ok)

    allow(System.cmd(any(), any(), any()),
      return: {error_message, 1}
    )

    assert_raise RuntimeError, "Docker Compose exited with code: 1. " <> error_message, fn ->
      Divo.Compose.run()
    end
  end

  test "docker stop command called with expected arguments" do
    :ok = Divo.Compose.stop()

    assert_called(
      System.cmd("docker-compose", ["--file", "/tmp/divo.compose", "stop"], stderr_to_stdout: true),
      once()
    )
  end

  test "docker stop and rm commands called with expected arguments on kill" do
    :ok = Divo.Compose.kill()

    assert_called(
      System.cmd("docker-compose", ["--file", "/tmp/divo.compose", "down"], stderr_to_stdout: true),
      once()
    )
  end
end
