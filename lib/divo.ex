defmodule Divo do
  @moduledoc """
  A library for incorporating docker-compose files or
  compose-compliant map structures defined in application
  config as dependency orchestration and management for
  integration testing Elixir apps with external services
  represented by the container services managed by divo.
  """

  defdelegate run(opts), to: Divo.Compose, as: :run
  defdelegate stop(), to: Divo.Compose, as: :stop
  defdelegate kill(), to: Divo.Compose, as: :kill
end
