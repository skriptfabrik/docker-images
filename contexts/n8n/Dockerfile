ARG ALPINE_VERSION=3.24

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

FROM n8nio/n8n:2.40.3

# Copy libreoffice-common from builder stage
COPY --from=builder /pkgroot/ /
