FROM --platform=linux/amd64 ghcr.io/restake/blackbox:0.1.2
LABEL org.opencontainers.image.source=https://github.com/restake/depot

RUN mkdir -p /chain

RUN IFS=',' \
    && for binary in ${DEPOT_DOCKER_IMAGE_BINARIES}; do \
        cp "${binary}" "/usr/local/bin/$(basename $binary)" \
        && chmod +x "/usr/local/bin/$(basename $binary)"; \
    done
