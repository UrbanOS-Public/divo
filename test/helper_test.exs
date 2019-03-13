defmodule Divo.HelperTest do
  use ExUnit.Case
  require TemporaryEnv

  test "returns the apps name for parsing" do
    assert Divo.Helper.fetch_name() == :divo
  end

  test "returns the compose config map" do
    compose_services = %{
      version: "2.0",
      services: %{
        image: "httpd:latest",
        command: ["httpd-foreground"],
        ports: ["8080:80"]
      }
    }

    TemporaryEnv.put :divo, :divo, compose_services do
      assert Divo.Helper.fetch_config() == compose_services
    end
  end
end
