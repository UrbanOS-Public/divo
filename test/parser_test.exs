defmodule Divo.ParserTest do
  use ExUnit.Case

  test "parse image and container name" do
    config_map = %{
      image: "derp:latest"
    }

    expected_args = ["--name=divo-derp", "derp:latest"]

    assert Divo.Parser.parse(:derp, config_map) == expected_args
  end

  test "parse command" do
    config_map = %{
      command: "rm -rf all.all"
    }

    expected_args = get_expected_args(["rm", "-rf", "all.all"])

    assert Divo.Parser.parse(:derp, config_map) == expected_args
  end

  test "parse environment variables" do
    config_map = %{
      env: [val1: "bob", val2: "hrob"]
    }

    expected_args = get_expected_args(["--env=VAL1=bob", "--env=VAL2=hrob"])

    assert Divo.Parser.parse(:derp, config_map) == expected_args
  end

  test "parse ports" do
    config_map = %{
      ports: [{90, 90}, {60, 70}]
    }

    expected_args = get_expected_args(["--publish=90:90", "--publish=60:70"])

    assert Divo.Parser.parse(:derp, config_map) == expected_args
  end

  test "parse volumes" do
    config_map = %{
      volumes: [{"/tmp", "tmp/"}, {"/data", "/data/bad/"}]
    }

    expected_args = get_expected_args(["--volume=/tmp:tmp/", "--volume=/data:/data/bad/"])

    assert Divo.Parser.parse(:derp, config_map) == expected_args
  end

  test "parse network" do
    config_map = %{
      net: :bob
    }

    expected_args = get_expected_args(["--net=container:bob"])

    assert Divo.Parser.parse(:derp, config_map) == expected_args
  end

  test "parser injects arbitrary 'additional params' into the docker start" do
    config_map = %{
      ports: [{90, 90}],
      additional_opts: [
        "--user=bob"
      ]
    }

    expected_args = get_expected_args(["--publish=90:90", "--user=bob"])

    assert Divo.Parser.parse(:derp, config_map) == expected_args
  end

  test "parser injects arbitrary 'additional params' into the docker start even when not formatted for System.cmd" do
    config_map = %{
      ports: [{90, 90}],
      additional_opts: [
        "--user bob",
        "-m 5mb"
      ]
    }

    expected_args = get_expected_args(["--publish=90:90", "-m", "5mb", "--user", "bob"])

    assert Divo.Parser.parse(:derp, config_map) == expected_args
  end

  defp get_expected_args(args) do
    ["--name=divo-derp" | args]
  end
end
