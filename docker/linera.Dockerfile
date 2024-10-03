FROM --platform=linux/amd64 ghcr.io/restake/blackbox:v0.1.5
LABEL org.opencontainers.image.source=https://github.com/restake/depot

ENV LD_LIBRARY_PATH=/usr/lib

ARG DEPOT_DOCKER_BINARIES

COPY binaries binaries

RUN mkdir -p /chain

RUN IFS=',' \
    && for binary in ${DEPOT_DOCKER_BINARIES}; do \
        mv "binaries/${binary}-generic-x86_64" "/usr/local/bin/$(basename $binary)" \
        && chmod +x "/usr/local/bin/$(basename $binary)"; \
    done

RUN rm -rf binaries
