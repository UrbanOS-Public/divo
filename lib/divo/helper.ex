defmodule Divo.Helper do
  @moduledoc """
  Extract common key-fetching functionality used by all of the
  mix tasks to construct the proper arguments to the docker
  commands.
  """

  def fetch_name() do
    Mix.Project.config()[:app]
  end

  def fetch_config() do
    fetch_name()
    |> Application.fetch_env!(:divo)
  end
end
