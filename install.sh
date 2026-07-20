#!/bin/bash

set -e

ZSHRC_FILE="$HOME/.zshrc"
TEMP_DIR="/tmp"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Update and upgrade pakages
sudo apt update && sudo apt upgrade -y

# Install build dependecies
sudo apt install -y \
    meson stow wget pkg-config ninja-build gettext cmake curl build-essential git \
    libglib2.0-dev libcairo2-dev libpango1.0-dev libgdk-pixbuf-2.0-dev \
    libxkbcommon-dev libwayland-dev wayland-protocols \
    libstartup-notification0-dev flex bison

# Install Python build dependencies
sudo apt update
sudo apt install -y make build-essential libssl-dev zlib1g-dev \
    libbz2-dev libreadline-dev libsqlite3-dev curl git \
    libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev libzstd-dev

# Install and setup zsh
sudo apt install -y zsh
sudo chsh -s "$(which zsh)" "$USER"

# Create initial .zshrc file
if [ ! -f "$ZSHRC_FILE" ]; then
    cat <<'EOF' >"$ZSHRC_FILE"
HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=1000
bindkey -v

zstyle :compinstall filename '/home/elis/.zshrc'

autoload -Uz compinit
compinit
EOF
    echo "Arquivo ~/.zshrc criado com as configurações padrão."
fi

# Install Sway and Sway packages
sudo apt install -y sway                                      # main system
sudo apt install -y swayidle                                  # idle management daemon
sudo apt install -y swaybg                                    # sway wallpaper utility
sudo apt install -y waybar                                    # wayland bar for sway
sudo apt install -y xwayland                                  # x11 suport for wayland
sudo apt install -y swaylock                                  # sway screenloking
sudo apt install -y grim                                      # grab images from a wayland compositor
sudo apt install -y slurp                                     # select a region in a wayland compositor and print
sudo apt install -y wl-clipboard                              # clipboard tool
sudo apt install -y cliphist                                  # clipboard history tool
sudo apt install -y swappy                                    # main screenshot tool
sudo apt install -y wf-recorder                               # screen recording tool
sudo apt install -y wmenu                                     # wayland menu for sway
sudo apt install -y foot                                      # lightweight terminal
sudo apt install -y alacritty                                 # main used terminal
sudo apt install -y sway-notification-center                  # notification centet
sudo apt install -y xdg-desktop-portal xdg-desktop-portal-wlr xdg-desktop-portal-gtk # screen sharing + settings portal
sudo apt install -y gsettings-desktop-schemas                 # color-scheme support for Chrome
sudo apt install -y wlogout                                   # logout screen
sudo apt install -y brightnessctl                             # control device brightness
sudo apt install -y lxqt-policykit                            # policy authentication agent

# Install usefull stuff
sudo apt install -y tmux network-manager tlp kanshi \
    thunar thunar-archive-plugin thunar-volman \
    unzip libnotify-bin libnotify-dev libusb-0.1-4 \
    lazygit ripgrep fd-find pavucontrol \
    network-manager-gnome playerctl fonts-noto-color-emoji \
    bibata-cursor-theme papirus-icon-theme \
    gvfs gvfs-backends xarchiver udiskie btop

# Install media applications
sudo apt install -y imv mpv zathura zathura-pdf-poppler evince

# Set default applications via xdg-mime
xdg-mime default imv-dir.desktop image/png
xdg-mime default imv-dir.desktop image/jpeg
xdg-mime default imv-dir.desktop image/gif
xdg-mime default imv-dir.desktop image/bmp
xdg-mime default imv-dir.desktop image/webp
xdg-mime default imv-dir.desktop image/tiff
xdg-mime default imv-dir.desktop image/svg+xml
xdg-mime default mpv.desktop video/mp4
xdg-mime default mpv.desktop video/mkv
xdg-mime default mpv.desktop video/webm
xdg-mime default mpv.desktop video/x-matroska
xdg-mime default mpv.desktop video/avi
xdg-mime default mpv.desktop audio/mpeg
xdg-mime default mpv.desktop audio/flac
xdg-mime default mpv.desktop audio/ogg
xdg-mime default mpv.desktop audio/mp4
xdg-mime default org.pwmt.zathura.desktop application/pdf

