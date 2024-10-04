FROM --platform=linux/amd64 ghcr.io/restake/blackbox:v0.1.6
LABEL org.opencontainers.image.source=https://github.com/restake/depot

ARG DEPOT_BINARY_VERSION

RUN mkdir -p /chain

RUN curl -Lo /usr/local/bin/bbcored https://github.com/BounceBit-Labs/node/releases/download/${DEPOT_BINARY_VERSION}/bbcored \
  && chmod +x /usr/local/bin/bbcored
