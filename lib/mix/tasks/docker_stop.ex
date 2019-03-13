defmodule Mix.Tasks.Docker.Stop do
  @moduledoc """
  Creates a custom mix task for stopping docker containers
  defined in your application's environment config file
  under the :divo key.
  """
  use Mix.Task
  alias Divo.Compose

  @impl Mix.Task
  def run(_args) do
    Compose.stop()
  end
end
