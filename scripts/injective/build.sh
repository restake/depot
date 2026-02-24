#!/usr/bin/env bash
set -euo pipefail

cd "${DEPOT_PROJECT_NAME}"
mkdir bin

# Version flags matching upstream Makefile
APP_VERSION="$(git describe --tags --match 'v*')"
GIT_COMMIT="$(git rev-parse --short HEAD)"
BUILD_DATE="$(date -u '+%Y%m%d-%H%M')"

COSMOS_VERSION_PKG="github.com/cosmos/cosmos-sdk/version"
INJECTIVED_VERSION_PKG="github.com/InjectiveLabs/injective-core/version"

VERSION_FLAGS="-X ${INJECTIVED_VERSION_PKG}.AppVersion=${APP_VERSION} \
-X ${INJECTIVED_VERSION_PKG}.GitCommit=${GIT_COMMIT} \
-X ${INJECTIVED_VERSION_PKG}.BuildDate=${BUILD_DATE} \
-X ${COSMOS_VERSION_PKG}.Version=${APP_VERSION} \
-X ${COSMOS_VERSION_PKG}.Name=injective \
-X ${COSMOS_VERSION_PKG}.AppName=injectived \
-X ${COSMOS_VERSION_PKG}.Commit=${GIT_COMMIT}"

build_binaries="$(deno run --allow-read --allow-env ../utils/binaries.ts)"

binaries=$(echo -e "${DEPOT_BINARY_BUILD_NAME}")
while IFS= read -r binary; do
    output_path="$(echo "${build_binaries}" | jq -r --arg b "${binary}" '.[$b]')"
    go build \
        -tags "netgo" \
        -ldflags "-s -w ${VERSION_FLAGS}" \
        -trimpath \
        -o "${output_path}" \
        "./cmd/${binary}"
done <<< "${binaries}"

# Ship dynamic libwasmvm alongside injectived
wasmvm_version="$(go list -json -m all | jq -cr 'select(.Path == "github.com/CosmWasm/wasmvm/v2") | .Replace.Version // .Version')"
curl -sLo bin/libwasmvm.x86_64.so "https://github.com/CosmWasm/wasmvm/releases/download/${wasmvm_version}/libwasmvm.x86_64.so"
