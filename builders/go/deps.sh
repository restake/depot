#!/usr/bin/env bash
set -euo pipefail

sudo apt-get install -y --no-install-recommends build-essential musl-dev

echo "cached-tooling-path=${GITHUB_WORKSPACE}/tools/go" >> "${GITHUB_OUTPUT}"
echo "cached-tooling-key=go-${DEPOT_BUILDER_VERSION}" >> "${GITHUB_OUTPUT}"
