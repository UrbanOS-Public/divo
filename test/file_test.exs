defmodule Divo.FileTest do
  use ExUnit.Case
  use Placebo
  require TemporaryEnv

  test "correctly determines the filename" do
    allow(System.get_env("TMPDIR"), return: "/var/tmp/foo")

    assert Divo.File.file_name() == "/var/tmp/foo/divo.compose"
  end

  test "correctly defaults the filename" do
    allow(System.get_env("TMPDIR"), return: nil)

    assert Divo.File.file_name() == "/tmp/divo.compose"
  end

  test "uses existing compose file" do
    TemporaryEnv.put :divo, :divo, "test/docker-compose.yaml" do
      file = Divo.Helper.fetch_config()

      assert Divo.File.ensure_file(file) == "test/docker-compose.yaml"
    end
  end

  test "generates compose file from app config" do
    allow(File.write!(any(), any()), return: :ok)
    allow(System.get_env("TMPDIR"), return: "/var/tmp/foo")
    config = Divo.Helper.fetch_config()

    assert Divo.File.ensure_file(config) == "/var/tmp/foo/divo.compose"
  end

  test "generates compose file from a behaviour implementation" do
    allow(File.write!(any(), any()), return: :ok)
    allow(System.get_env("TMPDIR"), return: "/var/tmp/bar")

    services = [{DivoBarbaz, []}]

    TemporaryEnv.put :divo, :divo, services do
      config = Divo.Helper.fetch_config()

      assert Divo.File.ensure_file(config) == "/var/tmp/bar/divo.compose"
    end
  end
end

defmodule DivoBarbaz do
  @behaviour Divo.Stack

  @impl Divo.Stack
  def gen_stack(_envars) do
    %{
      barbaz: %{
        image: "library/barbaz",
        healthcheck: %{
          test: ["CMD-SHELL", "/bin/true || exit 1"]
        },
        ports: ["2345:2345", "7777:7777"]
      }
    }
  end
end
