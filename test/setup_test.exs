### These tests rely on the configuration in test.exs
defmodule IntegrationAllTest do
  use ExUnit.Case
  use Divo.Setup

  test "test that the environment is stood up" do
    containers =
      'docker ps -a | grep divo-busybox'
      |> cmd_wrapper()

    assert String.contains?(containers, "busybox:latest")
  end

  defp cmd_wrapper(cmd), do: cmd |> :os.cmd() |> to_string
end

defmodule IntegrationPartialTest do
  use ExUnit.Case
  use Divo.Setup, services: [:alpine]

  test "test that only part of the environment is stood up" do
    containers =
      'docker ps -a | grep divo-busybox'
      |> cmd_wrapper()

    assert String.contains?(containers, "busybox:latest") == false
  end

  defp cmd_wrapper(cmd), do: cmd |> :os.cmd() |> to_string
end
