#!/bin/bash

# Define paths
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CONFIG_DIR="$HOME/.config"
LOCAL_DIR="$HOME/.local"
LOG_FILE="$DOTFILES_DIR/uninstall.log"

# Packages to uninstall (same as install.sh)
PACKAGES=(
    "hyprland" "waybar" "kitty" "fish" "neovim" "micro" "tofi" "wlogout" "wofi" "swaync" "btop" "cava" "nautilus"
    "mpd" "ncmpcpp" "clock-rs-git" "nwg-look" "bibata-cursor-theme" "clipvault-bin" "rxfetch" "zen-browser-bin"
    "sddm" "sddm-silent-theme"
    "python-pywal16" "starship" "ttf-jetbrains-mono-nerd" "ttf-font-awesome"
    "git" "base-devel" "pantheon-polkit-agent" "qt5-wayland" "qt6-wayland"
    "xdg-desktop-portal-hyprland" "brightnessctl" "playerctl" "swww"
    "hyprlock" "waypaper" "eza" "pipewire-alsa" "pipewire-pulse" "wireplumber" "pavucontrol"
    "bluez" "bluez-utils" "blueman" "networkmanager" "iwd"
    "ananicy-cpp" "gamemode" "reflector" "irqbalance"
    "hypridle" "pyprland" "wl-clipboard" "grim" "slurp" "jq"
)

# Fonts to uninstall
FONTS=(
    "noto-fonts" "noto-fonts-cjk" "noto-fonts-emoji"
    "ttf-jetbrains-mono-nerd" "ttf-firacode-nerd" "ttf-hack-nerd" "ttf-iosevka-nerd"
    "otf-hermit-nerd" "otf-codenewroman-nerd"
    "ttf-nerd-fonts-symbols" "ttf-nerd-fonts-symbols-common"
    "apple-fonts" "ttf-ms-fonts" "ttf-roboto" "ttf-ubuntu-font-family" "inter-font"
)

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

log() { echo -e "${BLUE}[INFO]${NC} $1" && echo "[INFO] $1" >> "$LOG_FILE"; }
error() { echo -e "${RED}[ERROR]${NC} $1" && echo "[ERROR] $1" >> "$LOG_FILE"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1" && echo "[SUCCESS] $1" >> "$LOG_FILE"; }

ask_confirmation() {
    read -p "$1 (y/n): " choice
    [[ "$choice" =~ ^[Yy]$ ]]
}

echo "==================================================="
echo "          Dotfiles Uninstall Script"
echo "==================================================="
echo "WARNING: This script will remove packages and unlink dotfiles."
echo "Use with caution!"
echo "==================================================="

# 1. Unlink Configs
if ask_confirmation "Unlink dotfiles and remove symlinks?"; then
    
    unlink_item() {
        local target="$HOME/$1"
        
        if [ -L "$target" ]; then
            # Check if the symlink points to our dotfiles directory
            local target_link=$(readlink -f "$target")
            if [[ "$target_link" == "$DOTFILES_DIR"* ]]; then
                log "Removing symlink: $target"
                rm "$target"
            else
                log "Skipping $target (not linked to dotfiles repo)"
            fi
        elif [ -e "$target" ]; then
             log "Skipping $target (is a real file/dir, not a symlink)"
        else
             log "Skipping $target (does not exist)"
        fi
    }

    # Unlink .config directories
    for config in fish kitty hypr nvim waybar swaync wofi tofi wlogout btop cava wal mpd ncmpcpp clock-rs nwg-look; do
        unlink_item ".config/$config"
    done
    unlink_item ".config/starship.toml"

    # Unlink home files
    unlink_item ".zshrc"
    unlink_item ".bashrc"
    unlink_item ".gitconfig"
    unlink_item "wallpapers"

    # Unlink .local files
    unlink_item ".local/bin"
    unlink_item ".local/share/fonts"

    # Unlink themes
    if [ -d "$DOTFILES_DIR/themes" ]; then
        for theme in "$DOTFILES_DIR/themes"/*; do
            [ -e "$theme" ] || continue
            theme_name=$(basename "$theme")
            unlink_item ".themes/$theme_name"
        done
        # Remove .themes dir if empty
        rmdir "$HOME/.themes" 2>/dev/null
    fi
    
    success "Dotfiles unlinked."
fi

# 2. Uninstall Packages
if ask_confirmation "Uninstall packages?"; then
    log "Preparing to uninstall packages..."
    
    TO_REMOVE=()
    for pkg in "${PACKAGES[@]}"; do
        if pacman -Qi "$pkg" &> /dev/null; then
            TO_REMOVE+=("$pkg")
        fi
    done

    if [ ${#TO_REMOVE[@]} -eq 0 ]; then
        log "No packages from the list are installed."
    else
        log "Packages to remove: ${TO_REMOVE[*]}"
        if ask_confirmation "Are you sure you want to remove these packages? (This might break your system if you remove essential tools)"; then
            sudo pacman -Rns "${TO_REMOVE[@]}"
        else
            log "Package removal cancelled."
        fi
    fi
fi

# 3. Uninstall Fonts
if ask_confirmation "Uninstall fonts?"; then
    log "Preparing to uninstall fonts..."
    
    FONTS_TO_REMOVE=()
    for font in "${FONTS[@]}"; do
        if pacman -Qi "$font" &> /dev/null; then
            FONTS_TO_REMOVE+=("$font")
        fi
    done

    if [ ${#FONTS_TO_REMOVE[@]} -eq 0 ]; then
        log "No fonts from the list are installed."
    else
        log "Fonts to remove: ${FONTS_TO_REMOVE[*]}"
        sudo pacman -Rns "${FONTS_TO_REMOVE[@]}"
    fi
fi

# 4. Disable SDDM (Optional)
if ask_confirmation "Disable SDDM?"; then
    log "Disabling SDDM service..."
    sudo systemctl disable sddm
    success "SDDM disabled."
fi

# 5. Restore Shell (Optional)
if ask_confirmation "Change default shell back to Bash?"; then
    chsh -s $(which bash)
    success "Shell changed to Bash."
fi

success "Uninstall complete!"
