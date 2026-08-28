# @skriptfabrik/docker-images/plane

Customized [Plane](https://plane.so/) images based on the official
[`makeplane/plane-backend`](https://hub.docker.com/r/makeplane/plane-backend) and
[`makeplane/plane-live`](https://hub.docker.com/r/makeplane/plane-live) images.

This context builds two separate images from two Dockerfiles:

- [Dockerfile.backend](Dockerfile.backend) – the Plane backend (API server by default),
  published as `plane-backend`.
- [Dockerfile.live](Dockerfile.live) – the Plane live collaboration server (powers the
  real-time rich text editor), published as `plane-live`.

Each image's version follows the upstream `makeplane/plane-backend`/`makeplane/plane-live`
version pinned in its Dockerfile (`FROM makeplane/<plane-backend|plane-live>:<version>`);
this is also what CI uses to derive the published image tags for each image separately
(see the [root README](../../README.md#continuous-integration)).

## Changes over the upstream images

- **[`fileenv`](https://github.com/skriptfabrik/fileenv) entrypoint wrapper** – the
  `fileenv` binary is copied in from the
  [`ghcr.io/skriptfabrik/fileenv`](https://github.com/skriptfabrik/fileenv) image and set
  as the first `ENTRYPOINT` argument, invoking
  [docker-entrypoint.sh](docker-entrypoint.sh) (see below) with the original startup
  command passed through as `CMD`. Before invoking `docker-entrypoint.sh`, `fileenv`
  resolves any `<VAR>_FILE` environment variable into its corresponding `<VAR>` variable
  by reading the referenced file's contents (and unsets the `_FILE` variable afterwards)
  — this lets secrets (e.g. database credentials, the `SECRET_KEY`,
  `LIVE_SERVER_SECRET_KEY`) be supplied via mounted files or Docker/Swarm secrets instead
  of plain environment variables, without requiring any change in Plane itself.

- **[docker-entrypoint.sh](docker-entrypoint.sh) connection URL builder** – shared by both
  images, runs after `fileenv` and before the original startup command (`CMD`), and
  assembles `AMQP_URL`, `DATABASE_URL`, and `REDIS_URL` from their individual component
  variables when the combined URL isn't already set:
  - `AMQP_URL` from `RABBITMQ_USER`, `RABBITMQ_PASSWORD`, `RABBITMQ_VHOST` (required), and
    optionally `RABBITMQ_HOST` (default `localhost`) and `RABBITMQ_PORT` (default `5672`).
  - `DATABASE_URL` from `DATABASE_USER`, `DATABASE_PASSWORD`, `DATABASE_NAME` (required),
    and optionally `DATABASE_HOST` (default `localhost`) and `DATABASE_PORT` (default
    `5432`).
  - `REDIS_URL` from optionally `REDIS_USER`/`REDIS_PASSWORD`, `REDIS_HOST` (default
    `localhost`), and `REDIS_PORT` (default `6379`).

This lets each connection's credentials be supplied as separate variables (e.g. via
`_FILE`-suffixed secrets resolved by `fileenv` above) instead of having to construct the
full connection URL by hand. If a `*_URL` variable is already set, it is left untouched. Note: components are not URL-encoded; if a username/password/vhost contains reserved characters, set the full `*_URL` instead (or percent-encode the component values).

## Usage

```sh
docker run -it --rm \
  -p 8000:8000 \
  -e DATABASE_USER=plane \
  -e DATABASE_PASSWORD_FILE=/run/secrets/database_password \
  -e DATABASE_NAME=plane \
  -e DATABASE_HOST=postgres \
  -e REDIS_HOST=redis \
  -e RABBITMQ_USER=plane \
  -e RABBITMQ_PASSWORD_FILE=/run/secrets/rabbitmq_password \
  -e RABBITMQ_VHOST=plane \
  -e RABBITMQ_HOST=rabbitmq \
  -e SECRET_KEY_FILE=/run/secrets/secret_key \
  -v ./database_password:/run/secrets/database_password:ro \
  -v ./rabbitmq_password:/run/secrets/rabbitmq_password:ro \
  -v ./secret_key:/run/secrets/secret_key:ro \
  ghcr.io/skriptfabrik/docker-images/plane-backend:latest
```

The `plane-backend` image runs as the Plane API server by default
(`docker-entrypoint-api.sh`). It also covers the other backend roles (worker, beat-worker,
migrator), which are run by overriding `CMD` with the corresponding
`bin/docker-entrypoint-*.sh` script.

```sh
docker run -it --rm \
  -p 3100:3100 \
  -e API_BASE_URL=http://plane-backend:8000 \
  -e WEB_BASE_URL=https://plane.example.com \
  -e LIVE_SERVER_SECRET_KEY_FILE=/run/secrets/live_server_secret_key \
  -e REDIS_HOST=redis \
  -v ./live_server_secret_key:/run/secrets/live_server_secret_key:ro \
  ghcr.io/skriptfabrik/docker-images/plane-live:latest
```

The `plane-live` image only uses the `docker-entrypoint.sh` `REDIS_URL` defaulting
described above (it has no database/AMQP connections of its own); `AMQP_URL`/
`DATABASE_URL` are only relevant to `plane-backend`.

Refer to the
[official Plane self-hosting documentation](https://developers.plane.so/self-hosting/overview)
for environment variables and general configuration — these images do not change Plane's
runtime behavior beyond the connection URL defaults and `fileenv`-based secret resolution
described above. Any environment variable Plane supports can alternatively be supplied as
`<VAR>_FILE` to have it resolved from a file at startup.
