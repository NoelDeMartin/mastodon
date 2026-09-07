#!/usr/bin/env sh
set -eu
umask 077

# Rireki backup script
# See https://github.com/NoelDeMartin/rireki

basedir="$(cd "$(dirname "$(readlink -f "$0")")/.." && pwd)"

if [ -z "${RIREKI_BACKUP_PATH:-}" ]; then
    echo "Error: RIREKI_BACKUP_PATH is not set" >&2
    exit 1
fi

tmp_sql="$RIREKI_BACKUP_PATH/dump.sql.tmp"
tmp_rdb="$RIREKI_BACKUP_PATH/dump.rdb.tmp"
trap 'rm -f "$tmp_sql" "$tmp_rdb"' EXIT

cd "$basedir"

echo "Backing up database..."
docker compose exec -T db pg_dump -U postgres postgres > "$tmp_sql"
mv "$tmp_sql" "$RIREKI_BACKUP_PATH/dump.sql"
chmod 600 "$RIREKI_BACKUP_PATH/dump.sql"
echo "Database backed up!"

echo "Backing up redis..."
docker compose exec -T redis redis-cli save > /dev/null
docker compose exec -T redis cat /data/dump.rdb > "$tmp_rdb"
mv "$tmp_rdb" "$RIREKI_BACKUP_PATH/dump.rdb"
chmod 600 "$RIREKI_BACKUP_PATH/dump.rdb"
echo "Redis backed up!"

trap - EXIT

echo "Backing up secrets..."
cp "$basedir/.env.production" "$RIREKI_BACKUP_PATH/.env.production"
chmod 600 "$RIREKI_BACKUP_PATH/.env.production"
echo "Secrets backed up!"
