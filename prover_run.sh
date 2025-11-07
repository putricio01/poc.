#!/usr/bin/env bash
set -euo pipefail

apt update
apt install -y wget curl

# release version
if [ -z "${SCROLL_ZKVM_VERSION:-}" ]; then
  echo "SCROLL_ZKVM_VERSION not set"
  exit 1
fi

# Use host.docker.internal if you run this inside Docker on Mac/Windows
BASE_URL="${BASE_URL:-http://host.docker.internal:8000}"

BASE_DOWNLOAD_DIR="/openvm"
mkdir -p "$BASE_DOWNLOAD_DIR"

# Define URLs for OpenVM files (No checksum verification)
# NOTE: keep this minimal to match what you served locally
OPENVM_URLS=(
  "${BASE_URL}/releases/${SCROLL_ZKVM_VERSION}/chunk/app.vmexe"
  "${BASE_URL}/releases/${SCROLL_ZKVM_VERSION}/verifier/verifier.bin"
  "${BASE_URL}/releases/${SCROLL_ZKVM_VERSION}/verifier/openVmVk.json"
  # If you also want to demo params, first create them under /tmp/test-openvm/releases/params and then uncomment:
  # "${BASE_URL}/releases/params/kzg_bn254_22.srs"
  # "${BASE_URL}/releases/params/kzg_bn254_24.srs"
)

# Download OpenVM files (No checksum verification)
for url in "${OPENVM_URLS[@]}"; do
  dest_subdir="$BASE_DOWNLOAD_DIR/$(basename "$(dirname "$url")")"
  mkdir -p "$dest_subdir"
  filepath="$dest_subdir/$(basename "$url")"
  echo "Downloading $filepath..."
  curl -fsSL -o "$filepath" -L "$url"
done

mkdir -p "$HOME/.openvm"
ln -sf "/openvm/params" "$HOME/.openvm/params" || true

mkdir -p /usr/local/bin
wget -q https://github.com/ethereum/solidity/releases/download/v0.8.19/solc-static-linux -O /usr/local/bin/solc || true
chmod +x /usr/local/bin/solc || true

mkdir -p /openvm/cache

echo "Skipping /prover/prover for PoC"
exit 0
