# @skriptfabrik/docker-images/rabbitmq

Customized [RabbitMQ](https://www.rabbitmq.com/) image based on the official
[`rabbitmq`](https://hub.docker.com/_/rabbitmq) image (management variant, i.e. with the
management plugin and its web UI enabled).

The image version follows the upstream `rabbitmq` version pinned in the
[Dockerfile](Dockerfile) (`FROM rabbitmq:<version>`); this is also what CI uses to derive
the published image tags (see the [root README](../../README.md#continuous-integration)).

## Changes over the upstream image

- **[`fileenv`](https://github.com/skriptfabrik/fileenv) entrypoint wrapper** – the
  `fileenv` binary is copied in from the
  [`ghcr.io/skriptfabrik/fileenv`](https://github.com/skriptfabrik/fileenv) image and set
  as `ENTRYPOINT`, wrapping the original RabbitMQ startup command (kept as `CMD`). Before
  starting the application, `fileenv` resolves any `<VAR>_FILE` environment variable into
  its corresponding `<VAR>` variable by reading the referenced file's contents (and unsets
  the `_FILE` variable afterwards) — this lets secrets (e.g. `RABBITMQ_DEFAULT_PASS`, the
  Erlang cookie) be supplied via mounted files or Docker/Swarm secrets instead of plain
  environment variables, without requiring any change in RabbitMQ itself.

## Usage

```sh
docker run -it --rm \
  -p 5672:5672 \
  -p 15672:15672 \
  -e RABBITMQ_DEFAULT_USER=rabbitmq \
  -e RABBITMQ_DEFAULT_PASS_FILE=/run/secrets/rabbitmq_password \
  -e RABBITMQ_DEFAULT_VHOST=/ \
  -v ./rabbitmq_password:/run/secrets/rabbitmq_password:ro \
  ghcr.io/skriptfabrik/docker-images/rabbitmq:latest
```

Refer to the [official RabbitMQ documentation](https://www.rabbitmq.com/docs/configure)
for environment variables, volumes, and general configuration — this image does not
change RabbitMQ's runtime behavior beyond the `fileenv`-based secret resolution described
above. Any environment variable RabbitMQ supports can alternatively be supplied as
`<VAR>_FILE` to have it resolved from a file at startup.
