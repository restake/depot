#!/usr/bin/env bash
set -euo pipefail

install_dir="${GITHUB_WORKSPACE}/tools/go-${DEPOT_BUILDER_VERSION}"

if ! [ -d "${install_dir}" ]; then
    echo ">>> Installing Go with version ${DEPOT_BUILDER_VERSION}"
    mkdir -p "${install_dir}"
    curl -L -o go.tar.gz "https://go.dev/dl/go${DEPOT_BUILDER_VERSION}.linux-amd64.tar.gz"
    tar --strip-components=1 -C "${install_dir}" -xf go.tar.gz
    rm go.tar.gz
fi

export PATH="${install_dir}/bin:${PATH}"

echo "PATH=${PATH}" >> "${GITHUB_ENV}"
echo ">>> $(go version)"
