#!/usr/bin/env bash
set -euo pipefail

cd "${DEPOT_PROJECT_NAME}"
mkdir bin

# Install required dependencies for Juno
echo "Installing Juno dependencies..."
sudo apt-get update
sudo apt-get install -y libjemalloc-dev libjemalloc2 pkg-config libbz2-dev

# Install additional dependencies via make
echo "Installing additional dependencies..."
make install-deps

# Build Juno using the correct target
echo "Building Juno..."
make juno

build_binaries="$(deno run --allow-read --allow-env ../utils/binaries.ts)"

echo "${build_binaries}" | jq -r 'to_entries[] | "\(.key) \(.value)"' | while read -r binary path; do
    mv -v "${GITHUB_WORKSPACE}/juno/build/${binary}" "${path}"
done
