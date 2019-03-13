### These tests rely on the configuration in test.exs
defmodule IntegrationAllTest do
  use ExUnit.Case
  use Divo

  test "the full dependency stack is stood up" do
    containers =
      'docker ps -a'
      |> cmd_wrapper()

    assert String.contains?(containers, "divo_busybox_1")
  end

  defp cmd_wrapper(cmd), do: cmd |> :os.cmd() |> to_string
end

defmodule IntegrationPartialTest do
  use ExUnit.Case
  use Divo, services: [:alpine]

  test "only specified parts of the stack are stood up" do
    containers =
      'docker ps -a'
      |> cmd_wrapper()

    assert String.contains?(containers, "divo_busybox_1") == false
    assert String.contains?(containers, "divo_alpine_1") == true
  end

  defp cmd_wrapper(cmd), do: cmd |> :os.cmd() |> to_string
end
