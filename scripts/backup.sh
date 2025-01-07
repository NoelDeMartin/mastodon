#!/usr/bin/env sh

# Rireki backup script
# See https://github.com/NoelDeMartin/rireki

basedir=`cd $(readlink -f $0 | xargs dirname) && cd .. && pwd`

echo "Backing up database..."
docker compose -f $basedir/docker-compose.yml exec db pg_dump -U postgres postgres > $RIREKI_BACKUP_PATH/dump.sql
echo "Database backed up!"

echo "Backing up secrets..."
cp $basedir/.env.production $RIREKI_BACKUP_PATH/.env.production
echo "Secrets backed up!"

echo "Backing up redis..."
cp $basedir/redis/dump.rdb $RIREKI_BACKUP_PATH/dump.rdb
echo "Redis backed up!"
