FROM ghcr.io/skriptfabrik/fileenv:1.1.0 AS fileenv

FROM infisical/infisical:v0.162.24

COPY --from=fileenv /usr/local/bin/fileenv /usr/local/bin/fileenv

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/fileenv", "/usr/local/bin/docker-entrypoint.sh"]

CMD ["./standalone-entrypoint.sh"]
