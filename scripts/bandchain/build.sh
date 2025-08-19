#!/usr/bin/env bash
set -euo pipefail

cd "${DEPOT_PROJECT_NAME}"
mkdir bin

go_owasm_version="$(go list -json -m all | jq -cr 'select(.Path == "github.com/bandprotocol/go-owasm") | .Replace.Version // .Version')"
curl -JLO "https://github.com/bandprotocol/go-owasm/releases/download/${go_owasm_version}/libgo_owasm_muslc.x86_64.a"
ln -s libgo_owasm_muslc.x86_64.a libgo_owasm.x86_64.a

mkdir -p build
make CC="x86_64-linux-musl-gcc" CGO_LDFLAGS="-L." LEDGER_ENABLED=false LINK_STATICALLY=true GOBIN="${GITHUB_WORKSPACE}/${DEPOT_PROJECT_NAME}/build" install

build_binaries="$(deno run --allow-read --allow-env ../utils/binaries.ts)"

echo "${build_binaries}" | jq -r 'to_entries[] | "\(.key) \(.value)"' | while read -r binary path; do
    mv -v "build/${binary}" "${path}"
done
