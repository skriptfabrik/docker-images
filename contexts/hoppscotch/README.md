# @skriptfabrik/docker-images/hoppscotch

Customized [Hoppscotch](https://hoppscotch.io/) image based on the official
[`hoppscotch/hoppscotch`](https://hub.docker.com/r/hoppscotch/hoppscotch) image.

The image version follows the upstream `hoppscotch/hoppscotch` version pinned in the
[Dockerfile](Dockerfile) (`FROM hoppscotch/hoppscotch:<version>`); this is also what CI
uses to derive the published image tags (see the
[root README](../../README.md#continuous-integration)).

## Changes over the upstream image

- **[`fileenv`](https://github.com/skriptfabrik/fileenv) entrypoint wrapper** – the
  `fileenv` binary is copied in from the
  [`ghcr.io/skriptfabrik/fileenv`](https://github.com/skriptfabrik/fileenv) image and set
  as the first `ENTRYPOINT` argument, invoking
  [docker-entrypoint.sh](docker-entrypoint.sh) (see below) with the original startup
  command passed through as `CMD`. Before invoking `docker-entrypoint.sh`, `fileenv`
  resolves any `<VAR>_FILE` environment variable into its corresponding `<VAR>` variable
  by reading the referenced file's contents (and unsets the `_FILE` variable afterwards)
  — this lets secrets (e.g. database credentials) be supplied via mounted files or
  Docker/Swarm secrets instead of plain environment variables, without requiring any
  change in Hoppscotch itself.

- **[docker-entrypoint.sh](docker-entrypoint.sh) `DATABASE_URL` builder** – runs after
  `fileenv` and before the original startup command (`CMD`), and assembles `DATABASE_URL`
  from `DATABASE_USER`, `DATABASE_PASSWORD`, and `DATABASE_NAME` (required) when
  `DATABASE_URL` isn't already set, optionally using `DATABASE_HOST` (default
  `localhost`) and `DATABASE_PORT` (default `5432`). This lets the database credentials
  be supplied as separate variables (e.g. via `_FILE`-suffixed secrets resolved by
  `fileenv` above) instead of having to construct the full connection URL by hand. If
  `DATABASE_URL` is already set, it is left untouched.

## Usage

```sh
docker run -it --rm \
  -p 3000:3000 \
  -e DATABASE_USER=hoppscotch \
  -e DATABASE_PASSWORD_FILE=/run/secrets/database_password \
  -e DATABASE_NAME=hoppscotch \
  -e DATABASE_HOST=postgres \
  -v ./database_password:/run/secrets/database_password:ro \
  ghcr.io/skriptfabrik/docker-images/hoppscotch:latest
```

Refer to the [official Hoppscotch documentation](https://docs.hoppscotch.io/) for
environment variables, volumes, and general configuration — this image does not change
Hoppscotch's runtime behavior beyond the `DATABASE_URL` assembly and `fileenv`-based
secret resolution described above. Any environment variable Hoppscotch supports can
alternatively be supplied as `<VAR>_FILE` to have it resolved from a file at startup.
