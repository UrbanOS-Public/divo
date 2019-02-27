defmodule Mix.Tasks.Docker.Kill do
  @moduledoc """
  Creates a custom mix task for killing docker containers
  defined in your application's environment config file
  under the :divo key.
  """
  use Mix.Task
  alias Divo.TaskHelper

  @impl Mix.Task
  def run(_args) do
    TaskHelper.fetch_config()
    |> Enum.map(fn {service_name, _config} -> Divo.Parser.create_name(service_name) end)
    |> Enum.map(&Divo.DockerCmd.kill/1)
  end
end
