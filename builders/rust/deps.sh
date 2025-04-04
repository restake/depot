#!/usr/bin/env bash
set -euo pipefail

sudo apt update

sudo apt-get install -y --no-install-recommends build-essential libssl-dev libudev-dev pkg-config zlib1g-dev llvm clang cmake make libprotobuf-dev protobuf-compiler

echo "cached-tooling-path=${GITHUB_WORKSPACE}/tools/rust/cargo" >> "${GITHUB_OUTPUT}"
echo "cached-tooling-key=cargo-${DEPOT_BUILDER_VERSION}" >> "${GITHUB_OUTPUT}"
