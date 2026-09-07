#!/usr/bin/env sh
set -eu

basedir="$(cd "$(dirname "$(readlink -f "$0")")/.." && pwd)"
cd "$basedir"

if [ -n "$(docker compose ps --status running -q web)" ]; then
    docker compose exec -T -u root web chown -R mastodon:mastodon /mastodon/public/system
else
    docker compose run -T --rm --no-deps -u root web chown -R mastodon:mastodon /mastodon/public/system
fi
