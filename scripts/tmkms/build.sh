#!/usr/bin/env bash
set -euo pipefail

cd tmkms
mkdir bin

cargo build --release --features=softsign,fortanixdsm

build_binaries="$(deno run --allow-read --allow-env ../utils/binaries.ts)"

echo "${build_binaries}" | jq -r 'to_entries[] | "\(.key) \(.value)"' | while read -r binary path; do
    mv -v "${GITHUB_WORKSPACE}/tmkms/target/release/${binary}" "${path}"
done
