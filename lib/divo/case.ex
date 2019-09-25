defmodule Divo.Case do
  @moduledoc """
  Can be used in place of Divo to also include ExUnit.Case.
  Opts will still be passed to Divo as normal.
  """

  defmacro __using__(opts \\ []) do
    quote do
      use ExUnit.Case
      use Divo, unquote(opts)
    end
  end
end
