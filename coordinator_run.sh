#!/usr/bin/env bash
set -euo pipefail

apt update
apt install -y wget curl || true

if [ -z "${SCROLL_ZKVM_VERSION:-}" ]; then
  echo "SCROLL_ZKVM_VERSION not set"
  exit 1
fi

# Default to host machine http server usable from containers
BASE_URL="${BASE_URL:-http://host.docker.internal:8000}"

BASE_DOWNLOAD_DIR="/openvm"
mkdir -p "$BASE_DOWNLOAD_DIR"

OPENVM_URLS=(
  "${BASE_URL}/releases/${SCROLL_ZKVM_VERSION}/verifier/verifier.bin"
  "${BASE_URL}/releases/${SCROLL_ZKVM_VERSION}/verifier/openVmVk.json"
  "${BASE_URL}/releases/${SCROLL_ZKVM_VERSION}/chunk/app.vmexe"
  # add params if you created them
  # "${BASE_URL}/releases/params/kzg_bn254_22.srs"
)

for url in "${OPENVM_URLS[@]}"; do
  dest_subdir="$BASE_DOWNLOAD_DIR/$(basename "$(dirname "$url")")"
  mkdir -p "$dest_subdir"
  filepath="$dest_subdir/$(basename "$url")"
  echo "Downloading $filepath..."
  curl -fsSL -o "$filepath" -L "$url"
done

echo "Coordinator PoC done - downloaded files to $BASE_DOWNLOAD_DIR"
# keep container alive for inspection if desired
tail -f /dev/null
