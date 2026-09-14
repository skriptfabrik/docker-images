# @skriptfabrik/docker-images/postgres

Customized [PostgreSQL](https://www.postgresql.org/) image based on the official
[`postgres`](https://hub.docker.com/_/postgres) image, with the
[pgvector](https://github.com/pgvector/pgvector) extension installed from the official PGDG
APT repository.

The image version follows the upstream `postgres` version pinned in the
[Dockerfile](Dockerfile) (`FROM postgres:<version>`); this is also what CI uses to derive
the published image tag (see the [root README](../../README.md#continuous-integration)).

## Purpose

This image exists specifically to satisfy [Formbricks'](https://formbricks.com/) requirement
for the PostgreSQL `vector` extension (required since Formbricks v2.7; see
[skriptfabrik/docker-images#114](https://github.com/skriptfabrik/docker-images/issues/114)).
The official Formbricks `docker-compose.yml` uses `pgvector/pgvector:pg18` for its Postgres
service instead of plain `postgres`.

**This is not a general-purpose Postgres replacement image.** It exists solely to add the
`vector` extension on top of the exact `postgres:18.6` patch version already running
elsewhere, so a single shared Postgres instance can serve Formbricks alongside other
databases without switching that instance to a different, more loosely version-pinned base
image (`pgvector/pgvector:pg18` tracks only the Postgres _major_ version, not the exact patch
release) or maintaining a from-source `pgvector` build. Unless you specifically need the
`vector` extension, use the official [`postgres`](https://hub.docker.com/_/postgres) image
instead.

## Changes over the upstream image

- **`vector` extension via the PGDG APT repository** – the
  [PostgreSQL APT repository](https://wiki.postgresql.org/wiki/Apt) signing key is imported
  and added as an `apt` source for the Debian release the base image is built on (detected
  from `/etc/os-release` at build time, not hardcoded), then `postgresql-18-pgvector` is
  installed from it at a pinned version. This installs a precompiled `pgvector` build
  matching the exact PostgreSQL major version — no build toolchain, no `-march=native`
  portability concerns, since the PGDG package ships precompiled for both `amd64` and
  `arm64` — while keeping the exact `postgres:18.6` patch version unchanged.
- Build-time-only tools (`curl`, `gnupg`) used to fetch and verify the PGDG signing key are
  removed again after installing the extension package; `ca-certificates` is kept.

## Usage

The `vector` extension is installed but not enabled by default — enable it per database
after starting the container, like any other Postgres extension:

```sh
docker run -it --rm \
  -e POSTGRES_PASSWORD_FILE=/run/secrets/postgres_password \
  -v ./postgres_password:/run/secrets/postgres_password:ro \
  -v pgdata:/var/lib/postgresql/data \
  ghcr.io/skriptfabrik/docker-images/postgres:latest
```

```sql
CREATE EXTENSION vector;
```

Refer to the [official `postgres` image documentation](https://hub.docker.com/_/postgres)
for environment variables and general configuration — this image does not change Postgres'
runtime behavior beyond adding the `vector` extension package described above. Note that
`POSTGRES_PASSWORD_FILE` and other `_FILE`-suffixed variables above are handled natively by
the official `postgres` entrypoint, not by `fileenv` — this image doesn't add `fileenv`.
