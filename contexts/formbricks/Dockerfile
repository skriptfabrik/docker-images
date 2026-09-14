FROM ghcr.io/skriptfabrik/fileenv:1.2.0 AS fileenv

FROM ghcr.io/formbricks/formbricks:5.4.2

COPY --from=fileenv /usr/local/bin/fileenv /usr/local/bin/fileenv

USER root

RUN mv /usr/local/bin/docker-entrypoint.sh /usr/local/bin/original-docker-entrypoint.sh

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

USER nextjs

ENTRYPOINT ["/usr/local/bin/fileenv", "/usr/local/bin/docker-entrypoint.sh"]

CMD ["/home/nextjs/start.sh"]
