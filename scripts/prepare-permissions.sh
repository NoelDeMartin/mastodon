#!/usr/bin/env bash

MASTODON_UID=`docker compose run --rm web id -u mastodon | sed 's/\r$//'`

sudo chown -R $MASTODON_UID:$MASTODON_UID ./public/system
