FROM bitwalker/alpine-elixir:1.14
COPY . /app
WORKDIR /app
RUN mix local.hex --force \
    && mix local.rebar --force \
    && mix deps.get \
    # && mix test \ # Tests run separately due to dockerized Jenkins
    && mix format --check-formatted \
    && mix credo
