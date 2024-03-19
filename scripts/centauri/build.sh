#!/bin/bash
set -euo pipefail

repository_path=$(pwd)
cd "$repository_path"

ls -la

cd centauri

# Grab static libwasmvm
wasmvm_version="$(go list -m all | grep -F "github.com/CosmWasm/wasmvm" | awk '{print $2}')"
curl -JLO "https://github.com/CosmWasm/wasmvm/releases/download/${wasmvm_version}/libwasmvm_muslc.x86_64.a"
ln -s libwasmvm_muslc.x86_64.a libwasmvm.x86_64.a

make CC="x86_64-linux-musl-gcc" CGO_LDFLAGS="-L." LEDGER_ENABLED=false LINK_STATICALLY=true build

# Smoke test
ldd ./bin/centaurid || :
./bin/centaurid version --long

build_binaries="$(deno run --allow-read --allow-env ../utils/binaries.ts)"

echo "${build_binaries}" | jq -r 'to_entries[] | "\(.key) \(.value)"' | while read -r binary path; do
    mv -v "$repository_path/centauri/bin/${binary}" "${path}"
done
