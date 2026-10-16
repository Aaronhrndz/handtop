# Handtop changelog

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
