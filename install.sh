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
sudo apt install -y xdg-desktop-portal xdg-desktop-portal-wlr # screen sharing
sudo apt install -y wlogout                                   # logout screen
sudo apt install -y brightnessctl                             # control device brightness

# Install usefull stuff
sudo apt install -y tmux network-manager tlp kanshi \
    thunar thunar-archive-plugin thunar-volman \
    unzip libnotify-bin libnotify-dev libusb-0.1-4 \
    lazygit

sudo tlp start
POWER_CONFIG='SUBSYSTEM=="power_supply", ATTR{status}=="Discharging", ATTR{capacity}=="[0-5]", RUN+="/usr/bin/systemctl suspend"'
LOW_BAT_RULE_FILE='/etc/udev/rules.d/99-lowbat.rules'
if [ ! -f "$LOW_BAT_RULE_FILE" ]; then
    echo "$POWER_CONFIG" | sudo tee "$LOW_BAT_RULE_FILE" >/dev/null
fi

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

stow fonts
sudo fc-cache -rs

stow alacritty

stow gitconfig

stow starship

stow waybar

stow sway
