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

  test "generates compose file from a behaviour implementation of a single service" do
    allow(File.write!(any(), any()), return: :ok)
    allow(System.get_env("TMPDIR"), return: "/var/tmp/bar")

    services = [{DivoFoobar, [db_password: "we-are-divo", db_name: "foobar-db", something: "else"]}]

    TemporaryEnv.put :divo, :divo, services do
      config = Divo.Helper.fetch_config()

      assert Divo.File.ensure_file(config) == "/var/tmp/bar/divo.compose"
    end
  end

  test "concatenates compose file from multiple implementations of the behaviour" do
    allow(File.write!(any(), any()), return: :ok)
    allow(System.get_env("TMPDIR"), return: "/var/tmp/bar")

    services = [
      {DivoFoobar, [db_password: "we-are-divo", db_name: "foobar-db", something: "else"]},
      DivoBarbaz
    ]

    TemporaryEnv.put :divo, :divo, services do
      config = Divo.Helper.fetch_config()

      assert Divo.File.ensure_file(config) == "/var/tmp/bar/divo.compose"
    end
  end
end
