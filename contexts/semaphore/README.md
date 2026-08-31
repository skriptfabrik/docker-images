# @skriptfabrik/docker-images/semaphore

Customized [Semaphore](https://semaphoreui.com/) image based on the official
[`semaphoreui/semaphore`](https://hub.docker.com/r/semaphoreui/semaphore) image.

The image version follows the upstream `semaphoreui/semaphore` version pinned in the
[Dockerfile](Dockerfile) (`FROM semaphoreui/semaphore:<version>`); this is also what CI
uses to derive the published image tags (see the
[root README](../../README.md#continuous-integration)).

## Changes over the upstream image

- **[docker-entrypoint.sh](docker-entrypoint.sh) `requirements.yml` writer** – set after
  the upstream `tini` in `ENTRYPOINT` (kept for proper signal handling/zombie reaping),
  wrapping the original startup command (kept as `CMD`). Before starting the application,
  if `SEMAPHORE_REQUIREMENTS` is set, it writes that variable's content to
  `/etc/semaphore/requirements.yml` (the file used to install additional Ansible
  collections/roles at startup) — this lets that file's content be supplied via an
  environment variable instead of having to bind-mount it.

This image intentionally does not wrap the container with
[`fileenv`](https://github.com/skriptfabrik/fileenv) — the upstream `server-wrapper`
(kept as `CMD`) already natively resolves a `<VAR>_FILE`-suffixed environment variable
into its corresponding `<VAR>` by reading the referenced file's contents, for
`SEMAPHORE_DB_USER`, `SEMAPHORE_DB_PASS`, `SEMAPHORE_ADMIN`, `SEMAPHORE_ADMIN_PASSWORD`,
`SEMAPHORE_LDAP_PASSWORD`, and `SEMAPHORE_ACCESS_KEY_ENCRYPTION`, so `fileenv` would only
have been redundant for those. Any other environment variable Semaphore supports (e.g.
`SEMAPHORE_COOKIE_HASH`, `SEMAPHORE_COOKIE_ENCRYPTION`) has no such native `_FILE`
handling and must be supplied as a plain environment variable.

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
Semaphore's runtime behavior beyond the `requirements.yml` writer described above.
