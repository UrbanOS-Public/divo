defmodule Mix.Tasks.Docker.Kill do
  @moduledoc """
  Executes `docker-compose down` with your :divo configuration.
  """
  use Mix.Task
  alias Divo.Compose

  @impl Mix.Task
  def run(_args) do
    Compose.kill()
  end
end
