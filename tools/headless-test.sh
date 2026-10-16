#!/bin/bash
# Smoke-test the desktop without hardware: run labwc (headless, software renderer) inside the
# arm64 rootfs under emulation at 640x480 and take screenshots into work/screens/.
set -euo pipefail
source "$(dirname "$(realpath "$0")")/../build/config.sh"
source "$(dirname "$(realpath "$0")")/../build/lib/chroot.sh"
trap chroot_umount EXIT
chroot_mount
UID_T=$(chroot "$ROOTFS" id -u "$USER_NAME")
mkdir -p "$ROOTFS/run/user/$UID_T" && chroot "$ROOTFS" chown "$USER_NAME:" "/run/user/$UID_T" && chmod 700 "$ROOTFS/run/user/$UID_T"
[ -e "$ROOTFS/tmp/screens" ] && safe_rm -r "$ROOTFS/tmp/screens"
mkdir -p "$ROOTFS/tmp/screens"; chmod 777 "$ROOTFS/tmp/screens"
cat > "$ROOTFS/tmp/screens/run.sh" <<'S'
sleep 4
wlr-randr --output HEADLESS-1 --custom-mode 640x480
sleep 90; grim /tmp/screens/1-desktop.png
foot & sleep 15; grim /tmp/screens/2-terminal.png
rg35xxh-power-menu & sleep 15; grim /tmp/screens/3-power-menu.png; pkill -x wlogout
rg35xxh-drawer & sleep 45; grim /tmp/screens/4-drawer.png
labwc --exit
S
chmod +x "$ROOTFS/tmp/screens/run.sh"
timeout 300 chroot "$ROOTFS" runuser -u "$USER_NAME" -- env HOME="/home/$USER_NAME" \
  XDG_RUNTIME_DIR="/run/user/$UID_T" WLR_BACKENDS=headless WLR_RENDERER=pixman WLR_LIBINPUT_NO_DEVICES=1 \
  dbus-run-session labwc -s /tmp/screens/run.sh > "$WORK/headless.log" 2>&1 || true
mkdir -p "$WORK/screens" && cp "$ROOTFS"/tmp/screens/*.png "$WORK/screens/" 2>/dev/null || true
safe_rm -r "$ROOTFS/tmp/screens"   # /run in the chroot is a tmpfs, removed on unmount
ls -la "$WORK/screens"
cp -r "$ROOTFS/home/$USER_NAME/.local/state/session" "$WORK/screens/session-logs" 2>/dev/null || true
