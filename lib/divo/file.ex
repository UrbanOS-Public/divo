defmodule Divo.File do
  @moduledoc """
  Constructs the ad hoc docker-compose file used by
  Divo to run docker dependency services based on
  config in the app environment (Mix.env()) file.
  """
  require Logger
  alias Divo.Helper

  def file_name() do
    app = Helper.fetch_name()

    case System.get_env("TMPDIR") do
      nil -> "/tmp/#{app}.compose"
      defined -> "#{defined}/#{app}.compose"
    end
  end

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
