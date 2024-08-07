#!/usr/bin/env bash
set -euo pipefail

cd "${DEPOT_PROJECT_NAME}"

# Grab static libwasmvm
wasmvm_version="$(go list -json -m all | jq -cr 'select(.Path == "github.com/CosmWasm/wasmvm") | .Replace.Version // .Version')"
curl -JLO "https://github.com/CosmWasm/wasmvm/releases/download/${wasmvm_version}/libwasmvm_muslc.x86_64.a"
ln -s libwasmvm_muslc.x86_64.a libwasmvm.x86_64.a

make CC="x86_64-linux-musl-gcc" CGO_LDFLAGS="-L." LEDGER_ENABLED=false LINK_STATICALLY=true build

# Smoke test
ldd ./bin/picad || :
./bin/picad version --long

build_binaries="$(deno run --allow-read --allow-env ../utils/binaries.ts)"

echo "${build_binaries}" | jq -r 'to_entries[] | "\(.key) \(.value)"' | while read -r binary path; do
    mv -v "${GITHUB_WORKSPACE}/picasso/bin/${binary}" "${path}"
done
