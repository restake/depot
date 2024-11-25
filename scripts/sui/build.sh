#!/usr/bin/env bash
set -euo pipefail

cd "${DEPOT_PROJECT_NAME}"

if [[ -n "${DEPOT_BINARY_HASH:-}" ]]; then
  echo "Building binaries from specific hash: ${DEPOT_BINARY_HASH}"

  mkdir -p bin
  export CARGO_BUILD_TARGET="x86_64-unknown-linux-gnu"
  export CARGO_INCREMENTAL="0"

  cargo build --release --bin sui --bin sui-bridge-cli --bin sui-bridge

  build_binaries="$(deno run --allow-read --allow-env ../utils/binaries.ts)"
  echo "${build_binaries}" | jq -r 'to_entries[] | "\(.key) \(.value)"' | while read -r binary path; do
    mv -f -v "target/${CARGO_BUILD_TARGET}/release/${binary}" "${path}"
  done
else
  echo "Building binaries from tags..."
  mkdir -p bin
  export CARGO_BUILD_TARGET="x86_64-unknown-linux-gnu"
  export CARGO_INCREMENTAL="0"

  binaries=$(echo -e "${DEPOT_BINARY_BUILD_NAME}")
  args=()
  while IFS= read -r binary; do
    args+=(--bin "${binary}")
  done <<< "${binaries}"

  cargo build --release "${args[@]}"

  build_binaries="$(deno run --allow-read --allow-env ../utils/binaries.ts)"
  echo "${build_binaries}" | jq -r 'to_entries[] | "\(.key) \(.value)"' | while read -r binary path; do
    mv -v "target/${CARGO_BUILD_TARGET}/release/${binary}" "${path}"
  done
fi
