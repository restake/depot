#!/usr/bin/env bash
set -euo pipefail

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain "${DEPOT_BUILDER_VERSION}"

export PATH="${PATH}:${HOME}/.cargo/bin"

echo ">>> $(cargo version)"
