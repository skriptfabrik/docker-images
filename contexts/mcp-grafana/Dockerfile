FROM ghcr.io/skriptfabrik/fileenv:1.2.0 AS fileenv

FROM grafana/mcp-grafana:2.2.0

ENV FILEENV_EXCLUDE="GRAFANA_SERVICE_ACCOUNT_TOKEN_FILE"

COPY --from=fileenv /usr/local/bin/fileenv /usr/local/bin/fileenv

ENTRYPOINT ["/usr/local/bin/fileenv", "/app/mcp-grafana", "--transport", "sse", "--address", "0.0.0.0:8000"]
