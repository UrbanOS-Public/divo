defmodule Divo.Stack do
  @moduledoc """
  Implements a behaviour for importing
  predefined compose stacks from external
  library complementary to divo for quickly
  standing up well-defined services with
  little variation in configuration.
  """
  alias Divo.Helper

  @callback gen_stack(keyword()) :: {atom(), map()}

  def concat_compose(config) do
    compose_file = %{version: "3.4"}

    services =
      config
      |> Enum.map(fn {module, envars} ->
        apply(module, :gen_stack, [envars])
      end)
      |> Enum.reduce(%{}, fn service, acc -> Map.merge(service, acc) end)

    Map.put(compose_file, :services, services)
  end
end
