#!/bin/bash
# Focused test: run only waybar in headless labwc (640x480) for 90 s; log + screenshot to work/screens/.
set -euo pipefail
source "$(dirname "$(realpath "$0")")/../build/config.sh"
source "$(dirname "$(realpath "$0")")/../build/lib/chroot.sh"
trap chroot_umount EXIT
chroot_mount
UID_T=$(chroot "$ROOTFS" id -u "$USER_NAME")
mkdir -p "$ROOTFS/run/user/$UID_T" && chroot "$ROOTFS" chown "$USER_NAME:" "/run/user/$UID_T" && chmod 700 "$ROOTFS/run/user/$UID_T"
T="$ROOTFS/tmp/wbtest"; [ -e "$T" ] && safe_rm -r "$T"; mkdir -p "$T"; chmod 777 "$T"
cat > "$T/run.sh" <<'S'
wlr-randr --output HEADLESS-1 --custom-mode 640x480
waybar -l debug > /tmp/wbtest/waybar.log 2>&1 &
sleep 90; grim /tmp/wbtest/bar.png; pgrep -a waybar > /tmp/wbtest/ps.txt || true; labwc --exit
S
chmod +x "$T/run.sh"
timeout 200 chroot "$ROOTFS" runuser -u "$USER_NAME" -- env HOME="/home/$USER_NAME" XDG_RUNTIME_DIR="/run/user/$UID_T" \
  WLR_BACKENDS=headless WLR_RENDERER=pixman WLR_LIBINPUT_NO_DEVICES=1 \
  dbus-run-session labwc -C /tmp/wbtest -s /tmp/wbtest/run.sh > "$WORK/waybar-test-labwc.log" 2>&1 || true
mkdir -p "$WORK/screens"; cp "$T/bar.png" "$WORK/screens/5-bar.png" 2>/dev/null || true
cp "$T/waybar.log" "$T/ps.txt" "$WORK/screens/" 2>/dev/null || true
safe_rm -r "$T"
echo "waybar processes:"; cat "$WORK/screens/ps.txt" 2>/dev/null || true
