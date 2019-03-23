defmodule Divo do
  @moduledoc """
  A library for incorporating docker-compose files or
  compose-compliant map structures defined in application
  config as dependency orchestration and management for
  integration testing Elixir apps with external services
  represented by the container services managed by divo.
  """

  defdelegate run(opts), to: Divo.Compose, as: :run
  defdelegate stop(), to: Divo.Compose, as: :stop
  defdelegate kill(), to: Divo.Compose, as: :kill

  @doc """
  Implements a macro for including directly in integration
  test files. Add `use Divo` to an integration test file to
  automatically add the Start and Kill commands for your
  dependent service definitions to a `setup_all` block of
  your tests.
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
          if unquote(auto_start) do
            dependent_apps =
              Application.spec(app, :applications) -- [:kernel, :stdlib, :elixir, :ex_unit, :logger, :divo, :placebo]

            [app | dependent_apps]
            |> Enum.each(&Application.stop/1)
          end

          Divo.Compose.kill()
        end)

        :ok
      end
    end
  end
end
