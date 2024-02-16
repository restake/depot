#!/usr/bin/env bash
set -euo pipefail

cd sui
mkdir bin

export CARGO_BUILD_TARGET="x86_64-unknown-linux-gnu"
export CARGO_BUILD_RUSTFLAGS="-C target-cpu=znver3"
export CARGO_INCREMENTAL="0"

cargo build --release --bin sui-node --bin sui

build_binaries="$(deno run --allow-read --allow-env ../utils/binaries.ts)"

echo "${build_binaries}" | jq -r 'to_entries[] | "\(.key) \(.value)"' | while read -r binary path; do
    mv -v "target/${CARGO_BUILD_TARGET}/release/${binary}" "${path}"
done
