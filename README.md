# Mastodon

This repository holds the configuration to serve my instance-of-one Mastodon server at [noeldemartin.social](https://noeldemartin.social). For documentation about how to host your own, or Mastodon in general, check out [the official docs](https://docs.joinmastodon.org/).

## Deployment

These instructions work to migrate an existing application, given that I was running the instance with a different setup before creating this repository. You can see how to generate the backup files in [backup.sh](./scripts/backup.sh).

Start creating the directory in the new machine:

```sh
git clone https://github.com/NoelDeMartin/mastodon.git mastodon
cd mastodon
cp .env.production.example .env.production
```

Set the following variables in `.env.production` (using the ones from the backup):

- `SECRET_KEY_BASE`
- `OTP_SECRET`
- `ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY`
- `ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT`
- `ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY`
- `VAPID_PRIVATE_KEY`
- `VAPID_PUBLIC_KEY`
- `SMTP_*`

Now, upload the backed up files from your local machine:

```sh
rsync -hr --progress --stats ./backup/system user@server:/var/www/mastodon/public/
scp ./backup/dump.sql user@server:/var/www/mastodon/dump.sql
scp ./backup/dump.rdb user@server:/var/www/mastodon/redis/dump.rdb
```

Next, back in the server, restore the database and run the migrations:

```sh
docker compose up -d
docker cp ./dump.sql mastodon-db-1:/dump.sql
docker compose exec db sh -i
psql -U postgres -d postgres < dump.sql
rm dump.sql
# Exit docker shell...
rm dump.sql
docker compose down
docker compose run --rm web bundle exec rails db:migrate
docker compose up -d
```

Finally, you'll need to run the following script in order to set up the proper permissions:

```sh
./scripts/prepare-permissions.sh
```

And that's it for the Mastodon set up. However, you'll probably have to do a couple more things before it's live.

You'll probably need to create new certificates:

```sh
sudo certbot certonly -d noeldemartin.social --standalone
```

You'll also need to configure a couple of cron jobs. Add the following to your user's crontab with `crontab -e` (no need to use sudo):

```
30 5 * * 1 /var/www/mastodon/scripts/prune-data.sh >> /var/log/cron-mastodon.log 2>> /var/log/cron-mastodon.log
```

And this one to the admin user with `sudo crontab -e`:

```
0 5 * * 1 /var/www/mastodon/scripts/prune-accounts.sh >> /var/log/cron-mastodon.log 2>> /var/log/cron-mastodon.log
```

Finally, install the site in [nginx-agora](https://github.com/noelDeMartin/nginx-agora):

```sh
nginx-agora install ./nginx/noeldemartin.social.conf ./public mastodon
nginx-agora enable mastodon
```

And configure backups with [rireki](https://github.com/noelDeMartin/rireki) using the following config in `~/.rireki/projects/mastodon.conf`:

```toml
name = "mastodon"

[driver]
name = "custom"
frequency = 10080
timeout = 600
command = "/var/www/mastodon/scripts/backup.sh"

[store]
name = "local"
path = "/var/www/Backups/mastodon"
```

That should be all!

## Updates

In order to upgrade Mastodon's version, it should suffice with updating the version in [the Dockerfile](./Dockerfile) and updating the code in the server:

```sh
git pull
docker compose build
docker compose down
docker compose run --rm web bundle exec rails db:migrate
docker compose up -d
```

## Health checks

Using the [prune-data.sh](./scripts/prune-data.sh) and [prune-accounts.sh](./scripts/prune-accounts.sh) scripts should be enough to keep the system in check, but once in a blue moon I'll run some of these commands:

```sh
# Check server memory usage
free -h # ram
df -h # disk
htop # ram & CPU

# Check media size
sudo du -hs ./public/system

# Prune extra data
docker compose exec -T web tootctl statuses remove
docker compose exec -T web tootctl accounts cull
```
