defmodule Mix.Tasks.Docker.Start do
  @moduledoc """
  Creates a custom mix task for creating and starting
  docker containers defined in your application's
  environment config file under the :divo key.
  """
  use Mix.Task
  alias Divo.Compose

  @impl Mix.Task
  def run(_args) do
    Compose.run()
  end
end
