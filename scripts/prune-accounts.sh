#!/usr/bin/env sh

# Workaround for removing cached remote assets
# See https://github.com/mastodon/mastodon/issues/15195

# sudo crontab -e
# 0 5 * * 1 /var/www/mastodon/scripts/prune-accounts.sh >> /var/log/cron-mastodon.log 2>> /var/log/cron-mastodon.log

echo "[`date`] Pruning mastodon accounts..."

# Delete cached assets
rm /var/www/mastodon/public/system/cache -rf

# Refresh some accounts I see often (please don't feel bad if you're not on this list 🙈)
docker compose -f /var/www/mastodon/docker-compose.yml exec -T web tootctl accounts refresh VincentTunru@fosstodon.org
docker compose -f /var/www/mastodon/docker-compose.yml exec -T web tootctl accounts refresh angelo@social.veltens.org
docker compose -f /var/www/mastodon/docker-compose.yml exec -T web tootctl accounts refresh jg10@mastodon.social
docker compose -f /var/www/mastodon/docker-compose.yml exec -T web tootctl accounts refresh antfu@webtoo.ls
docker compose -f /var/www/mastodon/docker-compose.yml exec -T web tootctl accounts refresh rosano@mastodon.online
docker compose -f /var/www/mastodon/docker-compose.yml exec -T web tootctl accounts refresh thisismissem@hachyderm.io
docker compose -f /var/www/mastodon/docker-compose.yml exec -T web tootctl accounts refresh aral@mastodon.ar.al
docker compose -f /var/www/mastodon/docker-compose.yml exec -T web tootctl accounts refresh nolan@toot.cafe
docker compose -f /var/www/mastodon/docker-compose.yml exec -T web tootctl accounts refresh tychi@merveilles.town

echo "[`date`] Mastodon accounts pruned!"
echo ""
