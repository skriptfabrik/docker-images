FROM alpine:2.24@sha256:71e9b7bae160ba167fa17414401b94cbcdaf3c32feeab9298bd794a2a0614c35 AS builder

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

FROM n8nio/n8n:2.45.1

# Copy libreoffice-common from builder stage
COPY --from=builder /pkgroot/ /
