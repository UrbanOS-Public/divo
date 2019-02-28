defmodule Mix.Tasks.Docker.Start do
  @moduledoc """
  Creates a custom mix task for creating and starting
  docker containers defined in your application's
  environment config file under the :divo key.
  """
  require Logger
  use Mix.Task
  alias Divo.{Parser, TaskHelper}

  @impl Mix.Task
  def run(args) do
    services =
      TaskHelper.fetch_config()
      |> filter_services(args)

    services
    |> Enum.map(fn {service, config} -> Divo.Parser.parse(service, config) end)
    |> Enum.map(&Divo.DockerCmd.run/1)
    |> Enum.each(&log_formatted/1)

    services
    |> Enum.map(fn {service, config} -> {service, Map.get(config, :wait_for, nil)} end)
    |> Enum.map(&wait_for_condition/1)
  end

  def wait_for_condition({_service, nil}), do: Logger.info("No service waits defined")

  def wait_for_condition({service, wait_for_config}) do
    {log, dwell, retry} = extract_wait_config(wait_for_config)

    Patiently.wait_for!(
      get_wait_condition(service, log),
      dwell: dwell,
      max_tries: retry
    )
  end

  defp extract_wait_config(wait_for_config) do
    log = Map.get(wait_for_config, :log, "")
    dwell = Map.get(wait_for_config, :dwell, 500)
    retry = Map.get(wait_for_config, :retry, 40)
    {log, dwell, retry}
  end

  defp get_wait_condition(service, log) do
    fn ->
      Logger.info("Checking for #{log}")
      status_code = Mix.shell().cmd("docker logs #{Parser.create_name(service)} --tail 100000 2>&1 | grep -q '#{log}'")
      case status_code do
        0 ->
          Logger.info("Found log '#{log}'")
          true

        _ ->
          false
      end
    end
  end

  defp log_formatted({parameters, {message, code}}) do
    Logger.info("docker run with (#{Enum.join(parameters, " ")})\n returned with code #{code}: #{message}")
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
