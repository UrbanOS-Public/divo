defmodule Divo.Parser do
  @moduledoc """
  Constructs the command string based on the application environment config.
  """

  def parse(configMap) do
    image = Map.get(configMap, :image)
    command = Map.get(configMap, :command)
    opts = Map.get(configMap, :env, [])
    |> Enum.map(fn {x, y} -> "--env #{String.upcase(to_string(x))}=#{y}" end)

    opts = Map.get(configMap, :ports, [])
    |> Enum.map(fn {x, y} -> "--port #{x}:#{y}" end)
    |> Enum.concat(opts)

    opts = Map.get(configMap, :volumes, [])
    |> Enum.map(fn {x, y} -> "-v #{x}:#{y}" end)
    |> Enum.concat(opts)

    Enum.filter([image] ++ opts ++ [command], fn x -> !is_nil(x) end)
  end
end
