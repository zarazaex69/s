#!/usr/bin/env bash
# Simple wallpaper switcher for Sway + pywal + bemenu
# ---------------------------------------------------

# Directory containing wallpapers
WALLPAPER_DIR="$HOME/Pictures/Wallpapers"

# Dependencies check
for cmd in bemenu swaybg wal swaymsg; do
  command -v "$cmd" >/dev/null 2>&1 || {
    echo "❌ Missing dependency: $cmd"
    exit 1
  }
done

# Ensure the wallpaper directory exists
[ ! -d "$WALLPAPER_DIR" ] && {
  echo "❌ Wallpaper directory not found: $WALLPAPER_DIR"
  exit 1
}

# List wallpapers and select one
SELECTED=$(find "$WALLPAPER_DIR" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) |
  xargs -I{} basename "{}" |
  bemenu -i -l 10 --prompt "Choose wallpaper:")

# Cancel if nothing selected
[ -z "$SELECTED" ] && exit 0

# Full path
IMG="$WALLPAPER_DIR/$SELECTED"

# Kill existing swaybg instances (to avoid duplicates)
pkill swaybg 2>/dev/null

# Set new wallpaper
swaybg -i "$IMG" -m fill &

# Apply pywal theme (quiet mode)
wal -i "$IMG" -q

# Update Sway theme dynamically (if script exists)
if [ -x "$HOME/.config/sway/scripts/sway-theme.sh" ]; then
  "$HOME/.config/sway/scripts/sway-theme.sh"
fi

# Reload Waybar (for new colors)
if pgrep waybar >/dev/null; then
  killall -SIGUSR2 waybar
fi

# (Optional) reload swaync with new colors
if pgrep swaync >/dev/null; then
  killall swaync
  swaync &
fi

# Done message
notify-send "Wallpaper changed" "$SELECTED" -i "$IMG"
