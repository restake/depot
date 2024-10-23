#!/usr/bin/env bash
set -euo pipefail

sudo apt-get install -y --no-install-recommends ca-certificates unzip

cd "${DEPOT_PROJECT_NAME}"
git submodule update --init dedicated_executor eth2_libp2p
mkdir bin

export CARGO_BUILD_TARGET="x86_64-unknown-linux-gnu"
export CARGO_INCREMENTAL="0"

# Replace literal '\n' with actual newlines for proper splitting
binaries=$(echo -e "${DEPOT_BINARY_BUILD_NAME}")

args=()

while IFS= read -r binary; do
    args+=(--bin "${binary}")
done <<< "${binaries}"

cargo build --release --features default-networks "${args[@]}"

build_binaries="$(deno run --allow-read --allow-env ../utils/binaries.ts)"

echo "${build_binaries}" | jq -r 'to_entries[] | "\(.key) \(.value)"' | while read -r binary path; do
    mv -v "target/${CARGO_BUILD_TARGET}/release/${binary}" "${path}"
done
