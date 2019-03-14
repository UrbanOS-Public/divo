defmodule Divo.ValidateTest do
  @moduledoc false
  use ExUnit.Case
  import ExUnit.CaptureLog

  test "successfully validates correct compose file" do
    compose = "test/support/sample-compose.yaml"

    actual =
      capture_log(fn ->
        Divo.Validate.validate(compose)
      end)

    assert actual =~ "Compose file validated successfully"
  end

  test "fails on an invalid compose file" do
    compose = "test/support/invalid-compose.yaml"

    assert_raise ArgumentError, fn ->
      actual =
        capture_log(fn ->
          Divo.Validate.validate(compose)
        end)

      assert actual =~ "Compose file invalid"
    end
  end
end
