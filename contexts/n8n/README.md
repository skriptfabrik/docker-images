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
- **`n8n-core` patch** – [patches/n8n-core.patch](patches/n8n-core.patch) is applied to the
  bundled `n8n-core` package on top of the upstream image. It extends the
  pre-authentication retry logic in `httpRequestWithAuthentication` to also trigger on
  HTTP `403` responses (upstream only retries on `401`), so credentials using
  `preAuthentication` are refreshed by nodes/APIs that return `403` instead of `401` for
  an expired/invalid token.

  When bumping the base image version, verify that this patch still applies cleanly
  (`git apply --check`) against the new `n8n-core` sources, since it targets a specific
  file path inside `n8n-core/dist`.

## Usage

```sh
docker run -it --rm \
  -p 5678:5678 \
  ghcr.io/skriptfabrik/docker-images/n8n:latest
```

Refer to the [official n8n documentation](https://docs.n8n.io/) for environment variables,
volumes, and general configuration — this image does not change n8n's runtime behavior or
configuration surface beyond the patch described above.
