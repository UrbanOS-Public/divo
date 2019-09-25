defmodule IntegrationAllTest do
  use Divo.Case

  test "the full dependency stack is stood up" do
    {containers, _} = System.cmd("docker", ["ps", "-a"], stderr_to_stdout: true)

    assert String.contains?(containers, "busybox_1")
  end
end

defmodule IntegrationPartialTest do
  use ExUnit.Case
  use Divo, services: [:alpine]

  test "only specified parts of the stack are stood up" do
    {containers, _} = System.cmd("docker", ["ps", "-a"], stderr_to_stdout: true)

    assert String.contains?(containers, "busybox_1") == false
    assert String.contains?(containers, "alpine_1") == true
  end
end

defmodule IntegrationBuildTest do
  use ExUnit.Case
  require TemporaryEnv

  test "compose files with build instructions will build and run" do
    compose = "test/support/build-compose.yaml"

    TemporaryEnv.put :divo, :divo, compose do
      Divo.Compose.run()

      {containers, _} = System.cmd("docker", ["ps", "-a"], stderr_to_stdout: true)
      assert String.contains?(containers, "support_custom_app_1") == true

      Divo.Compose.kill()
    end
  end
end

defmodule IntegrationLogTest do
  use ExUnit.Case
  import ExUnit.CaptureLog
  require TemporaryEnv

  test "compose file with health check wait until healthy" do
    compose = "test/support/sample-compose.yaml"

    TemporaryEnv.put :divo, :divo, compose do
      output = fn ->
        Divo.Compose.kill()
        Divo.Compose.run()
      end

      logs = capture_log(output)

      healthy_checks =
        logs
        |> check_logs_for("healthy...")

      ready_checks =
        logs
        |> check_logs_for("ready!")

      assert healthy_checks >= 5
      assert ready_checks == 1

      Divo.Compose.kill()
    end
  end

  test "compose file without check does not wait to start" do
    compose = "test/support/build-compose.yaml"

    TemporaryEnv.put :divo, :divo, compose do
      output = fn ->
        Divo.Compose.kill()
        Divo.Compose.run()
      end

      logs = capture_log(output)

      healthy_checks =
        logs
        |> check_logs_for("healthy...")

      ready_checks =
        logs
        |> check_logs_for("ready!")

      assert healthy_checks == 0
      assert ready_checks == 0

      Divo.Compose.kill()
    end
  end

  defp check_logs_for(log, word) do
    log
    |> String.split()
    |> Enum.count(fn chunk ->
      String.contains?(chunk, word)
    end)
  end
end
