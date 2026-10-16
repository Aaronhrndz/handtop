# Start the labwc desktop on tty1 after auto-login.
# Logging out of labwc returns to getty, which logs in again = session restart.
# Gives up after 3 quick failures per boot and leaves a shell on tty1.
if [ "$(tty)" = "/dev/tty1" ] && [ -z "${WAYLAND_DISPLAY:-}" ] && [ -z "${RG_NO_DESKTOP:-}" ]; then
  _rg_count="${XDG_RUNTIME_DIR:-/tmp}/rg35xxh-session-starts"
  _rg_n=$(( $(cat "$_rg_count" 2>/dev/null || echo 0) + 1 ))
  echo "$_rg_n" > "$_rg_count"
  if [ "$_rg_n" -le 3 ]; then
    mkdir -p "$HOME/.local/state"
    exec labwc > "$HOME/.local/state/labwc.log" 2>&1
  fi
  echo "labwc failed to start 3 times; see ~/.local/state/labwc.log (shell left on tty1)."
fi
