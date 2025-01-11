#!/usr/bin/env sh

git pull
docker compose build
docker compose down
docker compose up -d
nginx-agora restart
