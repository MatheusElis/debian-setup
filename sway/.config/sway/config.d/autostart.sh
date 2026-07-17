#!/bin/bash

# Autostart applications
## Notification daemon
pkill -x swaync
swaync &

## Status bar
pkill -x waybar
waybar &

wl-paste --watch cliphist store &

systemctl --user import-environment DISPLAY WAYLAND_DISPLAY SWAYSOCK XDG_CURRENT_DESKTOP
dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY SWAYSOCK XDG_CURRENT_DESKTOP
systemctl --user start xdg-desktop-portal-wlr
