# Mastodon

This repository holds the configuration to serve my instance-of-one Mastodon server at [noeldemartin.social](https://noeldemartin.social). For documentation about how to host your own, or Mastodon in general, check out [the official docs](https://docs.joinmastodon.org/).

## Deployment

These instructions work to migrate an existing application, given that I was running the instance with a different setup for many years.

Start with creating the directory:

```sh
git clone https://github.com/NoelDeMartin/mastodon.git mastodon
cd mastodon
cp .env.production.example .env.production
```

Initialize the following variables in `.env.production`:

- SECRET_KEY_BASE
- OTP_SECRET
- ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY
- ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT
- ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY
- VAPID_PRIVATE_KEY
- VAPID_PUBLIC_KEY
- SMTP_*

Now, upload the backed up files from your local machine:

```sh
rsync -hr --progress --stats ./backup/system user@server:/var/www/mastodon/public/
scp ./backup/dump.sql user@server:/var/www/mastodon/dump.sql
scp ./backup/dump.rdb user@server:/var/www/mastodon/redis/dump.rdb
```

Next, back in the server, restore the database:

```sh
docker compose up -d
docker cp ./dump.sql mastodon-db-1:/dump.sql
docker compose exec db sh -i
psql -U postgres -d postgres < dump.sql
rm dump.sql

# Exit docker shell...

docker compose run web bundle exec rails db:migrate
rm dump.sql
```

Finally, install the site in [nginx-agora](https://github.com/noelDeMartin/nginx-agora):

```sh
nginx-agora install ./nginx/noeldemartin.social.conf ./public mastodon
nginx-agora enable mastodon
```

And you're done!
