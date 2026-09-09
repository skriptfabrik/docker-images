FROM outlinewiki/outline:1.10.1

COPY docker-entrypoint.sh /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["node", "build/server/index.js"]
