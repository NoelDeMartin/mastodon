#!/usr/bin/env sh
set -eu

docker compose pull
docker compose build
docker compose down
docker compose run --rm web bundle exec rails db:migrate
docker compose up -d
nginx-agora restart
