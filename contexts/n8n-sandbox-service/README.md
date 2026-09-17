# @skriptfabrik/docker-images/n8n-sandbox-service

Customized [n8n Sandbox Service](https://github.com/n8n-io/n8n-sandbox-service) images
based on the official [`n8nio/n8n-sandbox-service-api`](https://hub.docker.com/r/n8nio/n8n-sandbox-service-api)
[`n8nio/n8n-sandbox-service-runner-dind`](https://hub.docker.com/r/n8nio/n8n-sandbox-service-runner-dind),
and [`n8nio/n8n-sandbox-service-sandbox`](https://hub.docker.com/r/n8nio/n8n-sandbox-service-sandbox)
images.

This context builds three separate images from three Dockerfiles:

- [Dockerfile.api](Dockerfile.api) – the sandbox control-plane API, published as
  `n8n-sandbox-service-api`.
- [Dockerfile.runner-dind](Dockerfile.runner-dind) – the privileged Docker-in-Docker
  sandbox runner, published as `n8n-sandbox-service-runner-dind`.
- [Dockerfile.sandbox](Dockerfile.sandbox) – the sandbox runtime, published as
  `n8n-sandbox-service-sandbox`.

Each image's version follows the upstream `n8nio/n8n-sandbox-service-*` version pinned
in its Dockerfile. This is also what CI uses to derive the published image tags for each
image separately (see the [root README](../../README.md#continuous-integration)).

## Changes over the upstream images

- **[`fileenv`](https://github.com/skriptfabrik/fileenv) entrypoint wrapper** – the
  `fileenv` binary is copied in from the
  [`ghcr.io/skriptfabrik/fileenv`](https://github.com/skriptfabrik/fileenv) image and set
  as the first `ENTRYPOINT` argument, invoking the original `sandbox-api`/
  `start-runner.sh` command directly. Before starting the application, `fileenv` resolves
  any `<VAR>_FILE` environment variable into its corresponding `<VAR>` variable by reading
  the referenced file's contents (and unsets the `_FILE` variable afterwards) — this lets
  secrets (e.g. `SANDBOX_API_KEYS`, `SANDBOX_RUNNER_API_KEYS`) be supplied via mounted
  files or Docker/Swarm secrets instead of plain environment variables, without requiring
  any change in the n8n Sandbox Service itself. `fileenv` only resolves these variables
  and then `exec`s into `/sbin/tini`, which continues to run as PID 1 as in the upstream
  images — this keeps `tini` responsible for reaping zombie processes, which matters in
  particular for `sandbox-runner-dind`, where it reaps the child processes spawned by the
  inner `dockerd` and its per-sandbox `containerd-shim` processes. `fileenv` itself does
  not take over any process-supervision duties.

## Usage

```sh
docker run -it --rm \
  -p 8080:8080 \
  -e SANDBOX_API_KEYS_FILE=/run/secrets/sandbox_api_keys \
  -v ./sandbox_api_keys:/run/secrets/sandbox_api_keys:ro \
  ghcr.io/skriptfabrik/docker-images/n8n-sandbox-service-api:latest
```

```sh
docker run -it --rm --privileged \
  -e SANDBOX_RUNNER_API_KEYS_FILE=/run/secrets/sandbox_runner_api_keys \
  -v ./sandbox_runner_api_keys:/run/secrets/sandbox_runner_api_keys:ro \
  ghcr.io/skriptfabrik/docker-images/n8n-sandbox-service-runner-dind:latest
```

The sandbox runtime image includes `pnpm` `12.4.2` globally. To verify the image
directly:

```sh
docker run --rm \
  ghcr.io/skriptfabrik/docker-images/n8n-sandbox-service-sandbox:latest \
  pnpm --version
```

Refer to the [official n8n Sandbox Service documentation](https://github.com/n8n-io/n8n-sandbox-service)
for environment variables, volumes, and general configuration — these images do not
change the sandbox service's runtime behavior beyond the `fileenv`-based secret
resolution described above. Any environment variable the sandbox service supports can
alternatively be supplied as `<VAR>_FILE` to have it resolved from a file at startup.
