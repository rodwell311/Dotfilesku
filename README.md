# Dotfilesku

My personal dotfiles for Linux (Arch/CachyOS). This repository includes an installation script that can set up a fresh Arch Linux installation with Hyprland and all my configurations.

## Content

- **Window Manager:** Hyprland
- **Bar:** Waybar
- **Terminal:** Kitty
- **Shell:** Fish / Zsh
- **Editor:** Neovim
- **Launcher:** Wofi
- **Notifications:** SwayNC
- **System Monitor:** Btop
- **Visualizer:** Cava
- **Colors:** Pywal

## Installation

### On a fresh Arch Linux install

1.  Clone the repository:
    ```bash
    git clone https://github.com/rodwell311/Dotfilesku.git
    cd Dotfilesku
    ```

2.  Run the installation script:
    ```bash
    chmod +x install.sh
    ./install.sh
    ```

    The script will interactively ask if you want to:
    - Update the system.
    - Install an AUR helper (`yay`) if missing.
    - Install all required packages (`hyprland`, `waybar`, `kitty`, fonts, etc.).
    - Backup existing configurations.
    - Symlink the new configurations.
    - Change your default shell to Fish.

## Post-Installation

Setelah instalasi selesai dan Anda masuk ke lingkungan desktop Hyprland, Anda perlu mengatur tema GTK dan Cursor secara manual menggunakan `nwg-look`:

1.  Buka terminal (`SUPER + RETURN`) atau launcher (`SUPER + SPACE`).
2.  Jalankan perintah: `nwg-look`.
3.  Di tab **GTK Theme**, pilih **Catppuccin-Mocha**.
4.  Di tab **Cursor Theme**, pilih **Bibata-Modern-Classic** (atau varian Bibata lainnya).
5.  Klik **Apply** untuk menerapkan perubahan.

## Structure

- `.config/`: Contains configuration folders for various tools.
- `home/`: Contains dotfiles meant for the home directory (e.g., `.zshrc`).
