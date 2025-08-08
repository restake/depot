#!/usr/bin/env bash
set -euo pipefail

cd "${DEPOT_PROJECT_NAME}"
mkdir bin

make build

# Verify the binary is static
echo "Checking if binary is static:"
if ldd bin/persistenceCore; then
    echo "Not a static binary"
    exit 1
fi

build_binaries="$(deno run --allow-read --allow-env ../utils/binaries.ts)"

echo "${build_binaries}" | jq -r 'to_entries[] | "\(.key) \(.value)"' | while read -r binary path; do
    mv -v "${GITHUB_WORKSPACE}/omniflixhub/build/${binary}" "${path}"
done
