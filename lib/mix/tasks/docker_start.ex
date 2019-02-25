defmodule Mix.Tasks.Docker.Start do
  @moduledoc """
  Creates a custom mix task for creating and starting
  docker containers defined in your application's
  environment config file under the :divo key.
  """
  use Mix.Task
  alias Divo.TaskHelper

  @impl Mix.Task
  def run(_args) do
    TaskHelper.fetch_config()
    |> Enum.map(fn {x, y} -> Divo.Parser.parse(x, y) end)
    |> Enum.map(&Divo.DockerCmd.run/1)
    |> Enum.map(&log_formatted/1)
  end

  defp log_formatted({parameters, {message, code}}) do
    IO.puts(
      "docker run with (#{Enum.join(parameters, " ")})\n returned with code #{code}: #{message}"
    )
  end
end
