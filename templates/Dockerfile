FROM --platform=linux/amd64 ghcr.io/restake/blackbox:0.1.1

ARG BINARY_LOCATION="/usr/local/bin/${DEPOT_DOCKER_IMAGE}"
RUN mkdir -p /chain

COPY "${DEPOT_DOCKER_IMAGE}" "${BINARY_LOCATION}"
RUN chmod +x "${BINARY_LOCATION}"
