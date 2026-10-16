#!/bin/bash
# Download the ROCKNIX H700 release image and verify its SHA-256 checksum.
set -euo pipefail
source "$(dirname "$0")/config.sh"

mkdir -p "$ROCKNIX_DL"
cd "$ROCKNIX_DL"

curl -fsSL -o "$ROCKNIX_IMAGE.sha256" "$ROCKNIX_URL.sha256"
if [ ! -f "$ROCKNIX_IMAGE" ]; then
  echo "Downloading $ROCKNIX_IMAGE ..."
  curl -fL --retry 3 -o "$ROCKNIX_IMAGE.part" "$ROCKNIX_URL"
  mv "$ROCKNIX_IMAGE.part" "$ROCKNIX_IMAGE"
fi

expected="$(awk '{print $1}' "$ROCKNIX_IMAGE.sha256")"
actual="$(sha256sum "$ROCKNIX_IMAGE" | awk '{print $1}')"
if [ "$expected" != "$actual" ]; then
  echo "Checksum mismatch: expected $expected, got $actual" >&2
  exit 1
fi
echo "OK: $ROCKNIX_IMAGE ($actual)"
