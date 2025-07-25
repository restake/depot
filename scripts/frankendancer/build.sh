#!/usr/bin/env bash
set -euo pipefail

cd "${DEPOT_PROJECT_NAME}"

# Initialize and update submodules
git submodule update --init --recursive

# Install additional dependencies required by Firedancer
sudo apt-get install -y --no-install-recommends libclang-dev diffutils

# export FD_AUTO_INSTALL_PACKAGES=1
# sudo -E ./deps.sh fetch check install

# Build the binaries
MACHINE="linux_gcc_x86_64" make -j fdctl solana

mkdir -p bin

build_binaries="$(deno run --allow-read --allow-env ../utils/binaries.ts)"

echo "${build_binaries}" | jq -r 'to_entries[] | "\(.key) \(.value)"' | while read -r binary path; do
    mv -v "build/${MACHINE:-native}/gcc/bin/${binary}" "${path}"
done
