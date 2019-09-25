defmodule Divo.Case do
  defmacro __using__(opts \\ []) do
    quote do
      use ExUnit.Case
      use Divo, opts
    end
  end
end
