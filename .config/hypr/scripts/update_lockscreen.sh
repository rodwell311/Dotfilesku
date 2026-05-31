#!/bin/bash
# Skrip untuk menyalin wallpaper aktif ke cache hyprlock (v2)

# Jika argumen pertama diberikan, gunakan itu
if [ -n "$1" ]; then
    SELECTED_WALLPAPER="$1"
else
    # Fallback ke wallpaper default jika tidak ada argumen
    SELECTED_WALLPAPER="$HOME/wallpapers/pywallpaper.jpg"
fi

# Jika path wallpaper ditemukan, salin ke lokasi cache yang digunakan hyprlock
if [ -n "$SELECTED_WALLPAPER" ] && [ -f "$SELECTED_WALLPAPER" ]; then
  cp "$SELECTED_WALLPAPER" "$HOME/.cache/current_wallpaper"
  # Refresh swaync agar sinkron
  swaync-client --reload-css
fi
