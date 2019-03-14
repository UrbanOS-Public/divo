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
    with {:ok, config} <- Application.fetch_env(fetch_name(), :divo) do
      config
    else
      :error -> raise ArgumentError, message: "no services were defined in application config"
    end
  end
end
