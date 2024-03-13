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

mv -v "target/${CARGO_BUILD_TARGET}/release/sui" "$repository_path/${DEPOT_NAME}/bin/sui-${DEPOT_CPU}-${DEPOT_ARCHITECTURE}"
mv -v "target/${CARGO_BUILD_TARGET}/release/sui-node" "$repository_path/${DEPOT_NAME}/bin/suinode-${DEPOT_CPU}-${DEPOT_ARCHITECTURE}"
