FROM ghcr.io/skriptfabrik/fileenv:1.2.0 AS fileenv

FROM ghcr.io/sigbit/mcp-auth-proxy:v2.10.2

COPY --from=fileenv /usr/local/bin/fileenv /usr/local/bin/fileenv

ENTRYPOINT ["/usr/local/bin/fileenv", "/usr/local/bin/mcp-auth-proxy"]
