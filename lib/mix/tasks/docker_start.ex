defmodule Mix.Tasks.Docker.Start do
  @moduledoc """
  Executes `docker-compose up` with your :divo configuration.
  """
  use Mix.Task
  alias Divo.Compose

  @impl Mix.Task
  def run(_args) do
    Compose.run()
  end
end
