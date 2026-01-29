#!/bin/bash
# Skrip untuk menyalin wallpaper aktif ke cache hyprlock (v2)

# Beri sedikit jeda untuk memastikan swww selesai mengganti wallpaper
sleep 0.5

# Ambil path wallpaper saat ini dari swww
# Format outputnya: "... image: /path/to/wallpaper.jpg"
CURRENT_WALLPAPER=$(swww query | head -n 1 | awk -F'image: ' '{print $2}')

# Jika path wallpaper ditemukan, salin ke lokasi cache yang digunakan hyprlock
if [ -n "$CURRENT_WALLPAPER" ] && [ -f "$CURRENT_WALLPAPER" ]; then
  cp "$CURRENT_WALLPAPER" "$HOME/.cache/current_wallpaper"
fi