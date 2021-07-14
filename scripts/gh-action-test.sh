DOCKER_COMPOSE_VERSION=1.23.1

sudo rm /usr/local/bin/docker-compose
curl -L https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-`uname -s`-`uname -m` > docker-compose
chmod +x docker-compose
sudo mv docker-compose /usr/local/bin

mix format --check-formatted
mix credo
mix dialyzer
mix hex.outdated || true
mix test