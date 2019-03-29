defmodule Divo.Helper do
  @moduledoc """
  Extract common key-fetching functionality used by all of the
  mix tasks to construct the proper arguments to the docker
  commands.
  """

  @doc """
  Returns the name of the calling app from the mix config.
  """
  @spec fetch_name() :: atom()
  def fetch_name() do
    Mix.Project.config()[:app]
  end

  @doc """
  Returns the configuration for divo from the environment config
  exs file that defines the container services to run or the path
  to the config given an existing compose file.
  """
  @spec fetch_config() :: map() | String.t | [tuple()]
  def fetch_config() do
    with {:ok, config} <- Application.fetch_env(fetch_name(), :divo) do
      config
    else
      :error -> raise ArgumentError, message: "no services were defined in application config"
    end
  end
end
