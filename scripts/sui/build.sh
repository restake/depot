#!/usr/bin/env bash
set -euo pipefail

cd "${DEPOT_PROJECT_NAME}"
mkdir bin

export CARGO_BUILD_TARGET="x86_64-unknown-linux-gnu"
export CARGO_INCREMENTAL="0"

cargo build --release --bin sui-node --bin sui --bin sui-tool

build_binaries="$(deno run --allow-read --allow-env ../utils/binaries.ts)"

echo "${build_binaries}" | jq -r 'to_entries[] | "\(.key) \(.value)"' | while read -r binary path; do
    mv -v "target/${CARGO_BUILD_TARGET}/release/${binary}" "${path}"
done
