# syntax=docker/dockerfile:1
FROM traefik:v3.8.0

# renovate: datasource=github-tags depName=maxlerebourg/crowdsec-bouncer-traefik-plugin
ARG CROWDSEC_BOUNCER_PLUGIN_VERSION=v1.8.2

ADD https://github.com/maxlerebourg/crowdsec-bouncer-traefik-plugin.git#${CROWDSEC_BOUNCER_PLUGIN_VERSION} \
    /plugins-local/src/github.com/maxlerebourg/crowdsec-bouncer-traefik-plugin

COPY plugins.txt /plugins-local/plugins.txt
COPY --chmod=0755 docker-entrypoint.sh /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["traefik"]
