# @skriptfabrik/docker-images/n8n

Customized [n8n](https://n8n.io/) image based on the official
[`n8nio/n8n`](https://hub.docker.com/r/n8nio/n8n) image.

The image version follows the upstream `n8nio/n8n` version pinned in the
[Dockerfile](Dockerfile) (`FROM n8nio/n8n:<version>`); this is also what CI uses to derive
the published image tags (see the [root README](../../README.md#continuous-integration)).

## Changes over the upstream image

- **LibreOffice support** – `libreoffice-common` is installed (via a separate Alpine
  builder stage, without running package scripts, to keep the final image lean) so that
  workflows/nodes relying on a LibreOffice binary for document conversion work out of the
  box.

## Usage

```sh
docker run -it --rm \
  -p 5678:5678 \
  ghcr.io/skriptfabrik/docker-images/n8n:latest
```

Refer to the [official n8n documentation](https://docs.n8n.io/) for environment variables,
volumes, and general configuration — this image does not change n8n's runtime behavior or
configuration surface.
