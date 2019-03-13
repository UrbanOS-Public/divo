defmodule Divo.FileTest do
  use ExUnit.Case
  use Placebo

  test "correctly determines the filename" do
    allow(System.get_env("TMPDIR"), return: "/var/tmp/foo")

    assert Divo.File.file_name() == "/var/tmp/foo/divo.compose"
  end

  test "correctly defaults the filename" do
    allow(System.get_env("TMPDIR"), return: nil)

    assert Divo.File.file_name() == "/tmp/divo.compose"
  end

  # test "uses existing compose file" do
  #   Application.put_env(:divo, :divo, "test/docker-compose.yaml", timeout: 5)
  #   file = Divo.Helper.fetch_config()

  #   assert Divo.File.ensure_file(file) == "test/docker-compose.yaml"
  # end

  test "generates compose file from app config" do
    allow(File.write!(any(), any()), return: :ok)
    allow(System.get_env("TMPDIR"), return: "/var/tmp/foo")
    file = Divo.Helper.fetch_config()

    assert Divo.File.ensure_file(file) == "/var/tmp/foo/divo.compose"
  end
end
