#!/bin/bash

THEME_DIR="$HOME/.config/hypr/themes"

# Fungsi menu untuk memilih tema dari daftar folder di THEME_DIR
menu() {
    ls "${THEME_DIR}"
}

main() {
    # Menampilkan menu Wofi untuk memilih tema
    choice=$(menu | wofi --show dmenu --prompt "Select Color Scheme:" -n)
    
    # Jika tidak ada pilihan, keluar
    if [ -z "$choice" ]; then
        exit 0
    fi

    SELECTED_THEME_PATH="${THEME_DIR}/${choice}"
    
    # Validasi jika folder tema ada
    if [ ! -d "$SELECTED_THEME_PATH" ]; then
        notify-send "Theme Error" "Theme ${choice} not found!"
        exit 1
    fi

    # Pastikan direktori cache ada
    mkdir -p "$HOME/.cache/wal"

    # 1. Update Hyprland Colors (Kita akan buat symlink agar hyprland.conf selalu baca file yang sama)
    cp "${SELECTED_THEME_PATH}/colors-hyprland.conf" "$HOME/.cache/wal/colors-hyprland"
    cp "${SELECTED_THEME_PATH}/colors-hyprland.conf" "$HOME/.cache/wal/colors-hyprland.conf"
    
    # 2. Update Kitty Colors
    if [ -f "${SELECTED_THEME_PATH}/colors-kitty.conf" ]; then
        cp "${SELECTED_THEME_PATH}/colors-kitty.conf" "$HOME/.cache/wal/colors-kitty.conf"
        cat "$HOME/.cache/wal/colors-kitty.conf" > "$HOME/.config/kitty/current-theme.conf"
    fi

    # 3. Update Colors.sh & Colors.json (Untuk Cava dan skrip lain yang baca variabel ini)
    cp "${SELECTED_THEME_PATH}/colors.sh" "$HOME/.cache/wal/colors.sh"
    cp "${SELECTED_THEME_PATH}/colors.json" "$HOME/.cache/wal/colors.json"
    cp "${SELECTED_THEME_PATH}/colors.css" "$HOME/.cache/wal/colors.css"

    # 4. Update Cava (Logika dari wallpaper.sh Anda tetap dipertahankan)
    color1=$(awk 'match($0, /color2=\47(.*)\47/,a) { print a[1] }' "$HOME/.cache/wal/colors.sh")
    color2=$(awk 'match($0, /color3=\47(.*)\47/,a) { print a[1] }' "$HOME/.cache/wal/colors.sh")
    cava_config="$HOME/.config/cava/config"
    if [ -f "$cava_config" ]; then
        sed -i "s/^gradient_color_1 = .*/gradient_color_1 = '$color1'/" $cava_config
        sed -i "s/^gradient_color_2 = .*/gradient_color_2 = '$color2'/" $cava_config
        pkill -USR2 cava 2>/dev/null
    fi

    # 5. Update Starship Palette
    # Ambil warna HEX dari colors-hyprland.conf tema yang dipilih
    # Format di file: $color4 = rgb(89b4fa) atau $color4 = #89b4fa
    get_hex() {
        grep "$1 =" "${SELECTED_THEME_PATH}/colors-hyprland.conf" | sed -E 's/.*rgb\((.*)\).*/#\1/; s/.*#([0-9a-fA-F]*).*/#\1/'
    }

    C_OS=$(get_hex "\$color4")
    C_USER=$(get_hex "\$color5")
    C_DIR=$(get_hex "\$color6")

    # Update baris terakhir di starship.toml
    sed -i "s/os_bg = .*/os_bg = \"$C_OS\"/" "$HOME/.config/starship.toml"
    sed -i "s/user_bg = .*/user_bg = \"$C_USER\"/" "$HOME/.config/starship.toml"
    sed -i "s/dir_bg = .*/dir_bg = \"$C_DIR\"/" "$HOME/.config/starship.toml"

    # 6. Reload SwayNC CSS
    swaync-client --reload-css

    # 6. Force Hyprland to reload sourced colors
    hyprctl reload
    # Opsi tambahan: sentuh config utama jika reload tidak cukup
    touch "$HOME/.config/hypr/hyprland.conf"

    # 7. Refresh Kitty (untuk jendela yang sedang terbuka)
    if command -v kitty >/dev/null; then
        pkill -USR1 kitty
    fi

    # Notifikasi
    notify-send "Theme Updated" "System theme changed to: ${choice}"
}

main