sudo tlp start
POWER_CONFIG='SUBSYSTEM=="power_supply", ATTR{status}=="Discharging", ATTR{capacity}=="[0-5]", RUN+="/usr/bin/systemctl suspend"'
LOW_BAT_RULE_FILE='/etc/udev/rules.d/99-lowbat.rules'
if [ ! -f "$LOW_BAT_RULE_FILE" ]; then
    echo "$POWER_CONFIG" | sudo tee "$LOW_BAT_RULE_FILE" >/dev/null
fi

# NetworkManager WiFi configuration is handled at the end of the script
# to avoid losing network connectivity mid-execution (see below)

# Audio and bluetooth
sudo apt install -y pipewire wireplumber pipewire-alsa \
    pipewire-audio pipewire-audio-client-libraries \
    pipewire-bin pipewire-jack pipewire-pulse \
    bluez blueman libspa-0.2-bluetooth

# Setup Starship
sudo apt install -y starship
STARSHIP_ACTIVATE='eval "$(starship init zsh)"'
if ! grep -Fq "$STARSHIP_ACTIVATE" "$ZSHRC_FILE"; then
    echo "" >>"$ZSHRC_FILE"
    echo "$STARSHIP_ACTIVATE" >>"$ZSHRC_FILE"
    echo "Trecho do Starship adicionado ao ~/.zshrc."
fi

# Install Flatpak and apps
sudo apt install -y flatpak steam-devices
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install -y --noninteractive flathub com.valvesoftware.Steam || true
flatpak install -y --noninteractive flathub com.spotify.Client || true

# Configure .zprofile (Sway autostart + environment)
ZPROFILE_FILE="$HOME/.zprofile"
if [ ! -f "$ZPROFILE_FILE" ]; then
    cat <<'EOF' >"$ZPROFILE_FILE"
if [ -z "$WAYLAND_DISPLAY" ] && [ "$XDG_VTNR" -eq 1 ]; then
        export MOZ_ENABLE_WAYLAND=1
        export XDG_SESSION_TYPE=wayland
        export XDG_CURRENT_DESKTOP=sway
        export XDG_DATA_DIRS="/usr/local/share:/usr/share:/var/lib/flatpak/exports/share:$HOME/.local/share/flatpak/exports/share"
        exec sway
fi
export TERMINAL="alacritty"
EOF
    echo "Arquivo ~/.zprofile criado com configurações do Sway."
else
    if ! grep -Fq "XDG_DATA_DIRS" "$ZPROFILE_FILE"; then
        sed -i '/exec sway/i \        export XDG_DATA_DIRS="/usr/local/share:/usr/share:/var/lib/flatpak/exports/share:$HOME/.local/share/flatpak/exports/share"' "$ZPROFILE_FILE"
        echo "XDG_DATA_DIRS adicionado ao ~/.zprofile."
    fi
fi

# Install Google Chrome
if ! command -v google-chrome-stable &>/dev/null; then
    sudo install -d -m 0755 /etc/apt/keyrings
    curl -fsSL https://dl.google.com/linux/linux_signing_key.pub |
        sudo gpg --dearmor -o /etc/apt/keyrings/google-chrome.gpg
    echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/google-chrome.gpg] https://dl.google.com/linux/chrome/deb/ stable main" |
        sudo tee /etc/apt/sources.list.d/google-chrome.list >/dev/null
    sudo apt update
    sudo apt install -y google-chrome-stable || echo "Google Chrome installation failed"
else
    echo "Google Chrome already installed, skipping..."
fi

# Install Rofi
if ! command -v rofi &>/dev/null; then
    rm -rf $TEMP_DIR/rofi
    cd $TEMP_DIR
    git clone --recursive https://github.com/DaveDavenport/rofi
    cd rofi/
    meson setup build
    ninja -C build
    sudo ninja -C build install
    rofi -v
fi

# Install Neovim
if ! command -v nvim &>/dev/null; then
    rm -rf $TEMP_DIR/neovim
    cd $TEMP_DIR
    git clone https://github.com/neovim/neovim
    cd neovim/
    git checkout stable
    make CMAKE_BUILD_TYPE=RelWithDebInfo
    cd build && cpack -G DEB && sudo dpkg -i nvim-linux-x86_64.deb
