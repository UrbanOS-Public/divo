defmodule Divo.ParserTest do
  use ExUnit.Case

  test "parse image name" do
    configMap = %{
      image: "derp:latest"
    }

    expectedArgs = ["derp:latest"]

    assert Divo.Parser.parse(configMap) == expectedArgs
  end

  test "parse command" do
    configMap = %{
      command: "rm -rf all.all"
    }

    expectedArgs = ["rm -rf all.all"]

    assert Divo.Parser.parse(configMap) == expectedArgs
  end

  test "parse environment variables" do
    configMap = %{
      env: [val1: "bob", val2: "hrob"]
    }

    expectedArgs = ["--env VAL1=bob", "--env VAL2=hrob"]

    assert Divo.Parser.parse(configMap) == expectedArgs
  end

  test "parse ports" do
    configMap = %{
      ports: [{90, 90}, {60, 70}]
    }

    expectedArgs = ["-p 90:90", "-p 60:70"]

    assert Divo.Parser.parse(configMap) == expectedArgs
  end

  test "parse volumes" do
    configMap = %{
      volumes: [{"/tmp", "tmp/"}, {"/data", "/data/bad/"}]
    }

    expectedArgs = ["-v /tmp:tmp/", "-v /data:/data/bad/"]

    assert Divo.Parser.parse(configMap) == expectedArgs
  end
end
