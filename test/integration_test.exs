defmodule IntegrationAllTest do
  use ExUnit.Case
  use Divo

  test "the full dependency stack is stood up" do
    {containers, _} = System.cmd("docker", ["ps", "-a"], stderr_to_stdout: true)

    assert String.contains?(containers, "divo_busybox_1")
  end
end

defmodule IntegrationPartialTest do
  use ExUnit.Case
  use Divo, services: [:alpine]

  test "only specified parts of the stack are stood up" do
    {containers, _} = System.cmd("docker", ["ps", "-a"], stderr_to_stdout: true)

    assert String.contains?(containers, "divo_busybox_1") == false
    assert String.contains?(containers, "divo_alpine_1") == true
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
      assert String.contains?(containers, "divo_custom_app_1") == true

      Divo.Compose.kill()
    end
  end
end

defmodule IntegrationLogTest do
  use ExUnit.Case
  import ExUnit.CaptureLog
  require TemporaryEnv

  test "compose files with health check wait until healthy" do
    compose = "test/support/sample-compose.yaml"

    TemporaryEnv.put :divo, :divo, compose do
      output = fn ->
        Divo.Compose.run()
      end

      assert capture_log(output) =~ "is healthy..."
      assert capture_log(output) =~ "ready!"

      Divo.Compose.kill()
    end
  end
end
