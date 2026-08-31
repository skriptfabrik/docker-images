# @skriptfabrik/docker-images/mcp-auth-proxy

Customized [MCP Auth Proxy](https://sigbit.github.io/mcp-auth-proxy/) image based on the
official [`sigbit/mcp-auth-proxy`](https://github.com/sigbit/mcp-auth-proxy) image. MCP
Auth Proxy is a drop-in OAuth 2.1/OIDC gateway for MCP servers, adding authentication
(Google, GitHub, OIDC, or password) in front of a stdio, SSE, or HTTP MCP server without
requiring any changes to that server.

The image version follows the upstream `sigbit/mcp-auth-proxy` version pinned in the
[Dockerfile](Dockerfile) (`FROM ghcr.io/sigbit/mcp-auth-proxy:<version>`); this is also
what CI uses to derive the published image tags (see the
[root README](../../README.md#continuous-integration)).

## Changes over the upstream image

- **[`fileenv`](https://github.com/skriptfabrik/fileenv) entrypoint wrapper** – the
  `fileenv` binary is copied in from the
  [`ghcr.io/skriptfabrik/fileenv`](https://github.com/skriptfabrik/fileenv) image and set
  as `ENTRYPOINT`, wrapping the original `mcp-auth-proxy` command (kept as `CMD`). Before
  starting the application, `fileenv` resolves any `<VAR>_FILE` environment variable into
  its corresponding `<VAR>` variable by reading the referenced file's contents (and unsets
  the `_FILE` variable afterwards) — this lets secrets (e.g. `AUTH_HMAC_SECRET`,
  `PASSWORD`, `JWT_PRIVATE_KEY`, OAuth client secrets) be supplied via mounted files or
  Docker/Swarm secrets instead of plain environment variables, without requiring any
  change in MCP Auth Proxy itself.

## Usage

```sh
docker run -it --rm \
  -p 80:80 \
  -e EXTERNAL_URL=https://mcp.example.com \
  -e NO_AUTO_TLS=true \
  -e AUTH_HMAC_SECRET_FILE=/run/secrets/auth_hmac_secret \
  -e PASSWORD_FILE=/run/secrets/password \
  -v ./auth_hmac_secret:/run/secrets/auth_hmac_secret:ro \
  -v ./password:/run/secrets/password:ro \
  ghcr.io/skriptfabrik/docker-images/mcp-auth-proxy:latest \
  -- npx -y @modelcontextprotocol/server-filesystem ./
```

Refer to the
[official MCP Auth Proxy documentation](https://sigbit.github.io/mcp-auth-proxy/docs/intro)
for CLI flags/environment variables (listen address, TLS, OAuth providers, the proxied MCP
server), and general configuration — this image does not change MCP Auth Proxy's runtime
behavior beyond the `fileenv`-based secret resolution described above. Any environment
variable MCP Auth Proxy supports can alternatively be supplied as `<VAR>_FILE` to have it
resolved from a file at startup.
