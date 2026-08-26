# @skriptfabrik/docker-images/arcane

Customized [Arcane](https://getarcaneapp.dev/) images based on the official
[`getarcaneapp/agent`](https://github.com/orgs/getarcaneapp/packages/container/package/agent)
and [`getarcaneapp/manager`](https://github.com/orgs/getarcaneapp/packages/container/package/manager)
images.

This context builds two separate images from two Dockerfiles:

- [Dockerfile.agent](Dockerfile.agent) – the Arcane agent, published as `arcane-agent`.
- [Dockerfile.manager](Dockerfile.manager) – the Arcane manager, published as `arcane-manager`.

Each image's version follows the upstream `getarcaneapp/agent`/`getarcaneapp/manager`
version pinned in its Dockerfile (`FROM ghcr.io/getarcaneapp/<agent|manager>:<version>`);
this is also what CI uses to derive the published image tags for each image separately
(see the [root README](../../README.md#continuous-integration)).

## Changes over the upstream images

- **[`fileenv`](https://github.com/skriptfabrik/fileenv) entrypoint wrapper** – the
  `fileenv` binary is copied in from the
  [`ghcr.io/skriptfabrik/fileenv`](https://github.com/skriptfabrik/fileenv) image and set
  as `ENTRYPOINT`, wrapping the original `arcane-agent`/`arcane` command (kept as `CMD`).
  Before starting the application, `fileenv` resolves any `<VAR>_FILE` environment
  variable into its corresponding `<VAR>` variable by reading the referenced file's
  contents (and unsets the `_FILE` variable afterwards) — this lets secrets (e.g.
  database credentials, tokens) be supplied via mounted files or Docker/Swarm secrets
  instead of plain environment variables, without requiring any change in Arcane itself.

## Usage

```sh
docker run -it --rm \
  -p 3552:3552 \
  ghcr.io/skriptfabrik/docker-images/arcane-manager:latest
```

```sh
docker run -it --rm \
  -e ARCANE_AGENT_TOKEN_FILE=/run/secrets/arcane_agent_token \
  -v ./arcane_agent_token:/run/secrets/arcane_agent_token:ro \
  ghcr.io/skriptfabrik/docker-images/arcane-agent:latest
```

Refer to the [official Arcane documentation](https://getarcaneapp.dev/docs) for
environment variables, volumes, and general configuration — this image does not change
Arcane's runtime behavior beyond the `fileenv`-based secret resolution described above.
Any environment variable Arcane supports can alternatively be supplied as `<VAR>_FILE`
to have it resolved from a file at startup.
