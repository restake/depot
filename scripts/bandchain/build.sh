#!/usr/bin/env bash
set -euo pipefail

cd "${DEPOT_PROJECT_NAME}"
mkdir bin

sudo apt-get install -y libgo-owasm-dev wasmtime-dev

# BandChain uses 'make install' which installs to Go bin directory
make CC="x86_64-linux-musl-gcc" CGO_LDFLAGS="-L." LEDGER_ENABLED=false LINK_STATICALLY=true install

build_binaries="$(deno run --allow-read --allow-env ../utils/binaries.ts)"

echo "${build_binaries}" | jq -r 'to_entries[] | "\(.key) \(.value)"' | while read -r binary path; do
    # 'make install' puts the binary in the Go bin directory
    mv -v "${GITHUB_WORKSPACE}/tools/go-1.24.3/bin/${binary}" "${path}"
done
