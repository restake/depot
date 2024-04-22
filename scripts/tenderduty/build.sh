#!/usr/bin/env bash
set -euo pipefail

cd tenderduty
mkdir bin

go get ./...
go build -ldflags '-s -w' -trimpath -o tenderduty main.go

build_binaries="$(deno run --allow-read --allow-env ../utils/binaries.ts)"

echo "${build_binaries}" | jq -r 'to_entries[] | "\(.key) \(.value)"' | while read -r binary path; do
    mv -v "${GITHUB_WORKSPACE}/tenderduty/${binary}" "${path}"
done
