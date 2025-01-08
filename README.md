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
30 5 * * 1 /var/www/mastodon/prune-data.sh >> /var/log/cron-mastodon.log 2>> /var/log/cron-mastodon.log
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
path = "/var/www/Backups/"
```

That should be all!

## Health checks

Using the [prune-data.sh](./scripts/prune-data.sh) script should be enough to keep the system in check, but I've found Mastodon to be particularly storage heavy (at least for an instance-of-one). Previously, [I resorted to deleting all media manually](https://github.com/NoelDeMartin/mastodon/blob/e02f0e037bd777e560420742886914d26e6379f1/clear-accounts.sh), but it seems like new versions have improved storage management and that shouldn't be necessary any more.

Still, once in a blue moon, I'll run some of these commands:

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
