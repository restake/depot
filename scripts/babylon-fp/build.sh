#!/usr/bin/env bash
set -euo pipefail

cd babylon-fp
mkdir bin

make build

build_binaries="$(deno run --allow-read --allow-env ../utils/binaries.ts)"

echo "${build_binaries}" | jq -r 'to_entries[] | "\(.key) \(.value)"' | while read -r binary path; do
    mv -v "${GITHUB_WORKSPACE}/babylon-fp/build/${binary}" "${path}"
done
