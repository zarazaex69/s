#!/bin/sh
# dynamic wallpaper daemon for sway
# uses l wallcreate for generation, checks wallsee.lock for manual overrides

WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
LOCK_FILE="$WALLPAPER_DIR/wallsee.lock"
WALLSEE_PPM="$WALLPAPER_DIR/wallsee.ppm"
GRAIN=15
ANGLE=45

BUF_A="/tmp/sway-wallpaper-a.ppm"
BUF_B="/tmp/sway-wallpaper-b.ppm"
CURRENT_BUF="A"

mkdir -p "$WALLPAPER_DIR"

get_resolution() {
    swaymsg -t get_outputs 2>/dev/null | \
        grep -oP '"current_mode":\s*\{[^}]*"width":\s*\K\d+' | head -1
}

get_height() {
    swaymsg -t get_outputs 2>/dev/null | \
        grep -oP '"current_mode":\s*\{[^}]*"height":\s*\K\d+' | head -1
}

WIDTH=$(get_resolution)
HEIGHT=$(get_height)
WIDTH=${WIDTH:-1920}
HEIGHT=${HEIGHT:-1080}

pkill -x swaybg 2>/dev/null
OLD_PID=""

set_wallpaper() {
    file="$1"
    swaybg -i "$file" -m fill &
    NEW_PID=$!
    sleep 0.5
    if [ -n "$OLD_PID" ]; then
        kill "$OLD_PID" 2>/dev/null
    fi
    OLD_PID=$NEW_PID
}

while true; do
    if [ -f "$LOCK_FILE" ]; then
        # wallsee is active, use its output
        if [ -f "$WALLSEE_PPM" ]; then
            set_wallpaper "$WALLSEE_PPM"
        fi
        sleep 3
    else
        # generate wallpaper based on current time
        TIME_FLOAT=$(date +'%H %M %S' | awk '{printf "%.4f", $1 + $2/60 + $3/3600}')

        if [ "$CURRENT_BUF" = "A" ]; then
            TARGET="$BUF_A"
            CURRENT_BUF="B"
        else
            TARGET="$BUF_B"
            CURRENT_BUF="A"
        fi

        l wallcreate "$WIDTH" "$HEIGHT" "$TIME_FLOAT" "$GRAIN" "$ANGLE" > "$TARGET"
        set_wallpaper "$TARGET"
        sleep 60
    fi
done
