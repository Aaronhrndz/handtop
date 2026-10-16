# Third-party components

The MIT license in `LICENSE` covers only this project's own files (build scripts, overlay
configuration, `src/`, `tools/`, docs). The SD card image also contains the following,
each under its own license.

## Hardware layer from ROCKNIX (`20261001`)

Taken unmodified from the official image
`ROCKNIX-H700.aarch64-20261001-DDR4.img.gz` (https://github.com/ROCKNIX/distribution/releases/tag/20261001):

| Component | License | Source |
|---|---|---|
| Linux kernel 7.2.0 (`KERNEL`), kernel modules, device trees | GPL-2.0 | ROCKNIX `20261001` tag: `projects/ROCKNIX/packages/linux` (linux 7.2 + patches), `projects/ROCKNIX/devices/H700/` |
| U-Boot (SPL + U-Boot) | GPL-2.0+ | ROCKNIX `20261001` tag, U-Boot package and H700 device files |
| Firmware blobs (Wi-Fi/Bluetooth, etc.) | Various redistributable vendor licenses | ROCKNIX `20261001` tag / linux-firmware |

`build/01-fetch-rocknix.sh` downloads that exact image (SHA-256 checked) and
`build/02-extract-rocknix.sh` extracts these parts.

## Built by this project from GPL sources

| Component | License | Source |
|---|---|---|
| `sunxi-cedrus.ko` (video decoder module) | GPL-2.0 | linux 7.2 (kernel.org) + ROCKNIX `20261001` kernel patches + `build/kernel/0001-cedrus-add-h616-variant.patch` (Chen-Yu Tsai, upstream "arm64: allwinner: h616: Support Video Engine" v3), built by `build/06b-cedrus.sh` |
| Video-engine device-tree overlay | GPL-2.0 / MIT (as upstream sunxi DTs) | `build/dts/rg35xxh-video-engine.dtso`, based on patch 7/7 of the same series |
| nwg-drawer v0.7.5 | MIT | https://github.com/nwg-piotr/nwg-drawer, built by `build/04b-nwg-drawer.sh` |

## Packages

- **Debian 13 "trixie"** packages, unmodified from deb.debian.org; licenses in `/usr/share/doc/*/copyright` on the device.
- **Moonlight (moonlight-qt)**, GPL-3.0, from the official Moonlight repository (dl.cloudsmith.io). Source: https://github.com/moonlight-stream/moonlight-qt
- **Tailscale**, BSD-3-Clause, from the official repository (pkgs.tailscale.com). Source: https://github.com/tailscale/tailscale

## Thanks

- ROCKNIX for the H700 kernel, U-Boot and device support this project stands on.
- MrJackSpade/RG35XXP-XFCE for showing that a desktop on these devices is practical.
