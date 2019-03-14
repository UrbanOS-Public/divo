defmodule Divo.Validate do
  @moduledoc """
  Implements a validation of the compose file structure,
  either constructed by divo or supplied by as an
  existing compose file.
  """
  require Logger

  def validate(file) do
    System.cmd("docker-compose", ["--file", file, "config"], stderr_to_stdout: true)
    |> case do
      {_, 0} ->
        Logger.info("Compose file validated successfully")

      {error, _} ->
        Logger.error("Compose file invalid: #{error}")
        raise ArgumentError, message: "Bailing out due to invalid compose file"
    end
  end
end
