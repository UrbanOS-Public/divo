defmodule Divo.Suite do
  @moduledoc false

  def start(opts \\ []) do
    exit_hook = Keyword.get(opts, :exit_hook, &System.at_exit/1)
    exit_arity = Keyword.get(opts, :exit_arity, 1)

    Divo.start(opts)

    exit_func =
      case exit_arity do
        1 -> fn _ -> Divo.cleanup(opts) end
        _ -> fn -> Divo.cleanup(opts) end
      end

    exit_hook.(exit_func)
  end
end
