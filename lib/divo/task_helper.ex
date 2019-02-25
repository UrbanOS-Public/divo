defmodule Divo.TaskHelper do
  @moduledoc """
  Extract common key-fetching functionality used by all of the
  mix tasks to construct the proper arguments to the docker
  commands.
  """
  def fetch_config() do
    Mix.Project.config()
    |> Keyword.get(:app)
    |> Application.fetch_env!(:divo)
  end
end
