#!/bin/bash
# Install the ROCKNIX hardware layer pieces that live in the root filesystem:
# kernel modules, firmware, and our ported hardware-init service.
set -euo pipefail
source "$(dirname "$0")/config.sh"
source "$(dirname "$0")/lib/chroot.sh"
trap chroot_umount EXIT

[ -d "$ROCKNIX_EX/modules/$KVER" ] || { echo "Run 02-extract-rocknix.sh first." >&2; exit 1; }

mkdir -p "$ROOTFS/usr/lib/modules" "$ROOTFS/usr/lib/firmware"
rsync -a --delete "$ROCKNIX_EX/modules/$KVER/" "$ROOTFS/usr/lib/modules/$KVER/"
rsync -a "$ROCKNIX_EX/firmware/" "$ROOTFS/usr/lib/firmware/"

chroot_mount
in_chroot "depmod -a $KVER"
in_chroot "systemctl enable rg35xxh-hwinit.service"
echo "Hardware layer installed: $(find "$ROOTFS/usr/lib/modules/$KVER" -name '*.ko*' | wc -l) modules."
