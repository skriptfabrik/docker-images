FROM ghcr.io/skriptfabrik/fileenv:1.2.0 AS fileenv

FROM ghcr.io/mend/renovate-ce:15.10.0

ENV FILEENV_EXCLUDE="LOG_FILE,RENOVATE_ADDITIONAL_CONFIG_FILE,RENOVATE_CONFIG_FILE,RENOVATE_X_DELETE_CONFIG_FILE,RENOVATE_X_STATIC_REPO_CONFIG_FILE,SSL_CERT_FILE"

COPY --from=fileenv /usr/local/bin/fileenv /usr/local/bin/fileenv

ENTRYPOINT ["/usr/local/bin/fileenv", "/usr/local/sbin/renovate-entrypoint.sh"]

CMD ["/usr/src/mend/node_opts_exec.sh", "node_default", "/usr/src/mend/src/community.js"]
