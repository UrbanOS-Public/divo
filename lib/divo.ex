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
    quote do
      import Divo
      import Divo.Compose

      setup_all do
        start(unquote(opts))

        on_exit(fn ->
          cleanup(unquote(opts))
        end)
      end
    end
  end

  def start(opts \\ []) do
    auto_start = Keyword.get(opts, :auto_start, true)
    post_docker_run = Keyword.get(opts, :post_docker_run, [])

    Divo.Compose.run(opts)

    Enum.each(post_docker_run, & &1.())

    app = Mix.Project.config() |> Keyword.get(:app)
    if auto_start, do: Application.ensure_all_started(app)
  end

  def cleanup(opts \\ []) do
    auto_start = Keyword.get(opts, :auto_start, true)
    app = Mix.Project.config() |> Keyword.get(:app)

    if auto_start do
      dependent_apps =
        Application.spec(app, :applications) --
          [:kernel, :stdlib, :elixir, :ex_unit, :logger, :divo, :placebo]

      Logger.remove_backend(:console)

      [app | dependent_apps]
      |> Enum.each(&Application.stop/1)

      Logger.add_backend(:console)
    end

    Divo.Compose.kill()
  end
end
