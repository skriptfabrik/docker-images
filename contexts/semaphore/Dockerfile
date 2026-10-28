FROM ghcr.io/skriptfabrik/fileenv:1.2.0 AS fileenv

FROM semaphoreui/semaphore:v2.19.17

# Exclude environment variables handled by the server wrapper and file path variables used by Semaphore itself from being processed by fileenv
ENV FILEENV_EXCLUDE="SEMAPHORE_ACCESS_KEY_ENCRYPTION_FILE,SEMAPHORE_ADMIN_FILE,SEMAPHORE_ADMIN_PASSWORD_FILE,SEMAPHORE_DB_PASS_FILE,SEMAPHORE_DB_USER_FILE,SEMAPHORE_ENCRYPTION_KEYS_FILE,SEMAPHORE_IMPORT_PROJECT_FILE,SEMAPHORE_LDAP_PASSWORD_FILE,SEMAPHORE_RUNNER_REGISTRATION_TOKEN_FILE,SEMAPHORE_RUNNER_SERVER_CA_CERT_FILE,SEMAPHORE_RUNNER_TOKEN_FILE,SEMAPHORE_SUBSCRIPTION_KEY_FILE,SEMAPHORE_TLS_CERT_FILE,SEMAPHORE_TLS_KEY_FILE"

COPY --from=fileenv /usr/local/bin/fileenv /usr/local/bin/fileenv

COPY docker-entrypoint.sh /docker-entrypoint.sh

ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/fileenv", "/docker-entrypoint.sh"]

CMD ["/usr/local/bin/server-wrapper"]
