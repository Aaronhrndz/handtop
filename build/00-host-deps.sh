#!/bin/bash
# Install build-host dependencies (Debian/Ubuntu host, run as root).
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq || true
apt-get install -y -qq --no-install-recommends \
  debootstrap qemu-user-static binfmt-support \
  parted fdisk dosfstools e2fsprogs mtools squashfs-tools device-tree-compiler \
  qemu-system-arm rsync xz-utils cpio lz4 zstd gzip file curl ca-certificates \
  debian-archive-keyring u-boot-tools \
  gcc-aarch64-linux-gnu pkg-config git \
  bc bison flex libelf-dev libssl-dev kmod   # kernel module build (06b-cedrus.sh)

# Register ARM64 emulation (needed to run package scripts inside the arm64 rootfs).
mountpoint -q /proc/sys/fs/binfmt_misc || mount -t binfmt_misc binfmt_misc /proc/sys/fs/binfmt_misc
if [ ! -e /proc/sys/fs/binfmt_misc/qemu-aarch64 ]; then
  if ! update-binfmts --enable qemu-aarch64 2>/dev/null; then
    cat /usr/lib/binfmt.d/qemu-aarch64.conf > /proc/sys/fs/binfmt_misc/register
  fi
fi
grep -q enabled /proc/sys/fs/binfmt_misc/qemu-aarch64 && echo "qemu-aarch64 binfmt: enabled"

# Go toolchain (>= 1.25) for cross-compiling nwg-drawer; Ubuntu/Debian packaged Go may be too old.
source "$(dirname "$0")/config.sh"
if [ ! -x "$GO_TOOLCHAIN" ]; then
  GOV=$(curl -fsSL 'https://go.dev/VERSION?m=text' | head -1)
  mkdir -p "$WORK/tools"
  curl -fsSL "https://go.dev/dl/${GOV}.linux-amd64.tar.gz" | tar -xz -C "$WORK/tools"
fi
"$GO_TOOLCHAIN" version
