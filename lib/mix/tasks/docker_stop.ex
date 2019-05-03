defmodule Mix.Tasks.Docker.Stop do
  @moduledoc """
  Executes `docker-compose stop` with your :divo configuration.
  """
  use Mix.Task
  alias Divo.Compose

  @impl Mix.Task
  def run(_args) do
    Compose.stop()
  end
end
