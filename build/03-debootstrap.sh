#!/bin/bash
# Create a minimal Debian arm64 root filesystem in $ROOTFS.
set -euo pipefail
source "$(dirname "$0")/config.sh"

if [ -e "$ROOTFS/etc/debian_version" ]; then
  echo "Rootfs already exists at $ROOTFS (delete it to rebuild)."; exit 0
fi
mkdir -p "$ROOTFS"
debootstrap --arch=arm64 --variant=minbase \
  --include=systemd,systemd-sysv,udev,dbus,apt-transport-https,ca-certificates,locales,tzdata,sudo,kmod,iproute2 \
  "$DEBIAN_SUITE" "$ROOTFS" "$DEBIAN_MIRROR"

cat > "$ROOTFS/etc/apt/sources.list" <<SRC
deb $DEBIAN_MIRROR $DEBIAN_SUITE main contrib non-free non-free-firmware
deb $DEBIAN_MIRROR $DEBIAN_SUITE-updates main contrib non-free non-free-firmware
deb https://security.debian.org/debian-security $DEBIAN_SUITE-security main contrib non-free non-free-firmware
deb $DEBIAN_MIRROR $DEBIAN_SUITE-backports main contrib non-free non-free-firmware
SRC
echo "Debian $(cat "$ROOTFS/etc/debian_version") arm64 rootfs created."
