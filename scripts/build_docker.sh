#!/usr/bin/env bash
set -euo pipefail

image="restake/${DEPOT_PROJECT_NAME}-${DEPOT_BINARY_VERSION}"

docker buildx build -t "${image}" -f templates/Dockerfile .
