# @skriptfabrik/docker-images/outline

Customized [Outline](https://www.getoutline.com/) image based on the official
[`outlinewiki/outline`](https://hub.docker.com/r/outlinewiki/outline) image.

The image version follows the upstream `outlinewiki/outline` version pinned in the
[Dockerfile](Dockerfile) (`FROM outlinewiki/outline:<version>`); this is also what CI uses
to derive the published image tags (see the
[root README](../../README.md#continuous-integration)).

## Changes over the upstream image

Outline already supports resolving `<VAR>_FILE`-suffixed environment variables into their
corresponding secrets natively, so no `fileenv` wrapper is needed here (unlike some of the
other images in this repository). The only gap is `DATABASE_URL`, which Outline requires
as a single connection string rather than individual components.

- **[docker-entrypoint.sh](docker-entrypoint.sh) `DATABASE_URL` builder** – set as
  `ENTRYPOINT`, wrapping the original Outline startup command (kept as `CMD`). Before
  starting the application, it assembles `DATABASE_URL` from `DATABASE_USER`,
  `DATABASE_PASSWORD_FILE`, and `DATABASE_NAME` (all required) when `DATABASE_URL` isn't
  already set, optionally using `DATABASE_HOST` (default `postgres`) and `DATABASE_PORT`
  (default `5432`). The database password is read directly from the file referenced by
  `DATABASE_PASSWORD_FILE` and embedded into the assembled `DATABASE_URL` — this lets the
  database credentials be supplied as separate variables/secrets instead of having to
  construct the full connection URL (including the password) by hand. If `DATABASE_URL` is
  already set, it is left untouched.

## Usage

```sh
docker run -it --rm \
  -p 3000:3000 \
  -e URL=https://outline.example.com \
  -e SECRET_KEY_FILE=/run/secrets/secret_key \
  -e UTILS_SECRET_FILE=/run/secrets/utils_secret \
  -e DATABASE_USER=outline \
  -e DATABASE_PASSWORD_FILE=/run/secrets/database_password \
  -e DATABASE_NAME=outline \
  -e DATABASE_HOST=postgres \
  -e REDIS_URL=redis://redis:6379 \
  -v ./secret_key:/run/secrets/secret_key:ro \
  -v ./utils_secret:/run/secrets/utils_secret:ro \
  -v ./database_password:/run/secrets/database_password:ro \
  ghcr.io/skriptfabrik/docker-images/outline:latest
```

Refer to the [official Outline self-hosting documentation](https://docs.getoutline.com/s/hosting)
for environment variables, volumes, and general configuration — this image does not change
Outline's runtime behavior beyond the `DATABASE_URL` assembly described above. `SECRET_KEY`,
`UTILS_SECRET`, and any other environment variable Outline supports can be supplied as
`<VAR>_FILE` to have it resolved from a file at startup, using Outline's own built-in
support for this — no `fileenv` involved.
