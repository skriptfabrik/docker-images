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
  in `ENTRYPOINT` after the upstream `tini` (kept for proper signal handling/zombie
  reaping), invoking [docker-entrypoint.sh](docker-entrypoint.sh) directly. Before
  starting the application, `fileenv` resolves any `<VAR>_FILE` environment variable into
  its corresponding `<VAR>` variable by reading the referenced file's contents (and unsets
  the `_FILE` variable afterwards) — this lets secrets (e.g. `SEMAPHORE_COOKIE_HASH`,
  `SEMAPHORE_COOKIE_ENCRYPTION`) be supplied via mounted files or Docker/Swarm secrets
  instead of plain environment variables, without requiring any change in Semaphore
  itself. The `_FILE` variables the upstream `server-wrapper` (kept as `CMD`) already
  natively resolves — `SEMAPHORE_ACCESS_KEY_ENCRYPTION_FILE`, `SEMAPHORE_ADMIN_FILE`,
  `SEMAPHORE_ADMIN_PASSWORD_FILE`, `SEMAPHORE_DB_PASS_FILE`, `SEMAPHORE_DB_USER_FILE`,
  and `SEMAPHORE_LDAP_PASSWORD_FILE` — are excluded from `fileenv` via
  `FILEENV_EXCLUDE` and left to `server-wrapper`. The same applies to the `_FILE`
  variables whose value is a file path consumed as such by `server-wrapper` or Semaphore
  itself rather than a secret reference — `SEMAPHORE_ENCRYPTION_KEYS_FILE`,
  `SEMAPHORE_IMPORT_PROJECT_FILE`, `SEMAPHORE_RUNNER_REGISTRATION_TOKEN_FILE`,
  `SEMAPHORE_RUNNER_SERVER_CA_CERT_FILE`, `SEMAPHORE_RUNNER_TOKEN_FILE`,
  `SEMAPHORE_SUBSCRIPTION_KEY_FILE`, `SEMAPHORE_TLS_CERT_FILE`, and
  `SEMAPHORE_TLS_KEY_FILE` — so they are passed through unchanged.
- **[docker-entrypoint.sh](docker-entrypoint.sh) `requirements.yml` writer** – invoked by
  `fileenv`, wrapping the original startup command (kept as `CMD`). Before starting the
  application, if `SEMAPHORE_REQUIREMENTS` is set, it writes that variable's content to
  `/etc/semaphore/requirements.yml` (the file used to install additional Ansible
  collections/roles at startup) — this lets that file's content be supplied via an
  environment variable instead of having to bind-mount it. Since `fileenv` runs first,
  `SEMAPHORE_REQUIREMENTS_FILE` can be used to read that content from a file as well.

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
  -e SEMAPHORE_COOKIE_HASH_FILE=/run/secrets/cookie_hash \
  -e SEMAPHORE_COOKIE_ENCRYPTION_FILE=/run/secrets/cookie_encryption \
  -v ./db_password:/run/secrets/db_password:ro \
  -v ./admin_password:/run/secrets/admin_password:ro \
  -v ./cookie_hash:/run/secrets/cookie_hash:ro \
  -v ./cookie_encryption:/run/secrets/cookie_encryption:ro \
  ghcr.io/skriptfabrik/docker-images/semaphore:latest
```

Refer to the [official Semaphore documentation](https://docs.semaphoreui.com/) for
environment variables, volumes, and general configuration — this image does not change
Semaphore's runtime behavior beyond the `_FILE` resolution and `requirements.yml` writer
described above.
