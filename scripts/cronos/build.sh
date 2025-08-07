#!/usr/bin/env bash
set -euo pipefail

cd "${DEPOT_PROJECT_NAME}"
mkdir bin

make CC="x86_64-linux-musl-gcc" CGO_ENABLED=1 CGO_LDFLAGS="-static -L." LEDGER_ENABLED=false LINK_STATICALLY=true build

# Verify the binary is static
echo "Checking if binary is static:"
if ldd bin/chain-maind; then
    echo "Not a static binary"
    exit 1
fi

build_binaries="$(deno run --allow-read --allow-env ../utils/binaries.ts)"

echo "${build_binaries}" | jq -r 'to_entries[] | "\(.key) \(.value)"' | while read -r binary path; do
    mv -v "${GITHUB_WORKSPACE}/cronos/build/${binary}" "${path}"
done
