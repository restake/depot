#!/bin/bash

set -euo pipefail

repository_path=$(pwd)
cd "$repository_path"

ls -la

cd "$repository_path/jito"

export CI_COMMIT=$(git rev-parse HEAD)
export CARGO_BUILD_TARGET="x86_64-unknown-linux-gnu"
export CARGO_BUILD_RUSTFLAGS="-C target-cpu=znver4"
export CARGO_INCREMENTAL="0"

cargo build --profile release --bin solana-validator

mkdir "$repository_path/jito/bin"
mv -v "target/${CARGO_BUILD_TARGET}/release/solana-validator" "$repository_path/jito/bin/solana-validator-${DEPOT_CPU}-${DEPOT_ARCHITECTURES}"
