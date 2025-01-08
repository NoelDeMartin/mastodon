#!/usr/bin/env sh

# crontab -e
# 30 5 * * 1 /var/www/mastodon/clear-data.sh >> /var/log/cron-mastodon.log 2>> /var/log/cron-mastodon.log

echo "[`date`] Clearing mastodon data..."
docker compose -f /var/www/mastodon/docker-compose.yml exec -T web tootctl media remove
docker compose -f /var/www/mastodon/docker-compose.yml exec -T web tootctl media remove --prune-profiles
docker compose -f /var/www/mastodon/docker-compose.yml exec -T web tootctl preview_cards remove
docker compose -f /var/www/mastodon/docker-compose.yml exec -T web tootctl emoji purge --remote-only
docker compose -f /var/www/mastodon/docker-compose.yml exec -T web tootctl accounts prune

echo "[`date`] Mastodon data cleared!"
echo ""
