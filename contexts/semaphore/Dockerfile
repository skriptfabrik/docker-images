FROM semaphoreui/semaphore:v2.19.12

COPY docker-entrypoint.sh /docker-entrypoint.sh

ENTRYPOINT ["/sbin/tini", "--", "/docker-entrypoint.sh"]

CMD ["/usr/local/bin/server-wrapper"]
