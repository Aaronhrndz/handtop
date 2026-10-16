#!/bin/bash
# Desktop session: auto-login on tty1 into labwc, toolkit defaults, shell defaults.
# (Config files themselves come from overlay/, copied by 05-configure-base.sh.)
set -euo pipefail
source "$(dirname "$0")/config.sh"
source "$(dirname "$0")/lib/chroot.sh"
trap chroot_umount EXIT

# Auto-login on tty1; /etc/profile.d/zz-rg35xxh-session.sh then starts labwc.
mkdir -p "$ROOTFS/etc/systemd/system/getty@tty1.service.d"
cat > "$ROOTFS/etc/systemd/system/getty@tty1.service.d/autologin.conf" <<A
[Service]
ExecStart=
ExecStart=-/sbin/agetty -o '-p -f -- \\\\u' --noclear --autologin $USER_NAME %I \$TERM
A

# Bracketed paste: a pasted newline never executes a command (R3 = paste).
grep -q 'enable-bracketed-paste' "$ROOTFS/etc/inputrc" || \
  printf '\n# RG35XX H: pasted text is never executed automatically\nset enable-bracketed-paste on\n' >> "$ROOTFS/etc/inputrc"

# Standard per-user dirs some apps expect to exist.
for d in .cache .config .local/share .local/state; do
  mkdir -p "$ROOTFS/etc/skel/$d" "$ROOTFS/home/$USER_NAME/$d"
done

chroot_mount
in_chroot "chown -R $USER_NAME: /home/$USER_NAME"
in_chroot "glib-compile-schemas /usr/share/glib-2.0/schemas"
in_chroot "fc-cache -f >/dev/null"
in_chroot "systemctl enable getty@tty1.service"
echo "Desktop session configured."
