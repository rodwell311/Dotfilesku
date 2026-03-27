#!/bin/bash
# Skrip untuk menyalin wallpaper aktif ke cache hyprlock (v2)

# Jika argumen pertama diberikan (dari waypaper), gunakan itu
if [ -n "$1" ]; then
    SELECTED_WALLPAPER="$1"
else
    # Jika tidak ada argumen, coba ambil dari awww (jika memungkinkan)
    # Karena awww query tidak memberikan path gambar saat ini, 
    # kita andalkan argumen atau script wallpaper.sh sebelumnya.
    # Namun sebagai fallback, kita cek file terakhir yang dicopy ke cache.
    SELECTED_WALLPAPER="$HOME/.cache/current_wallpaper"
fi

# Jika path wallpaper ditemukan, salin ke lokasi cache yang digunakan hyprlock
if [ -n "$SELECTED_WALLPAPER" ] && [ -f "$SELECTED_WALLPAPER" ]; then
  cp "$SELECTED_WALLPAPER" "$HOME/.cache/current_wallpaper"
  # Opsional: update pywal juga jika diinginkan saat ganti dari waypaper
  wal -i "$SELECTED_WALLPAPER" -n --cols16
  swaync-client --reload-css
fi
