#!/bin/bash

# Theme toggle: Catppuccin Mocha ↔ Latte
# Alterna tema em: Sway, Alacritty, Starship, Rofi, Swaylock, GTK, Cursor, Swaync, Wlogout

SWAY_CONFIG="$HOME/.config/sway/config.d"
STATE_FILE="$HOME/.config/sway/current-theme"
ALACRITTY_CONFIG="$HOME/.config/alacritty/alacritty.toml"
STARSHIP_CONFIG="$HOME/.config/starship.toml"
ROFI_CONFIG="$HOME/.config/rofi"
SWAYLOCK_CONFIG="$HOME/.config/swaylock"
SWAYNC_CONFIG="$HOME/.config/swaync"
WLOGOUT_CONFIG="$HOME/.config/wlogout"
GTK3_CONFIG="$HOME/.config/gtk-3.0/settings.ini"
GTK4_CONFIG="$HOME/.config/gtk-4.0/settings.ini"

MOCHA_WALLPAPER="$HOME/.config/sway/wallpapers/debian-black-4k.png"
LATTE_WALLPAPER="$HOME/.config/sway/wallpapers/debian-magenta-blue-1920x1080.png"

# Ler tema atual (padrão: mocha)
CURRENT=$(cat "$STATE_FILE" 2>/dev/null || echo "mocha")

if [ "$CURRENT" = "mocha" ]; then
    NEW="latte"
else
    NEW="mocha"
fi

# 1. Sway colors
ln -sf "colors-${NEW}" "$SWAY_CONFIG/colors"

# 2. Sway cursor
if [ "$NEW" = "mocha" ]; then
    sed -i 's/Bibata-Modern-Ice/Bibata-Modern-Classic/' "$SWAY_CONFIG/cursor.conf"
else
    sed -i 's/Bibata-Modern-Classic/Bibata-Modern-Ice/' "$SWAY_CONFIG/cursor.conf"
fi

# 3. Alacritty
if [ "$NEW" = "mocha" ]; then
    sed -i 's/catppuccin-latte\.toml/catppuccin-mocha.toml/' "$ALACRITTY_CONFIG"
else
    sed -i 's/catppuccin-mocha\.toml/catppuccin-latte.toml/' "$ALACRITTY_CONFIG"
fi

# 4. Starship
sed -i "s/palette = 'catppuccin_.*'/palette = 'catppuccin_${NEW}'/" "$STARSHIP_CONFIG"

# 5. Rofi
ln -sf "catppuccin-${NEW}.rasi" "$ROFI_CONFIG/theme.rasi"

# 6. Swaylock
ln -sf "config-${NEW}" "$SWAYLOCK_CONFIG/config"

# 6b. Swaync
ln -sf "style-${NEW}.css" "$SWAYNC_CONFIG/style.css"

# 6c. Wlogout
ln -sf "style-${NEW}.css" "$WLOGOUT_CONFIG/style.css"

# 7. GTK theme + cursor + icons
if [ "$NEW" = "mocha" ]; then
    GTK_THEME="Adwaita-dark"
    GTK_ICONS="Papirus-Dark"
    GTK_CURSOR="Bibata-Modern-Classic"
    GTK_DARK="1"
else
    GTK_THEME="Adwaita"
    GTK_ICONS="Papirus-Light"
    GTK_CURSOR="Bibata-Modern-Ice"
    GTK_DARK="0"
fi

for cfg in "$GTK3_CONFIG" "$GTK4_CONFIG"; do
    sed -i "s/gtk-theme-name=.*/gtk-theme-name=${GTK_THEME}/" "$cfg"
    sed -i "s/gtk-icon-theme-name=.*/gtk-icon-theme-name=${GTK_ICONS}/" "$cfg"
    sed -i "s/gtk-cursor-theme-name=.*/gtk-cursor-theme-name=${GTK_CURSOR}/" "$cfg"
    sed -i "s/gtk-application-prefer-dark-theme=.*/gtk-application-prefer-dark-theme=${GTK_DARK}/" "$cfg"
done

# 7b. Update color-scheme via gsettings (Chrome and portal-aware apps)
if command -v gsettings &>/dev/null; then
    if [ "$NEW" = "mocha" ]; then
        gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
    else
        gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'
    fi
fi

# 8. Wallpaper (update config file for persistence + apply immediately)
SWAY_MAIN_CONFIG="$HOME/.config/sway/config"
if [ "$NEW" = "mocha" ]; then
    sed -i "s|output \* bg .* fill|output * bg $MOCHA_WALLPAPER fill|" "$SWAY_MAIN_CONFIG"
    swaymsg "output * bg $MOCHA_WALLPAPER fill"
else
    sed -i "s|output \* bg .* fill|output * bg $LATTE_WALLPAPER fill|" "$SWAY_MAIN_CONFIG"
    swaymsg "output * bg $LATTE_WALLPAPER fill"
fi

# Salvar estado
echo "$NEW" > "$STATE_FILE"

# Recarregar Sway, Waybar e Swaync
swaymsg reload
pkill -x swaync; swaync &

notify-send "Tema alterado" "Catppuccin ${NEW^} ativado" -t 3000
