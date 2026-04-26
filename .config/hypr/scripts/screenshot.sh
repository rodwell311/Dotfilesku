#!/bin/bash
# Unified Screenshot Script
# Usage: ./screenshot.sh [region|window|output]

MODE=$1
SAVE_DIR="$HOME/Screenshots"
FILENAME="Screenshot_$(date +'%Y-%m-%d_%H-%M-%S').png"
FILEPATH="$SAVE_DIR/$FILENAME"

# Ensure directory exists
mkdir -p "$SAVE_DIR"

notify_user() {
    notify-send "Screenshot Saved" "Saved to $FILENAME" -i "$FILEPATH"
}

case $MODE in
    "region")
        # Select region with slurp
        COORDS=$(slurp)
        [ -z "$COORDS" ] && exit 0
        sleep 0.5 # Wait for overlay to fade
        grim -g "$COORDS" "$FILEPATH"
        ;;
    "window")
        # Select window: Feed geometries to slurp to snap to windows
        # Requires jq
        WINDOWS=$(hyprctl clients -j | jq -r '.[] | "\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')
        COORDS=$(echo "$WINDOWS" | slurp)
        [ -z "$COORDS" ] && exit 0
        sleep 0.5 # Wait for overlay to fade
        grim -g "$COORDS" "$FILEPATH"
        ;;
    "output")
        # Capture active monitor
        # Get the active workspace's monitor
        MONITOR=$(hyprctl monitors -j | jq -r '.[] | select(.focused == true) | .name')
        [ -z "$MONITOR" ] && exit 1
        sleep 0.5
        grim -o "$MONITOR" "$FILEPATH"
        ;;
    *)
        echo "Usage: $0 [region|window|output]"
        exit 1
        ;;
esac

# Copy to clipboard
wl-copy < "$FILEPATH"

# Notify
notify_user
