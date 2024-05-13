#!/usr/bin/env bash
set -euo pipefail

cd finality-provider
mkdir bin

make build

build_binaries="$(deno run --allow-read --allow-env ../utils/binaries.ts)"

echo "${build_binaries}" | jq -r 'to_entries[] | "\(.key) \(.value)"' | while read -r binary path; do
    mv -v "${GITHUB_WORKSPACE}/finality-provider/build/${binary}" "${path}"
done
