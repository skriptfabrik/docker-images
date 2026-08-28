# @skriptfabrik/docker-images/semaphore

Customized [Semaphore](https://semaphoreui.com/) image based on the official
[`semaphoreui/semaphore`](https://hub.docker.com/r/semaphoreui/semaphore) image.

The image version follows the upstream `semaphoreui/semaphore` version pinned in the
[Dockerfile](Dockerfile) (`FROM semaphoreui/semaphore:<version>`); this is also what CI
uses to derive the published image tags (see the
[root README](../../README.md#continuous-integration)).

## Changes over the upstream image

- **[`fileenv`](https://github.com/skriptfabrik/fileenv) entrypoint wrapper** – the
  `fileenv` binary is copied in from the
  [`ghcr.io/skriptfabrik/fileenv`](https://github.com/skriptfabrik/fileenv) image and set
  as the first `ENTRYPOINT` argument, invoking the upstream `tini` (kept for proper signal
  handling/zombie reaping) which in turn runs
  [docker-entrypoint.sh](docker-entrypoint.sh) (see below) with the original startup
  command passed through as `CMD`. Before that, `fileenv` resolves any `<VAR>_FILE`
  environment variable into its corresponding `<VAR>` variable by reading the referenced
  file's contents (and unsets the `_FILE` variable afterwards) — this lets secrets (e.g.
  `SEMAPHORE_ADMIN_PASSWORD`, `SEMAPHORE_DB_PASS`, `SEMAPHORE_COOKIE_HASH`,
  `SEMAPHORE_COOKIE_ENCRYPTION`, `SEMAPHORE_ACCESS_KEY_ENCRYPTION`) be supplied via
  mounted files or Docker/Swarm secrets instead of plain environment variables, without
  requiring any change in Semaphore itself.

- **[docker-entrypoint.sh](docker-entrypoint.sh) `requirements.yml` writer** – runs before
  the original startup command (`CMD`), and, if `SEMAPHORE_REQUIREMENTS` is set, writes
  its content to `/etc/semaphore/requirements.yml` (the file used to install additional
  Ansible collections/roles at startup) — this lets that file's content be supplied via an
  environment variable instead of having to bind-mount it.

## Usage

```sh
docker run -it --rm \
  -p 3000:3000 \
  -e SEMAPHORE_DB_DIALECT=postgres \
  -e SEMAPHORE_DB_HOST=postgres \
  -e SEMAPHORE_DB_USER=semaphore \
  -e SEMAPHORE_DB_PASS_FILE=/run/secrets/db_password \
  -e SEMAPHORE_DB=semaphore \
  -e SEMAPHORE_ADMIN=admin \
  -e SEMAPHORE_ADMIN_PASSWORD_FILE=/run/secrets/admin_password \
  -e SEMAPHORE_ADMIN_NAME=Admin \
  -e SEMAPHORE_ADMIN_EMAIL=admin@localhost \
  -v ./db_password:/run/secrets/db_password:ro \
  -v ./admin_password:/run/secrets/admin_password:ro \
  ghcr.io/skriptfabrik/docker-images/semaphore:latest
```

Refer to the [official Semaphore documentation](https://docs.semaphoreui.com/) for
environment variables, volumes, and general configuration — this image does not change
Semaphore's runtime behavior beyond the `requirements.yml` writer and `fileenv`-based
secret resolution described above. Any environment variable Semaphore supports can
alternatively be supplied as `<VAR>_FILE` to have it resolved from a file at startup.
