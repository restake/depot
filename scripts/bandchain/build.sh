#!/usr/bin/env bash
set -euo pipefail

cd "${DEPOT_PROJECT_NAME}"
mkdir bin

# Try to install required C libraries via apt first (faster)
echo "Installing required C libraries..."
if sudo apt-get install -y libgo-owasm-dev wasmtime-dev 2>/dev/null; then
    echo "C libraries installed via apt"
else
    echo "C libraries not available via apt, using pre-built binaries..."

    # Download pre-built wasmtime instead of building from Rust
    cd /tmp
    WASMTIME_VERSION="v20.0.0"
    wget "https://github.com/bytecodealliance/wasmtime/releases/download/${WASMTIME_VERSION}/wasmtime-${WASMTIME_VERSION}-x86_64-linux.tar.xz"
    tar -xf "wasmtime-${WASMTIME_VERSION}-x86_64-linux.tar.xz"
    sudo cp wasmtime-${WASMTIME_VERSION}-x86_64-linux/wasmtime /usr/local/bin/
    sudo chmod +x /usr/local/bin/wasmtime

    # Build and install go-owasm from source (Go only)
    cd /tmp
    git clone https://github.com/bandprotocol/go-owasm.git
    cd go-owasm
    make build
    sudo make install

    # Return to BandChain directory
    cd "${GITHUB_WORKSPACE}/${DEPOT_PROJECT_NAME}"
fi

# Build BandChain with static linking for cross-machine deployment
echo "Building BandChain with static linking..."
export CGO_ENABLED=1
export GOOS=linux
export GOARCH=amd64
export CGO_LDFLAGS="-static -L/usr/local/lib"
export CGO_CFLAGS="-I/usr/local/include"

# Force static linking for portability
make CC="x86_64-linux-musl-gcc" CGO_LDFLAGS="-static -L/usr/local/lib" LEDGER_ENABLED=false LINK_STATICALLY=true install

# Verify the binary is static
echo "Verifying static binary..."
if ldd "${GITHUB_WORKSPACE}/tools/go-1.24.3/bin/bandd" 2>/dev/null; then
    echo "ERROR: Binary is not static - will fail on other machines!"
    exit 1
else
    echo "✅ Binary is static - ready for cross-machine deployment"
fi

build_binaries="$(deno run --allow-read --allow-env ../utils/binaries.ts)"

echo "${build_binaries}" | jq -r 'to_entries[] | "\(.key) \(.value)"' | while read -r binary path; do
    # 'make install' puts the binary in the Go bin directory
    mv -v "${GITHUB_WORKSPACE}/tools/go-1.24.3/bin/${binary}" "${path}"
done
