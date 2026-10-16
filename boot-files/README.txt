Handtop (Debian desktop for the RG35XX H) - boot partition
===========================================================

Files you may edit on this partition (from Windows):
  wifi.txt               Wi-Fi network. Imported at next boot, password is then removed from the file.
  rg35xxh-input.conf     Controls (speeds, button actions). Applies after re-login/reboot.
  logs\boot-NNNN.txt     Diagnostic logs of the last 5 boots (written by the device).

Screen garbled or black?  Your board may have the newer "rev6" panel:
  copy device_trees\sun50i-h700-anbernic-rg35xx-h-rev6-panel.dtb over dtb.img
  (use "Safely remove" / Eject before taking the card out).

Login: user "rg", password "rg35xxh". SSH is off: turn it on with Apps > Enable SSH
(it asks you to choose your own password first).
Do not edit KERNEL, dtb.img or extlinux\ unless you know what you are doing.
