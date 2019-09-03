defmodule Divo do
  @moduledoc File.read!("README.md")

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
              Application.spec(app, :applications) --
                [:kernel, :stdlib, :elixir, :ex_unit, :logger, :divo, :placebo]

            Logger.remove_backend(:console)

            [app | dependent_apps]
            |> Enum.each(&Application.stop/1)

            Logger.add_backend(:console)
          end

          Divo.Compose.kill()
          Divo.Compose.remove()
        end)

        :ok
      end
    end
  end
end
