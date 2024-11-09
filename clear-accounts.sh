#!/usr/bin/env sh

# sudo crontab -e
# 30 6 * * 1 /var/www/mastodon/clear-accounts.sh >> /var/log/cron-mastodon.log 2>> /var/log/cron-mastodon.log

echo "[`date`] Clearing mastodon accounts..."
rm /var/www/mastodon/public/system/accounts/headers/000/ -rf
rm /var/www/mastodon/public/system/accounts/avatars/000/ -rf
mkdir -p /var/www/mastodon/public/system/accounts/headers/000/000/001/original
mkdir -p /var/www/mastodon/public/system/accounts/avatars/000/000/001/original
chmod 777 /var/www/mastodon/public/system/accounts/headers/000/
chmod 777 /var/www/mastodon/public/system/accounts/headers/000/000/
chmod 777 /var/www/mastodon/public/system/accounts/headers/000/000/001/
chmod 777 /var/www/mastodon/public/system/accounts/headers/000/000/001/original/
chmod 777 /var/www/mastodon/public/system/accounts/avatars/000/
chmod 777 /var/www/mastodon/public/system/accounts/avatars/000/000/
chmod 777 /var/www/mastodon/public/system/accounts/avatars/000/000/001/
chmod 777 /var/www/mastodon/public/system/accounts/avatars/000/000/001/original/
cp /var/www/mastodon/backups/f8f1df4b7f515ff3.jpeg /var/www/mastodon/public/system/accounts/headers/000/000/001/original/f8f1df4b7f515ff3.jpeg
cp /var/www/mastodon/backups/8e308d11e6bbdbe1.png /var/www/mastodon/public/system/accounts/avatars/000/000/001/original/8e308d11e6bbdbe1.png
/usr/local/bin/docker-compose -f /var/www/mastodon/docker-compose.yml exec -T web tootctl accounts refresh VincentTunru@fosstodon.org
/usr/local/bin/docker-compose -f /var/www/mastodon/docker-compose.yml exec -T web tootctl accounts refresh angelo@social.veltens.org
/usr/local/bin/docker-compose -f /var/www/mastodon/docker-compose.yml exec -T web tootctl accounts refresh jg10@mastodon.social
/usr/local/bin/docker-compose -f /var/www/mastodon/docker-compose.yml exec -T web tootctl accounts refresh antfu@webtoo.ls
/usr/local/bin/docker-compose -f /var/www/mastodon/docker-compose.yml exec -T web tootctl accounts refresh rosano@mastodon.online
/usr/local/bin/docker-compose -f /var/www/mastodon/docker-compose.yml exec -T web tootctl accounts refresh nolan@toot.cafe
/usr/local/bin/docker-compose -f /var/www/mastodon/docker-compose.yml exec -T web tootctl accounts refresh tychi@merveilles.town

echo "[`date`] Mastodon accounts cleared!"
echo ""
