#!/bin/bash

# Get battery info
BAT=$(ls /sys/class/power_supply/ | grep BAT | head -n 1)

if [ -z "$BAT" ]; then
    echo "No Battery"
    exit 0
fi

CAPACITY=$(cat /sys/class/power_supply/$BAT/capacity)
STATUS=$(cat /sys/class/power_supply/$BAT/status)

# Icons
ICON=""
if [ "$STATUS" == "Charging" ]; then
    ICON=""
elif [ "$CAPACITY" -le 20 ]; then
    ICON=""
elif [ "$CAPACITY" -le 40 ]; then
    ICON=""
elif [ "$CAPACITY" -le 60 ]; then
    ICON=""
elif [ "$CAPACITY" -le 80 ]; then
    ICON=""
fi

echo "$ICON    $CAPACITY%"
