#!/bin/bash
# Cross-compile nwg-drawer for arm64 on the (x86_64) build host, using the rootfs as sysroot.
# Needs: Go >= 1.25 ($GO_TOOLCHAIN), gcc-aarch64-linux-gnu, pkg-config on the host.
set -euo pipefail
source "$(dirname "$0")/config.sh"
source "$(dirname "$0")/lib/chroot.sh"
trap chroot_umount EXIT

SRC="$WORK/src/nwg-drawer"
DEV_PKGS="libgtk-3-dev libgtk-layer-shell-dev libgirepository1.0-dev"

# Temporary build dependencies inside the rootfs (removed again at the end).
chroot_mount
in_chroot "apt-get update -qq && apt-get install -y -qq --no-install-recommends $DEV_PKGS"
chroot_umount

[ -e "$SRC" ] && safe_rm -r "$SRC"
mkdir -p "$(dirname "$SRC")"
git clone -q --depth 1 -b "$NWG_DRAWER_VERSION" https://github.com/nwg-piotr/nwg-drawer "$SRC"

export CGO_ENABLED=1 GOOS=linux GOARCH=arm64
export CC="aarch64-linux-gnu-gcc --sysroot=$ROOTFS"
export PKG_CONFIG_SYSROOT_DIR="$ROOTFS"
export PKG_CONFIG_LIBDIR="$ROOTFS/usr/lib/aarch64-linux-gnu/pkgconfig:$ROOTFS/usr/share/pkgconfig"
export GOPATH="$WORK/gopath" GOCACHE="$WORK/gocache" GOFLAGS="-trimpath"
(cd "$SRC" && "$GO_TOOLCHAIN" build -ldflags "-s -w" -o bin/nwg-drawer .)
file "$SRC/bin/nwg-drawer" | grep -q 'ARM aarch64' || { echo "Build did not produce an arm64 binary" >&2; exit 1; }

install -Dm755 "$SRC/bin/nwg-drawer" "$ROOTFS/usr/local/bin/nwg-drawer"
mkdir -p "$ROOTFS/usr/share/nwg-drawer"
cp -r "$SRC/desktop-directories" "$SRC/img" "$SRC/drawer.css" "$ROOTFS/usr/share/nwg-drawer/"
install -Dm644 "$SRC/LICENSE" "$ROOTFS/usr/share/licenses/nwg-drawer/LICENSE"

chroot_mount
in_chroot "apt-get purge -y -qq $DEV_PKGS && apt-get autoremove -y -qq --purge && apt-get clean"
safe_rm -r "$ROOTFS"/var/lib/apt/lists/*
mkdir -p "$ROOTFS/var/lib/apt/lists/partial"
in_chroot "ldd /usr/local/bin/nwg-drawer | grep -q 'not found' && exit 1 || true"
echo "nwg-drawer $NWG_DRAWER_VERSION installed."
