#!/usr/bin/env bash
set -euo pipefail

cd haqq
mkdir bin

make LEDGER_ENABLED=false build

build_binaries="$(deno run --allow-read --allow-env ../utils/binaries.ts)"

echo "${build_binaries}" | jq -r 'to_entries[] | "\(.key) \(.value)"' | while read -r binary path; do
    mv -v "${GITHUB_WORKSPACE}/haqq/build/${binary}" "${path}"
done