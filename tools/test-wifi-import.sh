#!/bin/bash
# Tests rg35xxh-wifi-import with a fake nmcli (no network changes). Uses work/test-wifi/.
set -euo pipefail
source "$(dirname "$(realpath "$0")")/../build/config.sh"
T="$WORK/test-wifi"; [ -e "$T" ] && safe_rm -r "$T"; mkdir -p "$T"
cat > "$T/nmcli" <<'N'
#!/bin/sh
echo "nmcli $*" >> "$(dirname "$0")/calls.log"
case "$*" in "-t -f NAME connection show") echo "wifi-OldNet";; esac
exit 0
N
chmod +x "$T/nmcli"
S="$TOP/overlay/usr/local/sbin/rg35xxh-wifi-import"
fail=0
check() { if eval "$2"; then echo "ok    $1"; else echo "FAIL  $1"; fail=1; fi; }

# 1. Windows file (BOM + CRLF), password with spaces and '='
printf '\xEF\xBB\xBF# comment\r\nSSID=My Home 5G\r\nPASSWORD= p@ss w=rd \r\nCOUNTRY=DE\r\n' > "$T/wifi.txt"
WIFI_FILE="$T/wifi.txt" NMCLI="$T/nmcli" IW=true bash "$S" > "$T/out1.txt"
check "adds WPA connection" "grep -q 'connection add type wifi con-name wifi-My Home 5G ssid My Home 5G wifi-sec.key-mgmt wpa-psk wifi-sec.psk p@ss w=rd connection.autoconnect yes' '$T/calls.log'"
check "password blanked" "grep -qx 'PASSWORD=' '$T/wifi.txt'"
check "secret gone from file" "! grep -q 'p@ss' '$T/wifi.txt'"
check "SSID kept" "grep -qx 'SSID=My Home 5G' '$T/wifi.txt'"
check "marked imported" "grep -q '^# imported ' '$T/wifi.txt'"
check "CR/BOM removed" "! grep -q \$'\\r' '$T/wifi.txt' && ! head -c3 '$T/wifi.txt' | grep -q \$'\\xEF'"

# 2. Second boot: nothing re-imported
: > "$T/calls.log"
WIFI_FILE="$T/wifi.txt" NMCLI="$T/nmcli" IW=true bash "$S" > "$T/out2.txt"
check "no re-import on next boot" "! grep -q 'connection add' '$T/calls.log'"

# 3. Existing connection replaced; open network
printf 'SSID=OldNet\nPASSWORD=\n' > "$T/wifi2.txt"
: > "$T/calls.log"
WIFI_FILE="$T/wifi2.txt" NMCLI="$T/nmcli" IW=true bash "$S" > "$T/out3.txt"
check "old connection deleted" "grep -q 'connection delete wifi-OldNet' '$T/calls.log'"
check "open network without psk" "grep -q 'connection add type wifi con-name wifi-OldNet ssid OldNet connection.autoconnect yes' '$T/calls.log' && ! grep -q psk '$T/calls.log'"

# 4. Empty template: no-op
cp "$TOP/boot-files/wifi.txt" "$T/wifi3.txt"; : > "$T/calls.log"
WIFI_FILE="$T/wifi3.txt" NMCLI="$T/nmcli" IW=true bash "$S" > "$T/out4.txt"
check "empty template does nothing" "! grep -q 'connection' '$T/calls.log' && cmp -s '$T/wifi3.txt' '$TOP/boot-files/wifi.txt'"
# 5. Quoted values are accepted (quotes removed)
printf 'SSID="Cafe Net"\nPASSWORD="pa ss"\n' > "$T/wifi5.txt"; : > "$T/calls.log"
WIFI_FILE="$T/wifi5.txt" NMCLI="$T/nmcli" IW=true bash "$S" > "$T/out5.txt"
check "quotes stripped" "grep -q 'con-name wifi-Cafe Net ssid Cafe Net wifi-sec.key-mgmt wpa-psk wifi-sec.psk pa ss ' '$T/calls.log'"
safe_rm -r "$T"
exit $fail
