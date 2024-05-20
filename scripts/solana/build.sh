#!/usr/bin/env bash
set -euo pipefail

cd "${DEPOT_PROJECT_NAME}"
mkdir bin

export CI_COMMIT=$(git rev-parse HEAD)
export CARGO_BUILD_TARGET="x86_64-unknown-linux-gnu"
export CARGO_BUILD_RUSTFLAGS="-C target-cpu=${DEPOT_CPU}"
export CARGO_INCREMENTAL="0"

# Replace literal '\n' with actual newlines for proper splitting
binaries=$(echo -e "$DEPOT_BINARY_BUILD_NAME")

cmd="cargo build --profile release"

while IFS= read -r binary; do
    cmd+=" --bin $binary"
done <<< "$binaries"

echo "Executing: $cmd"

eval $cmd

build_binaries="$(deno run --allow-read --allow-env ../utils/binaries.ts)"

echo "${build_binaries}" | jq -r 'to_entries[] | "\(.key) \(.value)"' | while read -r binary path; do
    mv -v "target/${CARGO_BUILD_TARGET}/release/${binary}" "${path}"
done
