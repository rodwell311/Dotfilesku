#!/bin/bash

# Matikan mpvpaper yang sebelumnya berjalan agar video tidak menumpuk
killall mpvpaper 2>/dev/null

# Ganti lokasi path ini sesuai dengan letak file video MP4 Anda
#VIDEO_PATH="$HOME/Downloads/Video/zani.mp4" #Zani Wall
#VIDEO_PATH="$HOME/Downloads/Video/crimson.mp4" #Crimson Wal
VIDEO_PATH="$HOME/Downloads/Video/itachi.mp4" #itachi

# Jalankan mpvpaper di semua monitor ('*') dengan parameter optimal
mpvpaper -p '*' "$VIDEO_PATH" -o "no-audio --loop-file=inf --hwdec=auto --input-ipc-server=/tmp/mpvsocket" &

mpvpaper-stop
