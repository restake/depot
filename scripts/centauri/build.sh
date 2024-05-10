#!/usr/bin/env bash
set -euo pipefail

cd centauri

arch="$(uname -m)"

# Grab static libwasmvm
if ! [ -f "libwasmvm_muslc.${arch}.a" ]; then
    wasmvm_version="$(go list -json -m all | jq -cr 'select(.Path == "github.com/CosmWasm/wasmvm") | .Replace.Version // .Version')"
    curl -JL -o "libwasmvm_muslc.${arch}.a" "https://github.com/CosmWasm/wasmvm/releases/download/${wasmvm_version}/libwasmvm_muslc.${arch}.a"
    ln -s "libwasmvm_muslc.${arch}.a" "libwasmvm.${arch}.a"
fi

TARGET="${arch}-linux-gnu"
export CC="zig cc -target ${TARGET}"
export CXX="zig c++ -target ${TARGET}"
export CGO_ENABLED="1"
export CGO_LDFLAGS="-L. -Bsystem -lc -lm -lunwind -Bstatic"

make LEDGER_ENABLED=false LINK_STATICALLY=true build

# Smoke test
ldd ./bin/picad || :
./bin/picad version --long

build_binaries="$(deno run --allow-read --allow-env ../utils/binaries.ts)"

echo "${build_binaries}" | jq -r 'to_entries[] | "\(.key) \(.value)"' | while read -r binary path; do
    mv -v "${GITHUB_WORKSPACE}/centauri/bin/${binary}" "${path}"
done
