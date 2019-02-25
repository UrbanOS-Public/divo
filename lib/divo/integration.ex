defmodule Divo.Integration do
  defmacro __using__(opts \\ []) do
    quote do
      import Divo.{Parser, DockerCmd, TaskHelper}
      import Mix.Tasks.Docker.{Start, Kill}

      setup_all do
        Mix.Tasks.Docker.Start.run(unquote(opts))

        on_exit(fn ->
          Mix.Tasks.Docker.Kill.run(unquote(opts))
        end)

        :ok
      end
    end
  end
end
