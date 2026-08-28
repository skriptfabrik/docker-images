# @skriptfabrik/docker-images/searxng

Customized [SearXNG](https://docs.searxng.org/) image based on the official
[`searxng/searxng`](https://hub.docker.com/r/searxng/searxng) image.

The image version follows the upstream `searxng/searxng` version pinned in the
[Dockerfile](Dockerfile) (`FROM searxng/searxng:<version>`); this is also what CI uses to
derive the published image tags (see the
[root README](../../README.md#continuous-integration)).

## Changes over the upstream image

- **[`fileenv`](https://github.com/skriptfabrik/fileenv) entrypoint wrapper** – the
  `fileenv` binary is copied in from the
  [`ghcr.io/skriptfabrik/fileenv`](https://github.com/skriptfabrik/fileenv) image and set
  as the first `ENTRYPOINT` argument, invoking the original `entrypoint.sh` directly.
  Before starting the application, `fileenv` resolves any `<VAR>_FILE` environment
  variable into its corresponding `<VAR>` variable by reading the referenced file's
  contents (and unsets the `_FILE` variable afterwards) — this lets secrets (e.g.
  `SEARXNG_SECRET`) be supplied via mounted files or Docker/Swarm secrets instead of plain
  environment variables, without requiring any change in SearXNG itself.

## Usage

```sh
docker run -it --rm \
  -p 8080:8080 \
  -e SEARXNG_BASE_URL=http://localhost:8080/ \
  -e SEARXNG_SECRET_FILE=/run/secrets/searxng_secret \
  -v ./searxng_secret:/run/secrets/searxng_secret:ro \
  ghcr.io/skriptfabrik/docker-images/searxng:latest
```

Refer to the [official SearXNG documentation](https://docs.searxng.org/) for environment
variables, volumes, and general configuration — this image does not change SearXNG's
runtime behavior beyond the `fileenv`-based secret resolution described above. Any
environment variable SearXNG supports can alternatively be supplied as `<VAR>_FILE` to
have it resolved from a file at startup.
