# syntax=docker/dockerfile:1
FROM traefik:v3.7.17

# renovate: datasource=github-tags depName=maxlerebourg/crowdsec-bouncer-traefik-plugin
ARG CROWDSEC_BOUNCER_PLUGIN_VERSION=v1.8.1

ADD https://github.com/maxlerebourg/crowdsec-bouncer-traefik-plugin.git#${CROWDSEC_BOUNCER_PLUGIN_VERSION} \
    /plugins-local/src/github.com/maxlerebourg/crowdsec-bouncer-traefik-plugin

COPY plugins.txt /plugins-local/plugins.txt
COPY --chmod=0755 docker-entrypoint.sh /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["traefik"]
