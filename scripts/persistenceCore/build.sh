#!/usr/bin/env bash
set -euo pipefail
cd "${DEPOT_PROJECT_NAME}"
mkdir bin

# Force fully static linking
export CGO_ENABLED=1
export GOFLAGS=""

make CC="gcc" LEDGER_ENABLED=false build

build_binaries="$(deno run --allow-read --allow-env ../utils/binaries.ts)"
echo "${build_binaries}" | jq -r 'to_entries[] | "\(.key) \(.value)"' | while read -r binary path; do
    mv -v "${GITHUB_WORKSPACE}/persistenceCore/bin/${binary}" "${path}"
done
