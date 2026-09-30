FROM ghcr.io/skriptfabrik/fileenv:1.2.0 AS fileenv

FROM ghcr.io/usekaneo/kaneo:2.29.3

COPY --from=fileenv /usr/local/bin/fileenv /usr/local/bin/fileenv

ENTRYPOINT ["/usr/local/bin/fileenv"]

CMD ["/usr/local/bin/kaneo-entrypoint.sh"]
