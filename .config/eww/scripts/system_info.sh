#!/bin/sh

BAT_PATH=$(ls /sys/class/power_supply | grep BAT | head -n 1)

case $1 in
    cpu) echo $(awk '{print $1}' /proc/loadavg) $(nproc) | awk '{printf "%.1f", ($1/$2)*100}' ;;
    ram) free -h | awk '/Mem:/ { print $3 }' | sed 's/i//' ;;
    bat_perc) cat /sys/class/power_supply/$BAT_PATH/capacity ;;
    bat_status) cat /sys/class/power_supply/$BAT_PATH/status ;;
esac
