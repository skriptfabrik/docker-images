FROM ghcr.io/skriptfabrik/fileenv:1.2.0 AS fileenv

FROM n8nio/runners:2.39.8

COPY --from=fileenv /usr/local/bin/fileenv /usr/local/bin/fileenv

ENTRYPOINT ["/usr/local/bin/fileenv", "/tini", "--", "/usr/local/bin/task-runner-launcher"]

CMD ["javascript", "python"]
