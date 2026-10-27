FROM outlinewiki/outline:1.12.0

COPY docker-entrypoint.sh /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["node", "build/server/index.js"]
