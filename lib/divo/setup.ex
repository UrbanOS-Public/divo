defmodule Divo.Setup do
  @moduledoc """
  Implements a macro for including directly in integration test files.
  Add `use Divo.Setup` to an integration test file to automatically
  add the Start and Kill commands for your dependent service definitions
  to a `setup_all` block of your tests.
  """

  defmacro __using__(opts \\ []) do
    auto_start = Keyword.get(opts, :auto_start, true)

    quote do
      import Divo.Compose

      setup_all do
        Divo.Compose.run(unquote(opts))

        app = Mix.Project.config() |> Keyword.get(:app)
        if unquote(auto_start), do: Application.ensure_all_started(app)

        on_exit(fn ->
          if unquote(auto_start), do: Application.stop(app)

          Divo.Compose.kill()
        end)

        :ok
      end
    end
  end
end
