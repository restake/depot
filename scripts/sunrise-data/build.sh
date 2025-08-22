#!/usr/bin/env bash
set -euo pipefail

cd "${DEPOT_PROJECT_NAME}"
mkdir bin

mkdir -p build
make CC="x86_64-linux-musl-gcc" CGO_ENABLED=0 GOBIN="${GITHUB_WORKSPACE}/${DEPOT_PROJECT_NAME}/build" install

build_binaries="$(deno run --allow-read --allow-env ../utils/binaries.ts)"

echo "${build_binaries}" | jq -r 'to_entries[] | "\(.key) \(.value)"' | while read -r binary path; do
    mv -v "build/${binary}" "${path}"
done
