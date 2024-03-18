#!/usr/bin/env bash
set -euo pipefail

curl -o go.tar.gz "https://dl.google.com/go/go${DEPOT_BUILDER_VERSION}.linux-amd64.tar.gz"
sudo tar -C /usr/local -xzf go.tar.gz

export PATH="${PATH}:/usr/local/go/bin"

echo ">>> $(go version)"
