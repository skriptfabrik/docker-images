FROM ghcr.io/skriptfabrik/fileenv:1.2.0 AS fileenv

FROM pocketid/pocket-id:v2.19.1

ENV FILEENV_EXCLUDE="DB_CONNECTION_STRING_FILE,ENCRYPTION_KEY_FILE,LDAP_BIND_PASSWORD_FILE,MAXMIND_LICENSE_KEY_FILE,S3_SECRET_ACCESS_KEY_FILE,SMTP_PASSWORD_FILE,STATIC_API_KEY_FILE,TLS_CERT_FILE,TLS_KEY_FILE"

COPY --from=fileenv /usr/local/bin/fileenv /usr/local/bin/fileenv

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/fileenv", "sh", "/usr/local/bin/docker-entrypoint.sh", "sh", "/app/docker/entrypoint.sh"]

CMD ["/app/pocket-id"]
