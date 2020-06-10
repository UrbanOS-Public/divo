defmodule Divo.Suite do
  @moduledoc false

  def start(opts \\ []) do
    auto_cleanup? = Keyword.get(opts, :auto_cleanup?, true)

    Divo.start(opts)

    if auto_cleanup? do
      System.at_exit(fn
        _ -> Divo.cleanup(opts)
      end)
    end

    fn -> Divo.cleanup(opts) end
  end
end
