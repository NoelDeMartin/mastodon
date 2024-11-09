#!/usr/bin/env sh

# crontab -e
# 30 5 * * 1 /var/www/mastodon/clear-media.sh >> /var/log/cron-mastodon.log 2>> /var/log/cron-mastodon.log

echo "[`date`] Clearing mastodon media..."
/usr/local/bin/docker-compose -f /var/www/mastodon/docker-compose.yml exec -T web tootctl media remove
/usr/local/bin/docker-compose -f /var/www/mastodon/docker-compose.yml exec -T web tootctl preview_cards remove

echo "[`date`] Mastodon media cleared!"
echo ""
