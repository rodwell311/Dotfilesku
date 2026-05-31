#!/bin/bash

WINDOW="control_center"
LOCK_FILE="/tmp/eww_toggle.lock"

# Simple lock to prevent double execution from rapid clicks
if [ -f "$LOCK_FILE" ]; then
    exit 0
fi
touch "$LOCK_FILE"

# Start daemon if not running
if ! pgrep -x "eww" > /dev/null; then
    eww daemon &
    sleep 1
fi

# Logic: If window is active, close it. Otherwise, open it.
if eww active-windows | grep -q "$WINDOW"; then
    eww close "$WINDOW"
else
    # Try closing first to clear any ghost states, then open
    eww close "$WINDOW" 2>/dev/null
    eww open "$WINDOW"
fi

# Release lock
rm -f "$LOCK_FILE"
