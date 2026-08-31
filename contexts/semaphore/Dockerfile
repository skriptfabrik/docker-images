FROM ghcr.io/skriptfabrik/fileenv:1.1.0 AS fileenv

FROM semaphoreui/semaphore:v2.19.12

COPY --from=fileenv /usr/local/bin/fileenv /usr/local/bin/fileenv

COPY docker-entrypoint.sh /docker-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/fileenv", "/sbin/tini", "--", "/docker-entrypoint.sh"]

CMD ["/usr/local/bin/server-wrapper"]
