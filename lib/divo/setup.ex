defmodule Divo.Setup do
  @moduledoc """
  Implements a macro for including directly in integration test files.
  Add `use Divo.Setup` to an integration test file to automatically
  add the Start and Kill commands for your dependent service definitions
  to a `setup_all` block of your tests.
  """

  defmacro __using__(opts \\ []) do
    quote do
      import Divo.Compose

      setup_all do
        Divo.Compose.run(unquote(opts))

        Mix.Project.config()
        |> Keyword.get(:app)
        |> Application.ensure_all_started()

        on_exit(fn ->
          Mix.Project.config()
          |> Keyword.get(:app)
          |> Application.stop()

          Divo.Compose.kill()
        end)

        :ok
      end
    end
  end
end
