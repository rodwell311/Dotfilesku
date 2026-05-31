#!/bin/bash
FLAG="/tmp/hypr-close-confirm"
active_class=$(hyprctl activewindow -j | python3 -c "import sys,json; print(json.loads(sys.stdin.read())['class'])")

if [[ "$active_class" == *"elium"* ]]; then
    if [ -f "$FLAG" ]; then
        rm "$FLAG"
        notify-send "Helium Ditutup" "Window berhasil ditutup" \
            --icon=/usr/share/pixmaps/helium-browser.png \
            -t 1500
        hyprctl dispatch killactive
    else
        touch "$FLAG"
        notify-send "Yakin tutup Helium?" "Tekan Super+Q lagi dalam 3 detik untuk konfirmasi" \
            --icon=/usr/share/pixmaps/helium-browser.png \
            -t 3000
        (sleep 2 && rm -f "$FLAG") &
    fi
else
    hyprctl dispatch killactive
fi
