# @skriptfabrik/docker-images/mcp-grafana

Customized [Grafana MCP](https://github.com/grafana/mcp-grafana) image based on the
official [`grafana/mcp-grafana`](https://hub.docker.com/r/grafana/mcp-grafana) image.
Grafana MCP is a [Model Context Protocol](https://modelcontextprotocol.io/) server that
gives AI assistants (Claude, Cursor, Windsurf, …) access to a Grafana instance and its
ecosystem — dashboards, datasources, Prometheus/Loki/Tempo queries, alerting, incidents,
OnCall, and more.

The image version follows the upstream `grafana/mcp-grafana` version pinned in the
[Dockerfile](Dockerfile) (`FROM grafana/mcp-grafana:<version>`); this is also what CI uses
to derive the published image tags (see the
[root README](../../README.md#continuous-integration)).

## Changes over the upstream image

- **[`fileenv`](https://github.com/skriptfabrik/fileenv) entrypoint wrapper** – the
  `fileenv` binary is copied in from the
  [`ghcr.io/skriptfabrik/fileenv`](https://github.com/skriptfabrik/fileenv) image and set
  as `ENTRYPOINT`, wrapping the original upstream entrypoint
  (`/app/mcp-grafana --transport sse --address 0.0.0.0:8000`, kept unchanged). Before
  `fileenv` resolves supported `<VAR>_FILE` environment variables into their corresponding `<VAR>`
  variables by reading referenced file contents (and unsets the `_FILE` variable afterwards).
  `GRAFANA_SERVICE_ACCOUNT_TOKEN_FILE` is excluded in the Dockerfile so Grafana MCP can handle
  that variable itself, including rereading rotated token files. This lets other secrets (e.g.
  `GRAFANA_PASSWORD`, `MCP_GRAFANA_SERVER_TOKEN`) be supplied via mounted files or Docker/Swarm
  secrets instead of plain environment variables, without requiring any change in Grafana MCP
  itself.

## Usage

By default the container starts Grafana MCP with the SSE transport on port `8000`:

```sh
docker run -it --rm \
  -p 8000:8000 \
  -e GRAFANA_URL=https://grafana.example.com \
  -e GRAFANA_SERVICE_ACCOUNT_TOKEN_FILE=/run/secrets/grafana_service_account_token \
  -e MCP_GRAFANA_SERVER_TOKEN_FILE=/run/secrets/mcp_server_token \
  -v ./grafana_service_account_token:/run/secrets/grafana_service_account_token:ro \
  -v ./mcp_server_token:/run/secrets/mcp_server_token:ro \
  ghcr.io/skriptfabrik/docker-images/mcp-grafana:latest
```

Additional arguments are appended to the upstream entrypoint flags, so the defaults can be
overridden, e.g. to use the streamable HTTP transport (served at `/mcp`) and accept
requests for a public host name:

```sh
docker run -it --rm \
  -p 8000:8000 \
  -e GRAFANA_URL=https://grafana.example.com \
  -e GRAFANA_SERVICE_ACCOUNT_TOKEN_FILE=/run/secrets/grafana_service_account_token \
  -e MCP_GRAFANA_SERVER_TOKEN_FILE=/run/secrets/mcp_server_token \
  -v ./grafana_service_account_token:/run/secrets/grafana_service_account_token:ro \
  -v ./mcp_server_token:/run/secrets/mcp_server_token:ro \
  ghcr.io/skriptfabrik/docker-images/mcp-grafana:latest \
  --transport streamable-http \
  --allowed-hosts mcp-grafana.example.com:8000
```

> [!WARNING]
> The server listens on `0.0.0.0:8000`, and `--allowed-hosts` only validates the `Host`
> header — it does not authenticate callers. Without `MCP_GRAFANA_SERVER_TOKEN` (or an
> authenticating proxy such as
> [mcp-auth-proxy](../mcp-auth-proxy/README.md) in front), anyone who can reach the port
> can invoke Grafana tools with the configured service account's permissions.

Refer to the
[official Grafana MCP documentation](https://github.com/grafana/mcp-grafana#readme) for the
full set of environment variables (`GRAFANA_URL`, `GRAFANA_SERVICE_ACCOUNT_TOKEN`,
`GRAFANA_USERNAME`, `GRAFANA_PASSWORD`, `GRAFANA_ORG_ID`, `MCP_GRAFANA_SERVER_TOKEN`, …),
CLI flags (`--enabled-tools`, `--disable-write`, `--allowed-hosts`, …) and general
configuration — this image does not change Grafana MCP's runtime behavior beyond the
`fileenv`-based secret resolution described above. Any environment variable Grafana MCP
supports can alternatively be supplied as `<VAR>_FILE` to have it resolved from a file at
startup.
