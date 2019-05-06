defmodule Divo.File do
  @moduledoc """
  Constructs the ad hoc docker-compose file used by
  Divo to run docker dependency services based on
  config in the app environment (`Mix.env()`) file.
  """
  require Logger
  alias Divo.Helper

  @doc """
  Returns the name of the compose file to run, either as a
  pass-through from an existing compose file or the path of
  the file dynamically created by Divo.
  """
  @spec file_name() :: String.t()
  def file_name() do
    app = Helper.fetch_name()

    case System.get_env("TMPDIR") do
      nil -> "/tmp/#{app}.compose"
      defined -> "#{defined}/#{app}.compose"
    end
  end

  @doc """
  Passes through the file name when the compose file is
  pre-existing and supplied via file system path. Builds
  and writes a dynamic compose file to a temp directory before
  returning the path to that temp file if file does not exist.
  """
  @spec ensure_file(String.t() | [tuple()] | map()) :: String.t()
  def ensure_file(app_config) when is_binary(app_config) do
    Logger.info("Using : #{app_config}")

    app_config
  end

  def ensure_file(app_config) when is_list(app_config) do
    file = file_name()

    Logger.info("Generating : #{file} from stack module")

    app_config
    |> Divo.Stack.concat_compose()
    |> Jason.encode!()
    |> write(file)

    file
  end

  def ensure_file(app_config) when is_map(app_config) do
    file = file_name()

    Logger.info("Generating : #{file} from map")

    app_config
    |> Jason.encode!()
    |> write(file)

    file
  end

  defp write(content, path) do
    File.write!(path, content)
  end
end
