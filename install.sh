#!/bin/bash

# Define paths
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CONFIG_DIR="$HOME/.config"
LOCAL_DIR="$HOME/.local"
BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"
LOG_FILE="$DOTFILES_DIR/install.log"

# Packages to install
PACKAGES=(
    "hyprland" "waybar" "kitty" "fish" "neovim" "micro" "tofi" "wlogout" "wofi" "swaync" "btop" "cava" "nautilus"
    "mpd" "ncmpcpp" "clock-rs-git" "nwg-look" "bibata-cursor-theme" "clipvault-bin" "rxfetch" "zen-browser-bin"
    "sddm" "sddm-silent-theme"
    "python-pywal16" "starship" "ttf-jetbrains-mono-nerd" "ttf-font-awesome"
    "git" "base-devel" "pantheon-polkit-agent" "qt5-wayland" "qt6-wayland"
    "xdg-desktop-portal-hyprland" "brightnessctl" "playerctl"
)

# Fonts to install
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

# Check if running on Arch
if [ ! -f /etc/arch-release ]; then
    error "This script is optimized for Arch Linux."
    ask_confirmation "Do you want to continue anyway?" || exit 1
fi

# 1. System Update & Dependencies
if ask_confirmation "Update system and install dependencies?"; then
    log "Updating system..."
    sudo pacman -Syu --noconfirm
    sudo pacman -S --needed --noconfirm git base-devel
fi

# 2. Setup Chaotic AUR
if ! grep -q "\[chaotic-aur\]" /etc/pacman.conf; then
    if ask_confirmation "Setup Chaotic AUR (for pre-built AUR packages)?"; then
        log "Setting up Chaotic AUR..."
        sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
        sudo pacman-key --lsign-key 3056513887B78AEB
        sudo pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'
        sudo pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'
        
        echo -e "\n[chaotic-aur]\nInclude = /etc/pacman.d/chaotic-mirrorlist" | sudo tee -a /etc/pacman.conf
        sudo pacman -Sy
        success "Chaotic AUR setup complete."
    fi
else
    log "Chaotic AUR is already setup."
fi

# 3. Install AUR Helper (yay)
if ! command -v yay &> /dev/null; then
    log "Yay not found."
    if ask_confirmation "Install yay (AUR helper)?"; then
        log "Installing yay..."
        rm -rf /tmp/yay
        git clone https://aur.archlinux.org/yay.git /tmp/yay
        cd /tmp/yay && makepkg -si --noconfirm && cd "$DOTFILES_DIR"
        success "Yay installed."
    fi
else
    log "Yay is already installed. Skipping installation."
fi

# 4. Install Packages
if ask_confirmation "Install required packages?"; then
    log "Checking for missing packages..."
    TO_INSTALL=()

    for pkg in "${PACKAGES[@]}"; do
        if pacman -Qi "$pkg" &> /dev/null; then
            log "$pkg is already installed. Skipping..."
        else
            log "$pkg is missing. Adding to install list..."
            TO_INSTALL+=("$pkg")
        fi
    done

    if [ ${#TO_INSTALL[@]} -eq 0 ]; then
        log "All packages are already installed."
    else
        log "Installing missing packages: ${TO_INSTALL[*]}"
        yay -S --needed --noconfirm "${TO_INSTALL[@]}"
    fi
fi

# 5. Install Fonts
if ask_confirmation "Install additional fonts (Nerd Fonts, Noto, Apple, Microsoft, etc.)?"; then
    log "Checking for missing fonts..."
    FONTS_TO_INSTALL=()

    for font in "${FONTS[@]}"; do
        if pacman -Qi "$font" &> /dev/null; then
            log "$font is already installed. Skipping..."
        else
            log "$font is missing. Adding to install list..."
            FONTS_TO_INSTALL+=("$font")
        fi
    done

    if [ ${#FONTS_TO_INSTALL[@]} -eq 0 ]; then
        log "All fonts are already installed."
    else
        log "Installing missing fonts: ${FONTS_TO_INSTALL[*]}"
        yay -S --needed --noconfirm "${FONTS_TO_INSTALL[@]}"
    fi
fi

# 6. Setup SDDM
if ask_confirmation "Setup SDDM with Silent theme?"; then
    log "Enabling SDDM service..."
    sudo systemctl enable sddm
    
    log "Configuring SDDM theme..."
    if [ ! -d "/etc/sddm.conf.d" ]; then
        sudo mkdir -p /etc/sddm.conf.d
    fi
    
    echo -e "[Theme]\nCurrent=silent" | sudo tee /etc/sddm.conf.d/theme.conf
    success "SDDM setup complete."
fi

# 7. Link Configs
if ask_confirmation "Link dotfiles?"; then
    
    # 7a. Optional Backup
    DO_BACKUP=false
    if ask_confirmation "Backup existing configs first?"; then
         DO_BACKUP=true
         log "Backing up to: $BACKUP_DIR"
         mkdir -p "$BACKUP_DIR"
    fi

    # Function to create symlink with optional backup
    link_item() {
        local source="$DOTFILES_DIR/$1"
        local target="$HOME/$1"
        local target_dir=$(dirname "$target")

        [ ! -e "$source" ] && return

        mkdir -p "$target_dir"

        if [ -e "$target" ] || [ -L "$target" ]; then
            if [ "$DO_BACKUP" = true ]; then
                log "Backing up $target..."
                mv "$target" "$BACKUP_DIR/" 2>/dev/null
            else
                log "Removing existing $target (no backup)..."
                rm -rf "$target"
            fi
        fi

        log "Linking $1..."
        ln -s "$source" "$target"
    }

    # Link .config directories
    for config in fish kitty hypr nvim waybar swaync wofi tofi wlogout btop cava wal mpd ncmpcpp clock-rs nwg-look; do
        link_item ".config/$config"
    done
    link_item ".config/starship.toml"

    # Link home files
    link_item ".zshrc"
    link_item ".bashrc"
    link_item ".gitconfig"
    link_item "wallpapers"

    # Link .local files
    link_item ".local/bin"
    link_item ".local/share/fonts"

    # Link themes
    if [ -d "$DOTFILES_DIR/themes" ]; then
        log "Linking themes..."
        mkdir -p "$HOME/.themes"
        for theme in "$DOTFILES_DIR/themes"/*; do
            [ -e "$theme" ] || continue
            theme_name=$(basename "$theme")
            target="$HOME/.themes/$theme_name"
            
            if [ -e "$target" ] || [ -L "$target" ]; then
                if [ "$DO_BACKUP" = true ]; then
                    log "Backing up existing theme $theme_name..."
                    mv "$target" "$BACKUP_DIR/" 2>/dev/null
                else
                    log "Removing existing theme $theme_name (no backup)..."
                    rm -rf "$target"
                fi
            fi
            
            log "Linking theme $theme_name..."
            ln -s "$theme" "$target"
        done
    fi
    
    success "Dotfiles linked!"
fi

# 8. Set Shell
if ask_confirmation "Change default shell to Fish?"; then
    chsh -s $(which fish)
    success "Shell changed to Fish."
fi

success "Installation complete!"
