# @skriptfabrik/docker-images/pocket-id

Customized [Pocket ID](https://pocket-id.org/) image based on the official
[`pocketid/pocket-id`](https://hub.docker.com/r/pocketid/pocket-id) image.

The image version follows the upstream `pocketid/pocket-id` version pinned in the
[Dockerfile](Dockerfile) (`FROM pocketid/pocket-id:<version>`); this is also what CI uses
to derive the published image tags (see the
[root README](../../README.md#continuous-integration)).

## Changes over the upstream image

Pocket ID expects its PostgreSQL database to be configured as a single
`DB_CONNECTION_STRING` rather than individual components, which makes it impossible to
supply the database password as a separate secret file.

- **[fileenv](https://github.com/skriptfabrik/fileenv) support** – `/usr/local/bin/fileenv`
  is the first `ENTRYPOINT` step and resolves every `<VAR>_FILE` environment variable into
  `<VAR>` (reading the referenced file's contents and unsetting the `_FILE` variable
  afterwards) — this lets secrets such as `DB_PASSWORD` be supplied via mounted
  files or Docker/Swarm secrets. The `_FILE` variables Pocket ID already natively resolves
  — `DB_CONNECTION_STRING_FILE`, `ENCRYPTION_KEY_FILE`, `LDAP_BIND_PASSWORD_FILE`,
  `MAXMIND_LICENSE_KEY_FILE`, `S3_SECRET_ACCESS_KEY_FILE`, `SMTP_PASSWORD_FILE`, and
  `STATIC_API_KEY_FILE` — are excluded from `fileenv` via `FILEENV_EXCLUDE` and left to
  Pocket ID. The same applies to `TLS_CERT_FILE` and `TLS_KEY_FILE`, whose values are
  certificate/key file paths consumed as such by Pocket ID rather than secret references.
- **[docker-entrypoint.sh](docker-entrypoint.sh) `DB_CONNECTION_STRING` builder** – runs
  after `fileenv` and in front of the upstream `/app/docker/entrypoint.sh` (kept, so its
  `PUID`/`PGID` handling still applies), wrapping the original Pocket ID startup command
  (kept as `CMD`). Before starting the application, it assembles `DB_CONNECTION_STRING`
  from `DB_USER`, `DB_PASSWORD` (or `DB_PASSWORD_FILE` via `fileenv`), and `DB_NAME`
  (all required) when `DB_CONNECTION_STRING` isn't already set, optionally using
  `DB_HOST` (default `localhost`) and `DB_PORT` (default `5432`). The database password
  is embedded into the assembled `postgresql://` connection string as-is (it is not
  URL-encoded, so avoid characters such as `@`, `:`, `/`, or `%` in it) — this lets the
  database credentials be supplied as separate variables/secrets instead of having to
  construct the full connection string (including the password) by hand. If
  `DB_CONNECTION_STRING` is already set, or any of the required variables is missing, it
  is left untouched and Pocket ID falls back to its default behavior (e.g. the built-in
  SQLite database). Note that `DB_CONNECTION_STRING_FILE`, if set, always takes
  precedence over `DB_CONNECTION_STRING` in Pocket ID.

## Usage

```sh
docker run -it --rm \
  -p 1411:1411 \
  -e APP_URL=https://id.example.com \
  -e ENCRYPTION_KEY_FILE=/run/secrets/encryption_key \
  -e DB_USER=pocket-id \
  -e DB_PASSWORD_FILE=/run/secrets/database_password \
  -e DB_NAME=pocket-id \
  -e DB_HOST=postgres \
  -v ./encryption_key:/run/secrets/encryption_key:ro \
  -v ./database_password:/run/secrets/database_password:ro \
  -v pocket-id-data:/app/data \
  ghcr.io/skriptfabrik/docker-images/pocket-id:latest
```

Refer to the [official Pocket ID documentation](https://pocket-id.org/docs/configuration/environment-variables)
for environment variables, volumes, and general configuration — this image does not change
Pocket ID's runtime behavior beyond the `fileenv` resolution and `DB_CONNECTION_STRING`
assembly described above.
