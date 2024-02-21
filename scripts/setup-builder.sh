#!/bin/bash

CONFIG_FILE="config.yml"
PROTOCOL_NAME="$BINARY_PROTOCOL"

PROTOCOL_CONFIG=$(yq eval ".[] | select(.name == \"$PROTOCOL_NAME\")" "$CONFIG_FILE" -j)

echo "$PROTOCOL_CONFIG"

if [ -z "$PROTOCOL_CONFIG" ]; then
  echo "Error: Protocol '$PROTOCOL_NAME' not found in $CONFIG_FILE"
  exit 1
fi

BUILDER=$(echo "$PROTOCOL_CONFIG" | jq -r '.builder')
BUILDER_VERSION=$(echo "$PROTOCOL_CONFIG" | jq -r '.builder_version')

if [ "$BUILDER" = "go" ]; then
  wget -O go.tar.gz "https://dl.google.com/go/go${BUILDER_VERSION}.linux-amd64.tar.gz"
  sudo tar -C /usr/local -xzf go.tar.gz
  export PATH=$PATH:/usr/local/go/bin
elif [ "$BUILDER" = "rust" ]; then
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain $BUILDER_VERSION
  export PATH=$PATH:$HOME/.cargo/bin
else
  echo "Error: Unsupported builder type '$BUILDER'"
  exit 1
fi

echo "$BUILDER version: $($BUILDER --version)"