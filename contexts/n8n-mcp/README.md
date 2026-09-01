# @skriptfabrik/docker-images/n8n-mcp

Customized [n8n-MCP](https://github.com/czlonkowski/n8n-mcp) image based on the official
[`ghcr.io/czlonkowski/n8n-mcp`](https://github.com/czlonkowski/n8n-mcp/pkgs/container/n8n-mcp)
image. n8n-MCP is a [Model Context Protocol](https://modelcontextprotocol.io/) server that
gives AI assistants (Claude, Cursor, Windsurf, …) structured access to n8n node
documentation/properties and, optionally, tools to manage workflows on a connected n8n
instance.

The image version follows the upstream `ghcr.io/czlonkowski/n8n-mcp` version pinned in the
[Dockerfile](Dockerfile) (`FROM ghcr.io/czlonkowski/n8n-mcp:<version>`); this is also what
CI uses to derive the published image tags (see the
[root README](../../README.md#continuous-integration)).

## Changes over the upstream image

- **[`fileenv`](https://github.com/skriptfabrik/fileenv) entrypoint wrapper** – the
  `fileenv` binary is copied in from the
  [`ghcr.io/skriptfabrik/fileenv`](https://github.com/skriptfabrik/fileenv) image and set
  as `ENTRYPOINT`, wrapping the upstream `docker-entrypoint.sh` (kept as the wrapped
  command) and then executing the image's configured `CMD`. Before starting the application, `fileenv`
  resolves any `<VAR>_FILE` environment variable into its corresponding `<VAR>` variable by
  reading the referenced file's contents (and unsets the `_FILE` variable afterwards) —
  this lets secrets (e.g. `AUTH_TOKEN`, `N8N_API_KEY`) be supplied via mounted files or
  Docker/Swarm secrets instead of plain environment variables, without requiring any change
  in n8n-MCP itself (which already supports its own `AUTH_TOKEN_FILE`/`N8N_API_KEY_FILE`
  variables for some settings — `fileenv`'s `_FILE` convention works for any variable).

## Usage

By default the container starts n8n-MCP in stdio mode, e.g. for a local MCP client
launching the container directly:

```sh
docker run -it --rm \
  ghcr.io/skriptfabrik/docker-images/n8n-mcp:latest
```

To run it as a remote HTTP server, set `MCP_MODE=http` and provide an `AUTH_TOKEN` (via
`fileenv`, a mounted Docker/Swarm secret file):

```sh
docker run -it --rm \
  -p 3000:3000 \
  -e MCP_MODE=http \
  -e AUTH_TOKEN_FILE=/run/secrets/auth_token \
  -e N8N_API_URL=https://your-n8n-instance.example.com \
  -e N8N_API_KEY_FILE=/run/secrets/n8n_api_key \
  -v ./auth_token:/run/secrets/auth_token:ro \
  -v ./n8n_api_key:/run/secrets/n8n_api_key:ro \
  ghcr.io/skriptfabrik/docker-images/n8n-mcp:latest
```

Refer to the
[official n8n-MCP documentation](https://github.com/czlonkowski/n8n-mcp#readme) — in
particular the
[HTTP deployment guide](https://github.com/czlonkowski/n8n-mcp/blob/main/docs/HTTP_DEPLOYMENT.md)
— for the full set of environment variables (`MCP_MODE`, `PORT`, `N8N_API_URL`,
`N8N_API_KEY`, `N8N_MCP_ACCESS_TOKEN`, `DISABLED_TOOLS`, `WEBHOOK_SECURITY_MODE`, …) and
general configuration — this image does not change n8n-MCP's runtime behavior beyond the
`fileenv`-based secret resolution described above. Any environment variable n8n-MCP
supports can alternatively be supplied as `<VAR>_FILE` to have it resolved from a file at
startup.
