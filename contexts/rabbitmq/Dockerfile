FROM ghcr.io/skriptfabrik/fileenv:1.1.0 AS fileenv

FROM rabbitmq:4.3.5-management

COPY --from=fileenv /usr/local/bin/fileenv /usr/local/bin/fileenv

ENTRYPOINT ["/usr/local/bin/fileenv", "docker-entrypoint.sh"]

CMD ["rabbitmq-server"]
