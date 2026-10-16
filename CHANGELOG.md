# Handtop changelog

## v0.1.1

- Fix: Wi-Fi could stop passing traffic while still shown as connected (Realtek rtw88 driver stall with Wi-Fi power save on). Power save is now off during normal use (`/etc/NetworkManager/conf.d/50-rg35xxh-wifi-powersave.conf`); screen-off mode still turns it on and now turns it back off afterwards. Side effect: steadier Wi-Fi latency.
- Build: the Go toolchain download is pinned and SHA-256 checked, for x86_64 and arm64 build hosts.
- README: device photo.

## v0.1.0 — first public release

- ROCKNIX `20261001` hardware layer (kernel 7.2.0) + Debian 13 trixie + labwc desktop
- Input daemon: desktop mode (pointer, clicks, scroll, keys, copy/paste), gamepad mode (Xbox 360 pad), on-screen keyboard, volume/brightness with on-screen bars, power button (menu / 3 s shutdown), stick re-centring
- Moonlight with Cedrus hardware decoding (H.264/HEVC, 1080p60)
- Tailscale with tray icon and QR login
- HDMI hot-plug with monitor-only / extend / mirror modes
- Sleep (s2idle) and auto-sleep; charging while off
- `wifi.txt` import from the boot partition; boot logs on the boot partition
- Firefox ESR with low-RAM settings and uBlock Origin; zram + 2 GB swap file
- SSH off by default; Apps → Enable SSH sets your own password first
