#!/usr/bin/env bash

# Fetch Dunst history notifications
notifications=$(dunstctl history | jq -r '
  .data[0][] |
  "\(.summary.data): \(.body.data)" |
  if length > 80 then .[0:80] + "…" else . end
')

# Fallback if empty
[ -z "$notifications" ] && notifications="No notifications."

# Display in fuzzel (uses your existing theme)
chosen=$(echo "$notifications" | fuzzel --dmenu -p "Notifications: ")

# Optional: close all notifications if user selects one
if [ -n "$chosen" ] && [ "$chosen" != "No notifications." ]; then
  dunstctl close-all
fi
