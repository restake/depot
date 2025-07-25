#!/usr/bin/env bash
set -euo pipefail
cd "${DEPOT_PROJECT_NAME}"
mkdir bin

# Grab static libwasmvm if needed
wasmvm_version="$(go list -json -m all | jq -cr 'select(.Path == "github.com/CosmWasm/wasmvm") | .Replace.Version // .Version')"
if [ -n "${wasmvm_version}" ]; then
    curl -JLO "https://github.com/CosmWasm/wasmvm/releases/download/${wasmvm_version}/libwasmvm_muslc.x86_64.a"
    ln -s libwasmvm_muslc.x86_64.a libwasmvm.x86_64.a
fi

# Force fully static linking
export CGO_ENABLED=1
export CGO_LDFLAGS="-static -L."
export GOFLAGS=""

make CC="x86_64-linux-musl-gcc" LEDGER_ENABLED=false LINK_STATICALLY=true build

# Verify the binary is static
echo "Checking if binary is static:"
if ldd bin/persistenceCore; then
    echo "Not a static binary"
    exit 1
fi

build_binaries="$(deno run --allow-read --allow-env ../utils/binaries.ts)"
echo "${build_binaries}" | jq -r 'to_entries[] | "\(.key) \(.value)"' | while read -r binary path; do
    mv -v "${GITHUB_WORKSPACE}/persistenceCore/bin/${binary}" "${path}"
done
