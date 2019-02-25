defmodule Mix.Tasks.Docker.Start do
  @moduledoc """
  Creates a custom mix task for creating and starting
  docker containers defined in your application's
  environment config file under the :divo key.
  """
  use Mix.Task
  alias Divo.TaskHelper

  @impl Mix.Task
  def run(args) do
    TaskHelper.fetch_config()
    |> filter_services(args)
    |> Enum.map(fn {service, config} -> Divo.Parser.parse(service, config) end)
    |> Enum.map(&Divo.DockerCmd.run/1)
    |> Enum.map(&log_formatted/1)
  end

  defp log_formatted({parameters, {message, code}}) do
    IO.puts(
      "docker run with (#{Enum.join(parameters, " ")})\n returned with code #{code}: #{message}"
    )
  end

  defp filter_services(services, []), do: services

  defp filter_services(services, filter) do
    Enum.filter(services, fn {service, _config} ->
      filter
      |> Keyword.get(:services, [])
      |> Enum.member?(service)
    end)
  end
end
