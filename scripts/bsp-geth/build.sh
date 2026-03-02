#!/usr/bin/env bash
set -euo pipefail

cd "${DEPOT_PROJECT_NAME}"

# Fetch full git history if this is a shallow clone
# This is needed because the build process (build/ci.go) requires access to git commit objects
if git rev-parse --is-shallow-repository >/dev/null 2>&1; then
    git fetch --unshallow || git fetch --depth=0
fi

mkdir bin

make geth

build_binaries="$(deno run --allow-read --allow-env ../utils/binaries.ts)"

echo "${build_binaries}" | jq -r 'to_entries[] | "\(.key) \(.value)"' | while read -r binary path; do
    mv -v "${GITHUB_WORKSPACE}/bsp-geth/build/bin/${binary}" "${path}"
done
