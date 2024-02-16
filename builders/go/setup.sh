#!/usr/bin/env bash
set -euo pipefail
install_dir="${GITHUB_WORKSPACE}/tools/go"

if ! [ -d "${install_dir}" ]; then
    mkdir -p "${install_dir}"
    curl -o go.tar.gz "https://dl.google.com/go/go${DEPOT_BUILDER_VERSION}.linux-amd64.tar.gz"
    tar --strip-components=1 -C "${install_dir}" -xzf go.tar.gz
fi

export PATH="${PATH}:${install_dir}/bin"
echo "PATH=${PATH}" >> "${GITHUB_ENV}"
echo ">>> $(go version)"
