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
    dockerfile_path =
      case System.get_env("TMPDIR") do
        nil -> "/tmp"
        defined -> "#{defined}"
      end

    dockerfile = ~s(FROM alpine:latest\nEXPOSE 80/tcp\nCMD ["sleep","100"]\n)
    File.write!("#{dockerfile_path}/divo.dockerfile", dockerfile)

    compose = %{
      version: "3.4",
      services: %{
        custom_app: %{
          build: %{
            context: "#{dockerfile_path}",
            dockerfile: "#{dockerfile_path}/divo.dockerfile"
          }
        }
      }
    }

    TemporaryEnv.put :divo, :divo, compose do
      Divo.Compose.run()

      {containers, _} = System.cmd("docker", ["ps", "-a"], stderr_to_stdout: true)
      assert String.contains?(containers, "divo_custom_app_1") == true

      Divo.Compose.kill()
    end
  end
end
