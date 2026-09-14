# @skriptfabrik/docker-images/formbricks

Customized [Formbricks](https://formbricks.com/) images based on the official
[`ghcr.io/formbricks/formbricks`](https://github.com/formbricks/formbricks/pkgs/container/formbricks)
and [`ghcr.io/formbricks/hub`](https://github.com/formbricks/formbricks/pkgs/container/hub)
images.

This context builds two separate images from two Dockerfiles:

- [Dockerfile](Dockerfile) – the Formbricks main application (Next.js app), published as
  `formbricks`.
- [Dockerfile.hub](Dockerfile.hub) – the Formbricks Hub API, published as `formbricks-hub`.

Each image's version follows the upstream `formbricks/formbricks`/`formbricks/hub` version
pinned in its Dockerfile (`FROM ghcr.io/formbricks/<formbricks|hub>:<version>`); this is
also what CI uses to derive the published image tags for each image separately (see the
[root README](../../README.md#continuous-integration)).

## Changes over the upstream images

- **[`fileenv`](https://github.com/skriptfabrik/fileenv) entrypoint wrapper** – the
  `fileenv` binary is copied in from the
  [`ghcr.io/skriptfabrik/fileenv`](https://github.com/skriptfabrik/fileenv) image and set
  as the first `ENTRYPOINT` argument, invoking [docker-entrypoint.sh](docker-entrypoint.sh)
  (see below) with the original startup command passed through as `CMD`. Before invoking
  `docker-entrypoint.sh`, `fileenv` resolves any `<VAR>_FILE` environment variable into its
  corresponding `<VAR>` variable by reading the referenced file's contents (and unsets the
  `_FILE` variable afterwards) — this lets secrets (e.g. database credentials) be supplied
  via mounted files or Docker/Swarm secrets instead of plain environment variables, without
  requiring any change in Formbricks itself.

- **[docker-entrypoint.sh](docker-entrypoint.sh) connection URL builder** – shared by both
  images, runs after `fileenv` and before the original startup command (`CMD`), and
  assembles `DATABASE_URL` from `DATABASE_USER`, `DATABASE_PASSWORD`, `DATABASE_NAME`
  (required), and optionally `DATABASE_HOST` (default `localhost`) and `DATABASE_PORT`
  (default `5432`) when it isn't already set. This lets the database credentials be
  supplied as separate variables (e.g. via `_FILE`-suffixed secrets resolved by `fileenv`
  above) instead of having to construct the full connection string by hand. If `DATABASE_URL`
  is already set, it is left untouched. **Note: components are not URL-encoded; database
  credentials must not contain URL-reserved characters (`@`, `:`, `/`, `?`, `#`) since they
  are not percent-encoded when composing `DATABASE_URL` — set the full `DATABASE_URL`
  instead (or percent-encode the component values) if they do.**

- **Original entrypoint preserved and re-invoked** – the `formbricks` image's own upstream
  `/usr/local/bin/docker-entrypoint.sh` (a generic Node.js startup script that runs the
  given command through `node` if it isn't otherwise executable) is renamed to
  `/usr/local/bin/original-docker-entrypoint.sh` during the build. After assembling
  `DATABASE_URL`, [docker-entrypoint.sh](docker-entrypoint.sh) `exec`s into this renamed
  original script if present, which in turn runs the actual `CMD`. This keeps the upstream
  `formbricks` image's own startup logic intact instead of silently dropping it. The `hub`
  image has no such original entrypoint script, so this is a no-op there and
  `docker-entrypoint.sh` `exec`s the `CMD` directly.

## Environment variables

| Variable            | Default     | Description                                                                                                                                                                                                     |
| ------------------- | ----------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `DATABASE_URL`      | _(unset)_   | Full Postgres connection string used by Formbricks/Hub. If unset and `DATABASE_USER`, `DATABASE_PASSWORD`, and `DATABASE_NAME` are all set, it's derived from those plus `DATABASE_HOST`/`DATABASE_PORT` below. |
| `DATABASE_USER`     | _(unset)_   | Postgres username, used to derive `DATABASE_URL` when it's unset.                                                                                                                                               |
| `DATABASE_PASSWORD` | _(unset)_   | Postgres password, used to derive `DATABASE_URL` when it's unset.                                                                                                                                               |
| `DATABASE_HOST`     | `localhost` | Postgres host, used to derive `DATABASE_URL` when it's unset.                                                                                                                                                   |
| `DATABASE_PORT`     | `5432`      | Postgres port, used to derive `DATABASE_URL` when it's unset.                                                                                                                                                   |
| `DATABASE_NAME`     | _(unset)_   | Postgres database name, used to derive `DATABASE_URL` when it's unset.                                                                                                                                          |

Any environment variable Formbricks/Hub supports (e.g. `NEXTAUTH_SECRET`, `ENCRYPTION_KEY`,
`CRON_SECRET`) can alternatively be supplied as `<VAR>_FILE` to have it resolved from a file
at startup, see above. Refer to the
[official Formbricks self-hosting documentation](https://formbricks.com/docs/self-hosting/overview)
for these and other supported environment variables — these images do not change
Formbricks' runtime behavior beyond the connection URL default and `fileenv`-based secret
resolution described above.

## Usage

```sh
docker run -it --rm \
  -p 3000:3000 \
  -e DATABASE_USER=formbricks \
  -e DATABASE_PASSWORD_FILE=/run/secrets/database_password \
  -e DATABASE_NAME=formbricks \
  -e DATABASE_HOST=postgres \
  -e NEXTAUTH_SECRET_FILE=/run/secrets/nextauth_secret \
  -e ENCRYPTION_KEY_FILE=/run/secrets/encryption_key \
  -v ./database_password:/run/secrets/database_password:ro \
  -v ./nextauth_secret:/run/secrets/nextauth_secret:ro \
  -v ./encryption_key:/run/secrets/encryption_key:ro \
  ghcr.io/skriptfabrik/docker-images/formbricks:latest
```

```sh
docker run -it --rm \
  -p 8080:8080 \
  -e DATABASE_USER=formbricks \
  -e DATABASE_PASSWORD_FILE=/run/secrets/database_password \
  -e DATABASE_NAME=formbricks \
  -e DATABASE_HOST=postgres \
  -v ./database_password:/run/secrets/database_password:ro \
  ghcr.io/skriptfabrik/docker-images/formbricks-hub:latest
```

Refer to the
[official Formbricks self-hosting documentation](https://formbricks.com/docs/self-hosting/overview)
for the full set of environment variables and general configuration.
