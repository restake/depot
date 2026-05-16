#!/usr/bin/env bash
set -euo pipefail

cd "${DEPOT_PROJECT_NAME}"
mkdir bin

# Build slinky with static linking using musl
export CGO_ENABLED=1
export CGO_LDFLAGS="-static"
export GOFLAGS=""

# Build slinky binary
go build -ldflags="-linkmode external -extldflags '-static'" -o slinky ./cmd/slinky

build_binaries="$(deno run --allow-read --allow-env ../utils/binaries.ts)"
echo "${build_binaries}" | jq -r 'to_entries[] | "\(.key) \(.value)"' | while read -r binary path; do
    mv -v "${GITHUB_WORKSPACE}/slinky/${binary}" "${path}"
done
