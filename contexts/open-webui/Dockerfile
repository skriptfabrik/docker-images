FROM ghcr.io/skriptfabrik/fileenv:1.2.0 AS fileenv

FROM ghcr.io/open-webui/open-webui:v0.11.3

COPY --from=fileenv /usr/local/bin/fileenv /usr/local/bin/fileenv

ENTRYPOINT ["/usr/local/bin/fileenv"]

CMD ["bash", "/app/backend/start.sh"]
