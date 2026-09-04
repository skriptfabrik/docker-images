FROM ghcr.io/skriptfabrik/fileenv:1.2.0 AS fileenv

FROM hoppscotch/hoppscotch:2026.8.0

COPY --from=fileenv /usr/local/bin/fileenv /usr/local/bin/fileenv

COPY docker-entrypoint.sh /docker-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/fileenv", "/docker-entrypoint.sh"]

CMD ["node", "/usr/src/app/aio_run.mjs"]
