FROM ghcr.io/skriptfabrik/fileenv:1.1.0 AS fileenv

FROM ghcr.io/czlonkowski/n8n-mcp:2.77.0

COPY --from=fileenv /usr/local/bin/fileenv /usr/local/bin/fileenv

ENTRYPOINT ["/usr/local/bin/fileenv", "/usr/local/bin/docker-entrypoint.sh"]

CMD ["node", "dist/mcp/index.js"]
