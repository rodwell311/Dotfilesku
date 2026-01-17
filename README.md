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

After the installation is complete and you have logged into the Hyprland desktop environment, you need to manually set the GTK and Cursor themes using `nwg-look`:

1.  Open the terminal (`SUPER + RETURN`) or launcher (`SUPER + SPACE`).
2.  Run the command: `nwg-look`.
3.  In the **GTK Theme** tab, select **Catppuccin-Mocha**.
4.  In the **Cursor Theme** tab, select **Bibata-Modern-Classic** (or any other Bibata variant).
5.  Click **Apply** to save the changes.

### Changing Wallpaper

To change the wallpaper using `waypaper`:

1.  Open the terminal (`SUPER + RETURN`) or launcher (`SUPER + SPACE`).
2.  Run the command: `waypaper`.
3.  Select your preferred wallpaper and click **Apply**.

### SDDM Profile Picture

To change the profile picture in SDDM:

1.  Prepare an image with a **1:1** aspect ratio.
2.  Name the image using the format `(username).face.icon` (e.g., `rodwell.face.icon`).
3.  Save the file to the `/usr/share/sddm/faces/` directory.

### Wlogout Profile Picture

To change the profile picture in wlogout:

1.  Prepare an image with a **1:1** aspect ratio.
2.  Name the image `.face.icon`.
3.  Save the file to the `~/.config/hypr/` directory.

## Structure

- `.config/`: Contains configuration folders for various tools.
- `home/`: Contains dotfiles meant for the home directory (e.g., `.zshrc`).
