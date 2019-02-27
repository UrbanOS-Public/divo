defmodule Divo.Parser do
  @moduledoc """
  Constructs the command string based on the application environment config.
  """

  def parse(service_name, config_map) do
    image = Map.get(config_map, :image)
    command =
      config_map
      |> Map.get(:command, "")
      |> String.split(" ", trim: true)
    name = "--name=#{create_name(service_name)}"

    net =
      config_map
      |> Map.get(:net)
      |> get_network()

    additional_opts =
      config_map
      |> Map.get(:additional_opts, [])
      |> normalize_opts()

    opts =
      [:env, :ports, :volumes]
      |> Enum.reduce([], fn x, acc -> parse_opts(config_map, x) ++ acc end)
      |> Enum.concat(additional_opts)

    ([name, net] ++ opts ++ [image] ++ command)
    |> Enum.filter(&included/1)
  end

  def create_name(service_name) do
    app = Mix.Project.config()[:app]

    "#{app}-#{service_name}"
  end

  defp parse_opts(config_map, opt) do
    config_map
    |> Map.get(opt, [])
    |> Enum.map(&parse_opt(&1, opt))
  end

  defp parse_opt({variable, value}, :env) do
    "--env=#{String.upcase(to_string(variable))}=#{value}"
  end

  defp parse_opt({local, remote}, :ports), do: "--publish=#{local}:#{remote}"
  defp parse_opt({local, remote}, :volumes), do: "--volume=#{local}:#{remote}"

  defp included(arg) do
    !is_nil(arg)
  end

  defp get_network(nil), do: nil
  defp get_network(key), do: "--net=container:#{key}"

  defp normalize_opts(opts) do
    opts
    |> Enum.reduce([], fn x, acc -> [normalize_opt(x) | acc] end)
    |> List.flatten()
  end

  defp normalize_opt(opt) do
    String.split(opt, " ", trim: true)
  end
end
