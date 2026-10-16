#!/bin/bash
# Install the input daemon (src/inputd) into the rootfs after running its unit tests.
set -euo pipefail
source "$(dirname "$(realpath "$0")")/config.sh"
assert_rootfs
PYTHONDONTWRITEBYTECODE=1 python3 "$TOP/src/inputd/tests/test_core.py"
DEST="$ROOTFS/usr/local/lib/rg35xxh-inputd"
[ -e "$DEST" ] && safe_rm -r "$DEST"
mkdir -p "$DEST"
rsync -a --exclude __pycache__ "$TOP/src/inputd/rg35xxh_inputd" "$DEST/"
chmod -R u=rwX,go=rX "$DEST"
echo "Input daemon installed."
