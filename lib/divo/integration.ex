defmodule Divo.Integration do
  @moduledoc """
  Implements a macro for including directly in Integration test files.
  Add `use Divo.Integration` to an integration test file to automatically
  add the Start and Kill commands for your dependent service definitions
  to a `setup_all` block of your tests.
  """

  defmacro __using__(opts \\ []) do
    quote do
      import Mix.Tasks.Docker.{Start, Kill}

      setup_all do
        Mix.Tasks.Docker.Start.run(unquote(opts))

        Mix.Project.config()
        |> Keyword.get(:app)
        |> Application.ensure_all_started()

        on_exit(fn ->
          Mix.Tasks.Docker.Kill.run(unquote(opts))
        end)

        :ok
      end
    end
  end
end
