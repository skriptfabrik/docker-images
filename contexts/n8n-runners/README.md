# @skriptfabrik/docker-images/n8n-runners

Customized [n8n task runners](https://docs.n8n.io/hosting/configuration/task-runners/)
image based on the official [`n8nio/runners`](https://hub.docker.com/r/n8nio/runners)
image. It runs the `task-runner-launcher`, which launches n8n's external JavaScript and
Python Code node task runners and connects them to an n8n instance configured for
external task runners (`N8N_RUNNERS_MODE=external`).

The image version follows the upstream `n8nio/runners` version pinned in the
[Dockerfile](Dockerfile) (`FROM n8nio/runners:<version>`); this is also what CI uses to
derive the published image tags (see the
[root README](../../README.md#continuous-integration)).

## Changes over the upstream image

- **[`fileenv`](https://github.com/skriptfabrik/fileenv) entrypoint wrapper** – the
  `fileenv` binary is copied in from the
  [`ghcr.io/skriptfabrik/fileenv`](https://github.com/skriptfabrik/fileenv) image and set
  as the first `ENTRYPOINT` argument, ahead of the original `tini`/`task-runner-launcher`
  startup chain (kept as the remainder of `ENTRYPOINT`), with the runner types to launch
  passed through unchanged as `CMD` (`javascript` and `python` in this image). Before
  starting the launcher, `fileenv` resolves any `<VAR>_FILE` environment variable into its
  corresponding `<VAR>` variable by reading the referenced file's contents (and unsets the
  `_FILE` variable afterwards) — this lets secrets (e.g. `N8N_RUNNERS_AUTH_TOKEN`) be
  supplied via mounted files or Docker/Swarm secrets instead of plain environment
  variables, without requiring any change in the launcher itself.

## Usage

```sh
docker run -it --rm \
  -e N8N_RUNNERS_TASK_BROKER_URI=http://n8n:5679 \
  -e N8N_RUNNERS_AUTH_TOKEN_FILE=/run/secrets/runners_auth_token \
  -v ./runners_auth_token:/run/secrets/runners_auth_token:ro \
  ghcr.io/skriptfabrik/docker-images/n8n-runners:latest
```

The connected n8n instance must be configured with `N8N_RUNNERS_ENABLED=true`,
`N8N_RUNNERS_MODE=external`, and the same `N8N_RUNNERS_AUTH_TOKEN` (see the
[n8n](../n8n/README.md) image). Refer to the
[official task runner documentation](https://docs.n8n.io/hosting/configuration/task-runners/)
for `N8N_RUNNERS_TASK_BROKER_URI`, `N8N_RUNNERS_AUTH_TOKEN`, and other supported
environment variables, as well as the `/etc/n8n-task-runners.json` config used to
restrict builtins/external modules per runner type — this image does not change the
launcher's runtime behavior beyond the `fileenv`-based secret resolution described above.
Any environment variable it supports can alternatively be supplied as `<VAR>_FILE` to
have it resolved from a file at startup.
