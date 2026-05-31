#!/bin/sh

case $1 in
    wifi)
        # Use nmcli for more reliable SSID detection on Arch/Cachy
        SSID=$(nmcli -t -f active,ssid dev wifi | grep '^yes' | cut -d: -f2)
        
        if [ -z "$SSID" ]; then
            # Fallback check for Ethernet
            if nmcli dev status | grep -q "ethernet  connected"; then
                echo "Ethernet"
            else
                echo "Disconnected"
            fi
        else
            echo "$SSID"
        fi
        ;;
        
    bt)
        # Check for connected devices first
        NAME=$(bluetoothctl info | grep "Name:" | cut -d' ' -f2-)
        
        if [ -n "$NAME" ]; then
            echo "$NAME"
        else
            # Check if adapter is powered on
            if bluetoothctl show | grep -q "Powered: yes"; then
                echo "On"
            else
                echo "Off"
            fi
        fi
        ;;
esac
