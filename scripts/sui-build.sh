set -euo pipefail

repository_path=$(pwd)
cd "$repository_path"

cd sui
mkdir bin

export CARGO_BUILD_TARGET="x86_64-unknown-linux-gnu"
export CARGO_BUILD_RUSTFLAGS="-C target-cpu=znver3"
export CARGO_INCREMENTAL="0"

cargo build --release --bin sui-node --bin sui

set -x

mv -v "target/${CARGO_BUILD_TARGET}/release/sui" "$repository_path/$protocol/bin/sui-$BINARY_CPU-$BINARY_ARCH"
mv -v "target/${CARGO_BUILD_TARGET}/release/sui-node" "$repository_path/$protocol/bin/suinode-$BINARY_CPU-$BINARY_ARCH"
