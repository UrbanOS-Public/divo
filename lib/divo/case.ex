defmodule Divo.Case do
  @moduledoc """
  Can be used in place of Divo to also include ExUnit.Case.
  Opts will still be passed to Divo as normal, and the async
  opt will be passed only to ExUnit.Case.
  """

  defmacro __using__(opts \\ []) do
    {async, opts} = Keyword.pop(opts, :async, false)

    quote do
      use ExUnit.Case, async: unquote(async)
      use Divo, unquote(opts)
    end
  end
end
