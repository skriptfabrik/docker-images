# @skriptfabrik/docker-images/kaneo

Customized [Kaneo](https://kaneo.app/) image based on the official
[`usekaneo/kaneo`](https://github.com/usekaneo/kaneo/pkgs/container/kaneo) image.

The image version follows the upstream `ghcr.io/usekaneo/kaneo` version pinned in the
[Dockerfile](Dockerfile) (`FROM ghcr.io/usekaneo/kaneo:<version>`); this is also what CI
uses to derive the published image tags (see the
[root README](../../README.md#continuous-integration)).

## Changes over the upstream image

- **[`fileenv`](https://github.com/skriptfabrik/fileenv) entrypoint wrapper** – the
  `fileenv` binary is copied in from the
  [`ghcr.io/skriptfabrik/fileenv`](https://github.com/skriptfabrik/fileenv) image and set
  as `ENTRYPOINT`, wrapping the original `kaneo-entrypoint.sh` startup command (kept as
  `CMD`). Before starting the application, `fileenv` resolves any `<VAR>_FILE` environment
  variable into its corresponding `<VAR>` variable by reading the referenced file's
  contents (and unsets the `_FILE` variable afterwards) — this lets secrets (e.g.
  `POSTGRES_PASSWORD`, `AUTH_SECRET`) be supplied via mounted files or Docker/Swarm secrets
  instead of plain environment variables, without requiring any change in Kaneo itself.

## Usage

```sh
docker run -it --rm \
  -p 5173:5173 \
  -e KANEO_CLIENT_URL=http://localhost:5173 \
  -e POSTGRES_HOST=postgres \
  -e POSTGRES_DB=kaneo \
  -e POSTGRES_USER=kaneo \
  -e POSTGRES_PASSWORD_FILE=/run/secrets/postgres_password \
  -e AUTH_SECRET_FILE=/run/secrets/auth_secret \
  -v ./postgres_password:/run/secrets/postgres_password:ro \
  -v ./auth_secret:/run/secrets/auth_secret:ro \
  ghcr.io/skriptfabrik/docker-images/kaneo:latest
```

Refer to the
[official Kaneo environment variables documentation](https://kaneo.app/docs/core/installation/environment-variables)
for `POSTGRES_*`/`DATABASE_URL`, `AUTH_SECRET`, `KANEO_CLIENT_URL`, and other supported
environment variables, volumes, and general configuration — this image does not change
Kaneo's runtime behavior beyond the `fileenv`-based secret resolution described above. Any
environment variable Kaneo supports can alternatively be supplied as `<VAR>_FILE` to have
it resolved from a file at startup.
