#!/bin/sh
# dynamic wallpaper daemon for sway
# generates a time-based gradient, swaps swaybg without flickering

WALLGEN="$HOME/.config/sway/scripts/wallgen"
GRAIN=15
ANGLE=45

# two buffers to alternate between
BUF_A="/tmp/sway-wallpaper-a.png"
BUF_B="/tmp/sway-wallpaper-b.png"
PPM="/tmp/sway-wallpaper.ppm"
CURRENT_BUF="A"

# compile wallpaper generator if binary missing or source newer
compile_wallgen() {
    src="$HOME/.config/sway/scripts/wallpaper.c"
    if [ ! -f "$WALLGEN" ] || [ "$src" -nt "$WALLGEN" ]; then
        if command -v tcc >/dev/null 2>&1; then
            tcc "$src" -o "$WALLGEN" -lm
        elif command -v gcc >/dev/null 2>&1; then
            gcc -O2 "$src" -o "$WALLGEN" -lm
        else
            echo "error: no c compiler found" >&2
            exit 1
        fi
    fi
}

get_resolution() {
    swaymsg -t get_outputs 2>/dev/null | \
        grep -oP '"current_mode":\s*\{[^}]*"width":\s*\K\d+' | head -1
}

get_height() {
    swaymsg -t get_outputs 2>/dev/null | \
        grep -oP '"current_mode":\s*\{[^}]*"height":\s*\K\d+' | head -1
}

compile_wallgen

WIDTH=$(get_resolution)
HEIGHT=$(get_height)
WIDTH=${WIDTH:-1920}
HEIGHT=${HEIGHT:-1080}

# kill leftover swaybg from previous session
pkill -x swaybg 2>/dev/null
OLD_PID=""

while true; do
    TIME_FLOAT=$(date +'%H %M %S' | awk '{printf "%.4f", $1 + $2/60 + $3/3600}')

    # pick target buffer
    if [ "$CURRENT_BUF" = "A" ]; then
        TARGET="$BUF_A"
        CURRENT_BUF="B"
    else
        TARGET="$BUF_B"
        CURRENT_BUF="A"
    fi

    # generate new wallpaper
    "$WALLGEN" "$WIDTH" "$HEIGHT" "$TIME_FLOAT" "$GRAIN" "$ANGLE" > "$PPM"
    convert "$PPM" "$TARGET" 2>/dev/null || magick "$PPM" "$TARGET" 2>/dev/null

    # start new swaybg, let it render on top of old one
    swaybg -i "$TARGET" -m fill &
    NEW_PID=$!

    # give new instance time to render its first frame
    sleep 0.5

    # kill old instance after new one is visible
    if [ -n "$OLD_PID" ]; then
        kill "$OLD_PID" 2>/dev/null
    fi
    OLD_PID=$NEW_PID

    sleep 60
done
