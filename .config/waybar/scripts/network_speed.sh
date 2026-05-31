#!/bin/bash

# Get interface name
INTERFACE=$(ip route get 8.8.8.8 | grep -Po '(?<=dev )(\S+)')

if [ -z "$INTERFACE" ]; then
    echo "{\"text\": \"⚠\", \"tooltip\": \"Disconnected\"}"
    exit 0
fi

# Function to get bytes
get_bytes() {
    grep "$INTERFACE" /proc/net/dev | awk '{print $2 " " $10}'
}

# Initial read
read -r RX1 TX1 <<< $(get_bytes)
sleep 0.5
# Second read
read -r RX2 TX2 <<< $(get_bytes)

# Calculate rates (Bytes per second)
# Since we slept for 0.5s, multiply by 2 to get per second
RX_RATE=$(((RX2 - RX1) * 2))
TX_RATE=$(((TX2 - TX1) * 2))

# Function to format bytes to human readable using awk
format_speed() {
    echo "$1" | awk '{
        if ($1 < 1024) {
            printf "%.0f B/s", $1
        } else if ($1 < 1048576) {
            printf "%.1f KB/s", $1/1024
        } else {
            printf "%.1f MB/s", $1/1048576
        }
    }'
}

RX_HUMAN=$(format_speed $RX_RATE)
TX_HUMAN=$(format_speed $TX_RATE)

# Get SSID
SSID=$(nmcli -t -f active,ssid dev wifi | grep '^yes' | cut -d: -f2)
[ -z "$SSID" ] && SSID="Ethernet"

echo "{\"text\": \"  $RX_HUMAN\", \"tooltip\": \"$SSID\n⬆ $TX_HUMAN\n⬇ $RX_HUMAN\"}"
