defmodule Divo.Stack do
  @moduledoc """
  Implements a behaviour for importing
  predefined compose stacks from external
  library complementary to divo for quickly
  standing up well-defined services with
  little variation in configuration.
  """

  @doc """
  Defines the behaviour that must be implemented to
  supply configs from external modules to divo. The
  configuration values are expected as a keyword list
  of attributes specific to each module adopting the
  behaviour.
  """
  @callback gen_stack(keyword()) :: {atom(), map()}

  @doc """
  Iterates over modules supplied in the app :divo
  config, calling the `gen_stack` function on each
  module's implementation of the behavior, collecting
  the resulting maps into a single map and passing
  the accumulated result out for writing out the file.
  """
  @spec concat_compose([tuple()]) :: map()
  def concat_compose(config) do
    compose_file = %{version: "3.4"}

    services =
      config
      |> Enum.map(&configure_stack/1)
      |> Enum.reduce(%{}, fn service, acc -> Map.merge(service, acc) end)

    Map.put(compose_file, :services, services)
  end

  defp configure_stack(module) when is_atom(module), do: apply(module, :gen_stack, [[]])

  defp configure_stack({module, envars}), do: apply(module, :gen_stack, [envars])
end
