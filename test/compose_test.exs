defmodule Divo.ComposeTest do
  use ExUnit.Case, async: false

  import Mock

  setup_with_mocks([
    {System, [:passthrough], [cmd: fn(_, _) -> {"", 0} end]},
    {System, [], [cmd: fn(_, _, _) -> {"", 0} end]},
    {System, [], [get_env: fn(_) -> "/tmp" end]}
  ]) do
    {:ok, foo: "bar"}
  end

  test "docker run command called with expected arguments" do
    Divo.Compose.run()

    assert_called(
      System.cmd("docker-compose", ["--file", "/tmp/divo.compose", "up", "--detach"], stderr_to_stdout: true)
    )
  end

  test "docker run command with bad exit is raised as an error" do
    Divo.Compose.run()

    error_message = "Failed to get authorization token: NoCredentialProviders: no valid providers in chain. Deprecated."

    with_mocks(
      [
        {Divo.Validate, [], [validate: fn(_) -> :ok end]},
        {System, [], [cmd: fn(_, _, _) -> {error_message, 1} end]},
        {System, [], [get_env: fn(_) -> "/tmp" end]}
      ]
    ) do
      assert_raise RuntimeError, "Docker Compose exited with code: 1. " <> error_message, fn ->
        Divo.Compose.run()
      end
    end
  end

  test "docker stop command called with expected arguments" do
    :ok = Divo.Compose.stop()

    assert_called(
      System.cmd("docker-compose", ["--file", "/tmp/divo.compose", "stop"], stderr_to_stdout: true)
    )
  end

  test "docker stop and rm commands called with expected arguments on kill" do
    :ok = Divo.Compose.kill()

    assert_called(
      System.cmd("docker-compose", ["--file", "/tmp/divo.compose", "down"], stderr_to_stdout: true)
    )
  end
end
