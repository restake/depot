#!/usr/bin/env bash
set -euo pipefail

install_dir="${GITHUB_WORKSPACE}/tools/rust"

export RUSTUP_HOME="${install_dir}/rustup"
export CARGO_HOME="${install_dir}/cargo"

if ! [ -d "${install_dir}" ]; then
    mkdir -p "${install_dir}/rustup"
    mkdir -p "${install_dir}/cargo"
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain "${DEPOT_BUILDER_VERSION}" --profile minimal --no-modify-path
fi

export PATH="${PATH}:${CARGO_HOME}/bin"

echo "PATH=${PATH}" >> "${GITHUB_ENV}"
echo ">>> $(cargo version)"
