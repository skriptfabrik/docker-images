FROM ghcr.io/skriptfabrik/fileenv:1.2.0 AS fileenv

FROM ghcr.io/usekaneo/kaneo:2.34.0

ENV FILEENV_EXCLUDE="AUTH_SECRET_FILE,CUSTOM_OAUTH_CLIENT_SECRET_FILE,POSTGRES_PASSWORD_FILE"

COPY --from=fileenv /usr/local/bin/fileenv /usr/local/bin/fileenv

ENTRYPOINT ["/usr/local/bin/fileenv"]

CMD ["/usr/local/bin/kaneo-entrypoint.sh"]
