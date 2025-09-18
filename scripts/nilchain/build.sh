#!/usr/bin/env bash
set -euo pipefail

cd "${DEPOT_PROJECT_NAME}"
mkdir bin

# Build the nilchaind binary with static linking
make CC="x86_64-linux-musl-gcc" CGO_ENABLED=1 CGO_LDFLAGS="-static -L." LEDGER_ENABLED=false LINK_STATICALLY=true build

# Verify the binary is static
echo "Checking if binary is static:"
if ldd build/nilchaind 2>/dev/null; then
    echo "Not a static binary"
    exit 1
fi

build_binaries="$(deno run --allow-read --allow-env ../utils/binaries.ts)"

echo "${build_binaries}" | jq -r 'to_entries[] | "\(.key) \(.value)"' | while read -r binary path; do

    if [ -f "${GITHUB_WORKSPACE}/${DEPOT_PROJECT_NAME}/build/${binary}" ]; then
        mv -v "${GITHUB_WORKSPACE}/${DEPOT_PROJECT_NAME}/build/${binary}" "${path}"
    else
        echo "Error: Binary ${binary} not found in build directory"
        exit 1
    fi
done
