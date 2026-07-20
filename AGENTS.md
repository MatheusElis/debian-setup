# Agent Instructions — debian-setup

Dotfiles and bootstrap automation for a Debian minimal + Sway desktop environment.

## Project Overview

This repository provisions a complete Debian Sway desktop from a minimal install via a single `install.sh` script, deploying dotfiles with GNU Stow.

## Architecture

- **`install.sh`** — Idempotent bootstrap script. Installs packages, builds from source (Rofi, Neovim), configures shell/zsh, deploys dotfiles via stow, configures Flatpak apps, sets up theme system, and migrates WiFi to NetworkManager.
- **Stow packages** — Each top-level directory (alacritty, fonts, gitconfig, gtk, nvim, rofi, starship, sway, waybar) is a stow package mirroring target paths (`~/.config/`, `~/.local/`).
- **Sway config** — Modular: root config in `sway/.config/sway/config` includes per-concern files from `config.d/`. Scripts live in `sway/.config/sway/scripts/`.
- **Neovim (ComuVim)** — Modular Lua config using lazy.nvim. One plugin per file under `nvim/.config/nvim/lua/comuvim/plugins/`. Stow is done manually (not in install.sh).
- **Theme system** — Catppuccin Mocha/Latte with toggle via `Alt+Shift+T`. See [Theme System](#theme-system).
- **Flatpak apps** — Steam and Spotify installed via Flatpak. `XDG_DATA_DIRS` set in `~/.zprofile` for Rofi visibility.
- **Monitor profiles** — Kanshi manages automatic monitor switching (laptop, docked, external-only).

## Theme System

Toggle between Catppuccin Mocha (dark) and Latte (light) with `Alt+Shift+T`.

**Managed by:** `sway/.config/sway/scripts/theme-toggle.sh`

**Components toggled:**

| Component | Mechanism | Files |
|-----------|-----------|-------|
| Sway borders | symlink `colors` → `colors-mocha`/`colors-latte` | `config.d/colors-*` |
| Alacritty | sed import line | `catppuccin-mocha.toml`, `catppuccin-latte.toml` |
| Starship | sed palette name | `starship.toml` (both palettes defined) |
| Rofi | symlink `theme.rasi` → variant | `catppuccin-mocha.rasi`, `catppuccin-latte.rasi` |
| Swaylock | symlink `config` → `config-mocha`/`config-latte` | `swaylock/config-*` |
| Swaync | symlink `style.css` → `style-mocha.css`/`style-latte.css` | `swaync/style-*.css` |
| Wlogout | symlink `style.css` → `style-mocha.css`/`style-latte.css` | `wlogout/style-*.css` |
| GTK 3/4 | sed theme/icon/cursor names | `settings.ini` |
| Chrome | gsettings color-scheme | via `xdg-desktop-portal-gtk` |
| Cursor | sed Bibata-Modern-Classic/Ice | `cursor.conf` |
| Wallpaper | swaymsg + sed config | `debian-black-4k.png` / `debian-magenta-blue-1920x1080.png` |

**State file:** `~/.config/sway/current-theme` (contains `mocha` or `latte`)

**Convention for new themed components:** Create `*-mocha` and `*-latte` variants, add symlink logic to `theme-toggle.sh`, and add initial symlink to install.sh's "Initial theme setup" section.

## Key Conventions

- **Language**: Comments and user-facing messages in the script are in Portuguese (pt-BR). Maintain this when adding new sections.
- **Stow structure**: New dotfile packages must mirror the target path inside their directory (e.g., `app/.config/app/config`).
- **Never run stow or create symlinks manually** — all deployment must go through `install.sh`. This ensures idempotency and avoids conflicts.
- **install.sh idempotency**: Every section must be safe to re-run. Use guards:
  - `if ! command -v <bin>` for source builds
  - `if ! grep -Fq` before appending to files
  - `if [ ! -f ... ]` before creating files
  - Clean temp dirs (`rm -rf`) before `git clone`
  - Check existence before `nmcli connection add`
  - Remove real files before `stow` if they conflict (see gtk section)
- **Network safety**: Any operation that may disrupt connectivity (NetworkManager migration) MUST be placed at the end of `install.sh`, never mid-script.
- **Naming**: Lowercase, dash-separated filenames. Purpose-based names (e.g., `keymaps.conf`, `inputs.conf`).
- **No `set -e` workarounds**: The script uses `set -e`. Commands that may fail harmlessly should use `|| true` or `|| echo "..."`.

## Target Environment

- **OS**: Debian stable (minimal/netinst)
- **Display**: Sway (Wayland compositor)
- **Shell**: Zsh with Starship prompt
- **Terminal**: Alacritty (primary), Foot (secondary)
- **Editor**: Neovim (ComuVim distribution)
- **Launcher**: Rofi (built from source)
- **Networking**: ifupdown (default) → NetworkManager (post-install)
- **Cursor**: Bibata Modern (Classic/Ice)
- **Icons**: Papirus (Dark/Light)
- **Gaming**: Steam via Flatpak + steam-devices
- **User**: `elis`

## Common Tasks

| Task | Command |
|------|---------|
| Run full setup | `bash install.sh` |
| Deploy single dotfile | `cd ~/debian-setup && stow <package>` |
| Re-deploy dotfile | `cd ~/debian-setup && stow --restow <package>` |
| Toggle theme | `Alt+Shift+T` or `~/.config/sway/scripts/theme-toggle.sh` |
| Test script idempotency | Run `bash install.sh` twice — second run must succeed without errors |

## Pitfalls

- The script is executed via SSH on a fresh Debian minimal. Restarting NetworkManager mid-script drops the SSH session and kills the script.
- `apt install -y` is idempotent, but `git clone` is not — always `rm -rf` the target before cloning.
- `stow` fails if a real file (not symlink) already exists at the target path. Remove real files before stow (see gtk section in install.sh).
- `extrepo enable` may warn if already enabled — not fatal with `set -e` if exit code is 0.
- Theme symlinks (`colors`, `theme.rasi`, `style.css`, etc.) are NOT managed by stow — they are created by install.sh and toggled by `theme-toggle.sh`.
- Flatpak apps need `XDG_DATA_DIRS` set in `~/.zprofile` (before `exec sway`) to appear in Rofi.
