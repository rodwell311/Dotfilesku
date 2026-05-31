#!/bin/bash

THEME=$(eww get current_theme)

if [ "$THEME" == "dark" ]; then
    # Rosé Pine Dawn
    eww update current_theme="light" \
               c_bg_main="#cecacd" \
               c_bg_sec="#dfdad9" \
               c_bg_overlay="#f2e9e1" \
               c_fg_main="#575279" \
               c_fg_muted="#9893a5" \
               c_connection="#ea9d34" \
               c_city="#907aa9"
else
    # Rosé Pine
    eww update current_theme="dark" \
               c_bg_main="#191724" \
               c_bg_sec="#26233a" \
               c_bg_overlay="#191724" \
               c_fg_main="#e0def4" \
               c_fg_muted="#908caa" \
               c_connection="#ea9d34" \
               c_city="#c4a7e7"
fi
