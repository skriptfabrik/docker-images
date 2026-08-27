# @skriptfabrik/docker-images/infisical

Customized [Infisical](https://infisical.com/) image based on the official
[`infisical/infisical`](https://hub.docker.com/r/infisical/infisical) image.

The image version follows the upstream `infisical/infisical` version pinned in the
[Dockerfile](Dockerfile) (`FROM infisical/infisical:<version>`); this is also what CI uses
to derive the published image tags (see the [root README](../../README.md#continuous-integration)).

## Changes over the upstream image

- **[`fileenv`](https://github.com/skriptfabrik/fileenv) entrypoint wrapper** – the
  `fileenv` binary is copied in from the
  [`ghcr.io/skriptfabrik/fileenv`](https://github.com/skriptfabrik/fileenv) image and set
  as `ENTRYPOINT`, wrapping the container startup. Before starting the application,
  `fileenv` resolves any `<VAR>_FILE` environment variable into its corresponding `<VAR>`
  variable by reading the referenced file's contents (and unsets the `_FILE` variable
  afterwards) — this lets secrets (e.g. database credentials, the encryption key) be
  supplied via mounted files or Docker/Swarm secrets instead of plain environment
  variables, without requiring any change in Infisical itself.
- **Custom entrypoint for connection string assembly** – [docker-entrypoint.sh](docker-entrypoint.sh)
  wraps the upstream `standalone-entrypoint.sh` (set as `CMD`) and, before handing off to
  it, derives `DB_CONNECTION_URI` from `DB_USER`/`DB_PASSWORD`/`DB_HOST`/`DB_PORT`/`DB_NAME`
  and `REDIS_URL` from `REDIS_USER`/`REDIS_PASSWORD`/`REDIS_HOST`/`REDIS_PORT` when those
  aren't already set, so Postgres and Redis can be configured via individual parts instead
  of a single connection string.

## Environment variables

| Variable            | Default     | Description                                                                                                                                                                  |
| ------------------- | ----------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `DB_CONNECTION_URI` | _(unset)_   | Full Postgres connection string used by Infisical. If unset and `DB_USER`, `DB_PASSWORD`, and `DB_NAME` are all set, it's derived from those plus `DB_HOST`/`DB_PORT` below. |
| `DB_USER`           | _(unset)_   | Postgres username, used to derive `DB_CONNECTION_URI` when it's unset.                                                                                                       |
| `DB_PASSWORD`       | _(unset)_   | Postgres password, used to derive `DB_CONNECTION_URI` when it's unset.                                                                                                       |
| `DB_HOST`           | `localhost` | Postgres host, used to derive `DB_CONNECTION_URI` when it's unset.                                                                                                           |
| `DB_PORT`           | `5432`      | Postgres port, used to derive `DB_CONNECTION_URI` when it's unset.                                                                                                           |
| `DB_NAME`           | _(unset)_   | Postgres database name, used to derive `DB_CONNECTION_URI` when it's unset.                                                                                                  |
| `REDIS_URL`         | _(unset)_   | Full Redis connection string used by Infisical. If unset, it's derived from `REDIS_HOST`/`REDIS_PORT` below and, if set, `REDIS_USER`/`REDIS_PASSWORD`.                      |
| `REDIS_USER`        | _(unset)_   | Optional Redis username, used to derive `REDIS_URL` when it's unset.                                                                                                         |
| `REDIS_PASSWORD`    | _(unset)_   | Optional Redis password, used to derive `REDIS_URL` when it's unset.                                                                                                         |
| `REDIS_HOST`        | `localhost` | Redis host, used to derive `REDIS_URL` when it's unset.                                                                                                                      |
| `REDIS_PORT`        | `6379`      | Redis port, used to derive `REDIS_URL` when it's unset.                                                                                                                      |

Any environment variable Infisical supports (e.g. `ENCRYPTION_KEY`, `AUTH_SECRET`,
`SITE_URL`) can alternatively be supplied as `<VAR>_FILE` to have it resolved from a file
at startup, see above. Refer to the
[official Infisical documentation](https://infisical.com/docs/self-hosting/configuration/envars)
for these and other supported environment variables — this image does not change
Infisical's runtime behavior beyond the `fileenv`-based secret resolution and the
connection string assembly described above.

## Usage

```sh
docker run -it --rm \
  -p 8080:8080 \
  -e ENCRYPTION_KEY_FILE=/run/secrets/encryption_key \
  -e AUTH_SECRET_FILE=/run/secrets/auth_secret \
  -e SITE_URL=http://localhost:8080 \
  -e DB_USER=infisical \
  -e DB_PASSWORD_FILE=/run/secrets/db_password \
  -e DB_HOST=postgres \
  -e DB_NAME=infisical \
  -e REDIS_HOST=redis \
  -v ./encryption_key:/run/secrets/encryption_key:ro \
  -v ./auth_secret:/run/secrets/auth_secret:ro \
  -v ./db_password:/run/secrets/db_password:ro \
  ghcr.io/skriptfabrik/docker-images/infisical:latest
```
