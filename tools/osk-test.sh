#!/bin/bash
# Visual test of the on-screen keyboard in headless labwc (640x480), without the input daemon.
# (The daemon itself is NOT run here: inside the chroot it would see and grab the build
#  server's own input devices.)
set -euo pipefail
source "$(dirname "$(realpath "$0")")/../build/config.sh"
source "$(dirname "$(realpath "$0")")/../build/lib/chroot.sh"
trap chroot_umount EXIT
chroot_mount
UID_T=$(chroot "$ROOTFS" id -u "$USER_NAME")
mkdir -p "$ROOTFS/run/user/$UID_T" && chroot "$ROOTFS" chown "$USER_NAME:" "/run/user/$UID_T" && chmod 700 "$ROOTFS/run/user/$UID_T"
T="$ROOTFS/tmp/osktest"; [ -e "$T" ] && safe_rm -r "$T"; mkdir -p "$T"; chmod 777 "$T"
cat > "$T/osk.py" <<'PY'
import sys
sys.path.insert(0, "/usr/local/lib/rg35xxh-inputd")
from gi.repository import GLib, Gtk
from rg35xxh_inputd.osk import OnScreenKeyboard
typed = []
k = OnScreenKeyboard(lambda mods, key: typed.append("+".join(mods + [key])))
k.toggle()
steps = [lambda: k.move(1, 0), lambda: k.move(1, 0), lambda: k.move(0, 1),   # h -> j -> k, down -> ','
         lambda: k.press_selected(),                                         # type ','
         lambda: k.move(0, -2), lambda: k.press_selected(),                  # up 2 -> 'i'? type it
         lambda: (k.move(-20, 0), k.move(0, 1))[0],                          # navigate to '⇧' row start
         lambda: k.press_selected()]                                         # latch Shift
def step():
    if steps:
        steps.pop(0)()
        return True
    open("/tmp/osktest/typed.txt", "w").write("\n".join(typed) + "\n")
    return False
GLib.timeout_add(1500, step)
Gtk.main()
PY
cat > "$T/run.sh" <<'S'
wlr-randr --output HEADLESS-1 --custom-mode 640x480
foot &
python3 /tmp/osktest/osk.py > /tmp/osktest/osk.log 2>&1 &
sleep 45; grim /tmp/osktest/osk.png; labwc --exit
S
chmod +x "$T/run.sh"
timeout 150 chroot "$ROOTFS" runuser -u "$USER_NAME" -- env HOME="/home/$USER_NAME" XDG_RUNTIME_DIR="/run/user/$UID_T" \
  WLR_BACKENDS=headless WLR_RENDERER=pixman WLR_LIBINPUT_NO_DEVICES=1 \
  dbus-run-session labwc -C /tmp/osktest -s /tmp/osktest/run.sh > "$WORK/osk-test-labwc.log" 2>&1 || true
mkdir -p "$WORK/screens"; cp "$T/osk.png" "$WORK/screens/6-osk.png" 2>/dev/null || true
echo "--- typed:"; cat "$T/typed.txt" 2>/dev/null || true
echo "--- log:"; cat "$T/osk.log" 2>/dev/null | tail -5 || true
safe_rm -r "$T"
