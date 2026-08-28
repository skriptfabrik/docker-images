FROM ghcr.io/skriptfabrik/fileenv:1.1.0 AS fileenv

FROM searxng/searxng:2026.8.22-9fea41204

COPY --from=fileenv /usr/local/bin/fileenv /usr/local/bin/fileenv

ENTRYPOINT ["/usr/local/bin/fileenv", "/usr/local/searxng/entrypoint.sh"]
