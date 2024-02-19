#!/bin/bash

set -euo pipefail

cd jito-solana

export CI_COMMIT=$(git rev-parse HEAD)
export CARGO_BUILD_TARGET="x86_64-unknown-linux-gnu"
export CARGO_BUILD_RUSTFLAGS="-C target-cpu=znver4"
export CARGO_INCREMENTAL="0"

cargo build --profile release --bin solana-validator

mv -v "target/${CARGO_BUILD_TARGET}/release/solana-validator" "${BINARY_PROTOCOL}/bin/${BINARY_NAME}"