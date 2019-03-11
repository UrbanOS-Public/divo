defmodule Divo.Integration do
  @moduledoc """
  Implements a macro for including directly in Integration test files.
  Add `use Divo.Integration` to an integration test file to automatically
  add the Start and Kill commands for your dependent service definitions
  to a `setup_all` block of your tests.
  """

  defmacro __using__(opts \\ []) do
    auto_start = Keyword.get(opts, :auto_start, true)

    quote do
      import Mix.Tasks.Docker.{Start, Kill}

      setup_all do
        Mix.Tasks.Docker.Start.run(unquote(opts))

        app = Mix.Project.config() |> Keyword.get(:app)
        if unquote(auto_start), do: Application.ensure_all_started(app)

        on_exit(fn ->
          if unquote(auto_start), do: Application.stop(app)
          Mix.Tasks.Docker.Kill.run(unquote(opts))
        end)

        :ok
      end
    end
  end
end