fi

# Install MISE
sudo apt install -y extrepo
sudo extrepo enable mise
sudo apt update
sudo apt install -y mise
MISE_ACTIVATE='eval "$(/usr/bin/mise activate zsh)"'
if ! grep -Fq "$MISE_ACTIVATE" "$ZSHRC_FILE"; then
    echo "" >>"$ZSHRC_FILE"
    echo "$MISE_ACTIVATE" >>"$ZSHRC_FILE"
fi

# Criar diretório para gravações de tela
mkdir -p "$HOME/Videos"

stow fonts
sudo fc-cache -f -v

# Remove arquivos/diretórios reais que conflitam com symlinks do stow
# Alacritty: stow cria symlink de diretório, então checamos o diretório
if [ -d "$HOME/.config/alacritty" ] && [ ! -L "$HOME/.config/alacritty" ]; then
    rm -rf "$HOME/.config/alacritty"
fi
stow alacritty

stow gitconfig

# Starship: stow cria symlink de arquivo
if [ -f "$HOME/.config/starship.toml" ] && [ ! -L "$HOME/.config/starship.toml" ]; then
    rm "$HOME/.config/starship.toml"
fi
stow starship

stow waybar

stow sway

stow rofi

# GTK: apps podem criar settings.ini real
for gtk_dir in gtk-3.0 gtk-4.0; do
    target="$HOME/.config/$gtk_dir/settings.ini"
    if [ -f "$target" ] && [ ! -L "$target" ]; then
        rm "$target"
    fi
done
stow gtk

# Initial theme setup (Catppuccin Mocha as default)
if [ ! -f "$HOME/.config/sway/current-theme" ]; then
    ln -sf colors-mocha "$HOME/.config/sway/config.d/colors"
    ln -sf catppuccin-mocha.rasi "$HOME/.config/rofi/theme.rasi"
    ln -sf config-mocha "$HOME/.config/swaylock/config"
    ln -sf style-mocha.css "$HOME/.config/swaync/style.css"
    ln -sf style-mocha.css "$HOME/.config/wlogout/style.css"
    echo "mocha" > "$HOME/.config/sway/current-theme"
    echo "Tema Catppuccin Mocha configurado como padrão."
fi

# Configure NetworkManager to manage WiFi (MUST be last step)
# Debian installer adds WiFi config to /etc/network/interfaces, which makes
# NetworkManager ignore the interface. We remove it here so NM takes over.
# We extract SSID/PSK first to create an NM profile, ensuring auto-reconnect after reboot.
if sudo grep -q 'wlp\|wlan' /etc/network/interfaces 2>/dev/null; then
    # Extract SSID and PSK from /etc/network/interfaces before removing
    WIFI_SSID=$(sudo grep 'wpa-ssid' /etc/network/interfaces | awk '{print $2}' | tr -d '"')
    WIFI_PSK=$(sudo grep 'wpa-psk' /etc/network/interfaces | awk '{print $2}' | tr -d '"')

    # Create NM connection profile so WiFi reconnects automatically after reboot
    if [ -n "$WIFI_SSID" ] && [ -n "$WIFI_PSK" ] && ! nmcli connection show "$WIFI_SSID" &>/dev/null; then
        sudo nmcli connection add \
            type wifi \
            con-name "$WIFI_SSID" \
            ssid "$WIFI_SSID" \
            wifi-sec.key-mgmt wpa-psk \
            wifi-sec.psk "$WIFI_PSK" \
            connection.autoconnect yes
        echo "NetworkManager profile created for SSID: $WIFI_SSID"
    fi

    # Remove WiFi entries from /etc/network/interfaces
    sudo sed -i '/allow-hotplug wl/d; /iface wl.*inet/d; /wpa-ssid/d; /wpa-psk/d' /etc/network/interfaces

    echo "WiFi removed from /etc/network/interfaces - NetworkManager will manage it after reboot."
    echo ""
    echo "============================================"
    echo " SETUP COMPLETE - REBOOT REQUIRED"
    echo " Run: sudo reboot"
    echo " After reboot, NetworkManager will manage WiFi."
    echo "============================================"
else
    echo ""
    echo "============================================"
    echo " SETUP COMPLETE"
    echo "============================================"
fi
