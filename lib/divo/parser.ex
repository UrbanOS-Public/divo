defmodule Divo.Parser do
  @moduledoc """
  Constructs the command string based on the application environment config.
  """

  def parse(configMap) do
    image = Map.get(configMap, :image)
    command = Map.get(configMap, :command)

    opts =
      [:env, :ports, :volumes]
      |> Enum.reduce([], fn x, acc -> parse_opts(configMap, x) ++ acc end)

    ([image] ++ opts ++ [command])
    |> Enum.filter(&included/1)
  end

  def parse_opts(configMap, opt) do
    Map.get(configMap, opt, [])
    |> Enum.map(&parse_opt(&1, opt))
  end

  def parse_opt({variable, value}, :env),
    do: "--env #{String.upcase(to_string(variable))}=#{value}"

  def parse_opt({local, remote}, :ports), do: "-p #{local}:#{remote}"
  def parse_opt({local, remote}, :volumes), do: "-v #{local}:#{remote}"

  def included(arg) do
    !is_nil(arg)
  end
end
