defmodule Divo.FileTest do
  use ExUnit.Case

  import Mock

  require TemporaryEnv

  test "correctly determines the filename" do
    with_mock(System, [], [get_env: fn ("TMPDIR") -> "/var/tmp/foo" end]) do
      assert Divo.File.file_name() == "/var/tmp/foo/divo.compose"
    end
  end

  test "correctly defaults the filename" do
    with_mock(System, [], [get_env: fn ("TMPDIR") -> nil end]) do
      assert Divo.File.file_name() == "/tmp/divo.compose"
    end
  end

  test "uses existing compose file" do
    TemporaryEnv.put :divo, :divo, "test/docker-compose.yaml" do
      file = Divo.Helper.fetch_config()

      assert Divo.File.ensure_file(file) == "test/docker-compose.yaml"
    end
  end

  describe "generate" do
    setup_with_mocks([
      {System, [], [get_env: fn ("TMPDIR") -> "/var/tmp/foo" end]},
      {File, [], [write!: fn (_, _) -> :ok end]},
      {DivoFoobar, [:non_strict], [gen_stack: fn(_) -> %{} end]},
      {DivoBarbaz, [:non_strict], [gen_stack: fn(_) -> %{} end]}
    ]) do
      {:ok, foo: "bar"}
    end

    test "generates compose file from app config" do
      config = Divo.Helper.fetch_config()

      assert Divo.File.ensure_file(config) == "/var/tmp/foo/divo.compose"
    end

    test "generates compose file from a behaviour implementation of a single service" do
      services = [{DivoFoobar, [db_password: "we-are-divo", db_name: "foobar-db", something: "else"]}]

      TemporaryEnv.put :divo, :divo, services do
        config = Divo.Helper.fetch_config()

        assert Divo.File.ensure_file(config) == "/var/tmp/foo/divo.compose"
      end
    end

  test "concatenates compose file from multiple implementations of the behaviour" do
    services = [
      {DivoFoobar, [db_password: "we-are-divo", db_name: "foobar-db", something: "else"]},
      DivoBarbaz
    ]

    TemporaryEnv.put :divo, :divo, services do
      config = Divo.Helper.fetch_config()

      assert Divo.File.ensure_file(config) == "/var/tmp/foo/divo.compose"
    end
  end
  end
end
