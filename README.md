Morsel API
==========

The API for Morsel (https://api.eatmorsel.com) <br />
Valid endpoints available in [API Docs](doc/API-Docs.md) <br />
User Events can be found in [User Events](doc/User-Events.md) <br />

## Built w/
* Hosted on Heroku
* Ruby on Rails (see [Gemfile](Gemfile) for current versions)
* [Unicorn](unicorn.bogomips.org) webserver
* [Sidekiq](https://github.com/mperham/sidekiq) for background jobs
* PostgreSQL v9.3+, with pgbackups
* redis v2.8+ via [openredis.io](openredis.io) and monitored via [redisgreen.net](redisgreen.net)
* memcached via [redislabs.com](redislabs.com)
* Active Admin for the admin dashboard
* S3 for static content/image hosting
* Carrierwave for image processing
* Devise for managing users
* [Mandrill](mandrillapp.com) for sending emails
* [Rollbar](https://rollbar.com) for exception tracking
* [bit.ly](bit.ly) URL shortener
* [Foursquare](foursquare.com) for Place searching/populating
* [New Relic](newrelic.com) for monitoring/pretty graphcs
* [Loggly](loggly.com) for searching and archiving logs to S3
* [Zendesk](zendesk.com) for support emails and users reporting content
* [HireFire](hirefire.io) for auto-scaling dynos up/down

## Environment Variables

```

RACK_ENV=development
PORT=3000

MORSEL_API_URL=https://api.eatmorsel.com
MORSEL_MEDIA_URL=http://media.eatmorsel.com
MORSEL_WEB_URL=https://eatmorsel.com
MORSEL_TWITTER_USERNAME=eatmorsel
MORSEL_SUPPORT_EMAIL_ADDRESS=support@eatmorsel.com
PROFILER_PASSWORD=

DEVELOPER_EMAIL=turdferg@eatmorsel.com
PAGINATION_DEFAULT_COUNT=20

APNS_CERT=
- or -
APNS_CERT_PATH=/path/to/dev/pem

AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
S3_DEFAULT_BUCKET=

BITLY_ACCESS_TOKEN=

FOURSQUARE_CLIENT_ID=
FOURSQUARE_CLIENT_SECRET=
FOURSQUARE_API_VERSION=20130509

MANDRILL_API_KEY=
MANDRILL_USER_NAME=

MEMCACHEDCLOUD_PASSWORD=
MEMCACHEDCLOUD_SERVERS=
MEMCACHEDCLOUD_USERNAME=

NEW_RELIC_LICENSE_KEY
NEW_RELIC_APP_NAME

OPENREDIS_URL=redis://localhost

ROLLBAR_ACCESS_TOKEN=
ROLLBAR_ENDPOINT=

ZENDESK_URL=
ZENDESK_USERNAME=
ZENDESK_TOKEN=

# Social

FACEBOOK_APP_ID=
FACEBOOK_APP_SECRET=

TWITTER_CONSUMER_KEY=
TWITTER_CONSUMER_SECRET=


# OPTIONAL

UNICORN_WORKER_PROCESS_COUNT=2
DB_REAP_FREQ=10
DB_POOL=2
SIDEKIQ_CONCURRENCY=5

HIPCHAT_AUTH_TOKEN=
HIPCHAT_DEFAULT_ROOM=

```
