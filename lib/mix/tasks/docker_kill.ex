defmodule Mix.Tasks.Docker.Kill do
  @moduledoc """
  Creates a custom mix task for killing docker containers
  defined in your application's environment config file
  under the :divo key.
  """
  use Mix.Task
  alias Divo.Compose

  @impl Mix.Task
  def run() do
    Compose.kill()
  end
end
