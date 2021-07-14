mix format --check-formatted
mix credo
mix dialyzer
mix hex.outdated || true
mix test