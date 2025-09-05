#!/usr/bin/env bash
set -euo pipefail

cd "${DEPOT_PROJECT_NAME}"
mkdir bin

# Build from the protocol directory
cd protocol
make CC="x86_64-linux-musl-gcc" CGO_LDFLAGS="-L." LEDGER_ENABLED=false LINK_STATICALLY=true build

# Go back to project root
cd ..

build_binaries="$(deno run --allow-read --allow-env ../utils/binaries.ts)"

echo "${build_binaries}" | jq -r 'to_entries[] | "\(.key) \(.value)"' | while read -r binary path; do
    # The binary should be in the protocol/build directory
    if [ -f "${GITHUB_WORKSPACE}/${DEPOT_PROJECT_NAME}/protocol/build/${binary}" ]; then
        mv -v "${GITHUB_WORKSPACE}/${DEPOT_PROJECT_NAME}/protocol/build/${binary}" "${path}"
    else
        echo "Error: Binary ${binary} not found in protocol/build directory"
        exit 1
    fi
done
