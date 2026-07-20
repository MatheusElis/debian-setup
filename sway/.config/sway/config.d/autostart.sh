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

## Restart WirePlumber to ensure Bluetooth audio works after environment is set
systemctl --user restart wireplumber

## Network applet (provides tray icon and WiFi selector)
pkill -x nm-applet
nm-applet &

## Bluetooth applet (provides tray icon and device management)
pkill -x blueman-applet
blueman-applet &

pkill -x lxqt-policykit-agent
lxqt-policykit-agent &

## Auto-mount de dispositivos USB
pkill -x udiskie
udiskie --tray --notify &

## Dynamic monitor profile manager
pkill -x kanshi
kanshi &
