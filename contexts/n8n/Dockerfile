ARG ALPINE_VERSION=3.22

FROM alpine:${ALPINE_VERSION} AS builder

# Install libreoffice-common in builder stage
RUN set -e \
  ; mkdir -p /pkgroot \
  ; apk add --no-cache \
    --initdb \
    --root /pkgroot \
    --keys-dir /etc/apk/keys \
    --repositories-file /etc/apk/repositories \
    --no-scripts \
    libreoffice-common

FROM n8nio/n8n:2.36.8

# Copy libreoffice-common from builder stage
COPY --from=builder /pkgroot/ /

# Copy patch files
COPY ./patches /home/node/patches/

# Set to root user to apply patches
USER 0

# Apply patches
RUN set -e \
  ; for path in /usr/local/lib/node_modules/n8n/node_modules/.pnpm/n8n-core*/node_modules/n8n-core \
  ;   do git -C "$path" apply /home/node/patches/n8n-core.patch \
  ; done \
  ; rm -rf /home/node/patches

# Set back to node user
USER 1000
