# ROCKNIX H700 Quirks — Porting Notes

Extracted by `build/02-extract-rocknix.sh` into `work/rocknix/quirks/` and `work/rocknix/system/`.
Most ROCKNIX quirk scripts only write ROCKNIX-specific settings files; the table lists what each one actually does to the hardware and whether we port it.

| ROCKNIX script | Effect on hardware | Port? |
|---|---|---|
| `001-device_config` | Temp sensor = `thermal_zone2` | Reference only (Waybar/htop) |
| `010-governors` | CPU policy `cpufreq/policy0`; GPU devfreq `1800000.gpu` | **Yes** — paths for our governor/“screen off” service |
| `400-set_gpu_overclock` | GPU max 600 MHz (648 MHz when overclocked) | **Yes** — keep 600 MHz default |
| `010-led_control`, `bin/ledcontrol` | LEDs `green:power`, `red:status` via `/sys/class/leds` | **Yes** — status LED blink on shutdown |
| `030-suspend_mode` | Disables suspend, logind ignores power key | **Partly** — our input daemon owns the power key (`HandlePowerKey=ignore`) |
| `sleep.d/pre`, `sleep.d/post` | CPU1–3 offline, powersave governors, `amixer -c0 sset DAC off/on` | **Yes** — basis for “screen off” mode and sleep tests |
| `common/050-audio` | PipeWire; `amixer -c0 sset Master 100%`; volume via PipeWire | **Yes** — set ALSA Master 100% at boot |
| `common/020-rumble` | Rumble switch at `/sys/devices/platform/**/rumble_enable` | **Yes** — ensure enabled for shutdown haptic |
| `common/055-hdmi-check` | Picks 720p/1080p DRM mode for EmulationStation | No — labwc handles outputs |
| `030-analog_leds`, `bin/analog_sticks_ledcontrol` | RGB stick LEDs over `/dev/ttyS2` (other models) | No — RG35XX H has no stick LEDs |
| `002-turbo-mode`, `020-fan_control`, `050-modifiers`, `090/091-ui_*`, `020-set_audio_latency` | ROCKNIX UI settings only | No |
| `bin/gpu_overclock` | see above | merged into governor service |

## Hardware layer contents (ROCKNIX 20260901)

- Kernel `7.2.0`; most drivers built in, ~100 loadable modules.
- Firmware: `rtw88/rtw8821c_fw.bin` (Wi-Fi), `rtl_bt/rtl8821cs_*` (BT), `panels/`, `regulatory.db`.
- Bootloader: `H700_DDR4_u-boot-sunxi-with-spl.bin`, written raw at 8 KiB on the card (verified identical to the image).
- `rocknix-fake-suspend` kept as reference for the “screen off” mode.
