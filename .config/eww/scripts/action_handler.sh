#!/bin/bash

case $1 in
    wifi)
        eww close control_center
        # Use hyprctl to launch for better reliability in Hyprland
        hyprctl dispatch exec "[float;center;size 600 500] kitty --class nmtui -T nmtui -e nmtui"
        ;;
    bluetooth)
        eww close control_center
        # Launch blueman-manager (GUI)
        hyprctl dispatch exec "blueman-manager"
        ;;
    spotify)
        eww close control_center
        hyprctl dispatch exec "spotify"
        ;;
esac
