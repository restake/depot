#!/usr/bin/env bash
set -euo pipefail

sudo apt-get update && sudo apt-get install -y --no-install-recommends libclang-dev

cd "${DEPOT_PROJECT_NAME}"
mkdir bin

export CI_COMMIT=$(git rev-parse HEAD)
export CARGO_BUILD_TARGET="x86_64-unknown-linux-gnu"
export CARGO_BUILD_RUSTFLAGS="-C target-cpu=${DEPOT_CPU}"
export CARGO_INCREMENTAL="0"

cargo build --profile release --bin agave-validator

build_binaries="$(deno run --allow-read --allow-env ../utils/binaries.ts)"

echo "${build_binaries}" | jq -r 'to_entries[] | "\(.key) \(.value)"' | while read -r binary path; do
    mv -v "target/${CARGO_BUILD_TARGET}/release/${binary}" "${path}"
done
