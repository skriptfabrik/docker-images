# @skriptfabrik/docker-images/semaphore-mcp

Customized [Semaphore MCP](https://github.com/cloin/semaphore-mcp) image based on the
official [`ghcr.io/cloin/semaphore-mcp`](https://github.com/cloin/semaphore-mcp/pkgs/container/semaphore-mcp)
image. Semaphore MCP is a [Model Context Protocol](https://modelcontextprotocol.io/) server
that gives AI assistants (Claude, Cursor, Windsurf, …) access to a
[Semaphore UI](https://semaphoreui.com/) instance, e.g. to manage projects and templates
and to run and inspect tasks.

The image version follows the upstream `ghcr.io/cloin/semaphore-mcp` version pinned in the
[Dockerfile](Dockerfile) (`FROM ghcr.io/cloin/semaphore-mcp:<version>`); this is also what
CI uses to derive the published image tags (see the
[root README](../../README.md#continuous-integration)).

## Changes over the upstream image

Semaphore MCP reads its Semaphore API token only from an environment variable
(`SEMAPHORE_API_TOKEN`) or a command line flag (`--token`), which makes it impossible to
supply it as a Docker/Swarm secret.

- **[`fileenv`](https://github.com/skriptfabrik/fileenv) entrypoint wrapper** – the
  `fileenv` binary is copied in from the
  [`ghcr.io/skriptfabrik/fileenv`](https://github.com/skriptfabrik/fileenv) image and set
  as `ENTRYPOINT`, wrapping the upstream `semaphore-mcp` entrypoint (kept as the wrapped
  command). Before starting the application, `fileenv` resolves any `<VAR>_FILE`
  environment variable into its corresponding `<VAR>` variable by reading the referenced
  file's contents (and unsets the `_FILE` variable afterwards) — this lets secrets (e.g.
  `SEMAPHORE_API_TOKEN`) be supplied via mounted files or Docker/Swarm secrets instead of
  plain environment variables, without requiring any change in Semaphore MCP itself. Since
  the upstream image defines no `CMD`, any arguments passed to the container (e.g.
  `--verbose`) are still forwarded to `semaphore-mcp`.

## Usage

By default the container starts Semaphore MCP as a remote HTTP server (streamable HTTP
transport) listening on port `8000` (upstream defaults `MCP_TRANSPORT=http`,
`MCP_HOST=0.0.0.0`, `MCP_PORT=8000`):

```sh
docker run -it --rm \
  -p 8000:8000 \
  -e SEMAPHORE_URL=https://your-semaphore-instance.example.com \
  -e SEMAPHORE_API_TOKEN_FILE=/run/secrets/semaphore_api_token \
  -v ./semaphore_api_token:/run/secrets/semaphore_api_token:ro \
  ghcr.io/skriptfabrik/docker-images/semaphore-mcp:latest
```

With the HTTP transport, `SEMAPHORE_API_TOKEN` is optional: without it, the
`Authorization: Bearer <token>` header sent by the MCP client is forwarded to Semaphore
instead, so every client authenticates with its own Semaphore API token.

To run it in stdio mode instead, e.g. for a local MCP client launching the container
directly, set `MCP_TRANSPORT=stdio`:

```sh
docker run -i --rm \
  -e MCP_TRANSPORT=stdio \
  -e SEMAPHORE_URL=https://your-semaphore-instance.example.com \
  -e SEMAPHORE_API_TOKEN_FILE=/run/secrets/semaphore_api_token \
  -v ./semaphore_api_token:/run/secrets/semaphore_api_token:ro \
  ghcr.io/skriptfabrik/docker-images/semaphore-mcp:latest
```

Refer to the [official Semaphore MCP documentation](https://github.com/cloin/semaphore-mcp#readme)
for the full set of environment variables (`SEMAPHORE_URL`, `SEMAPHORE_API_TOKEN`,
`MCP_TRANSPORT`, `MCP_HOST`, `MCP_PORT`) and general configuration — this image does not
change Semaphore MCP's runtime behavior beyond the `fileenv`-based secret resolution
described above. Any environment variable Semaphore MCP supports can alternatively be
supplied as `<VAR>_FILE` to have it resolved from a file at startup.
