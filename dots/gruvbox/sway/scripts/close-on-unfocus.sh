#!/bin/sh
PIDFILE="/tmp/sway-close-on-unfocus.pid"

if [ -f "$PIDFILE" ]; then
    oldpid=$(cat "$PIDFILE" 2>/dev/null)
    if [ -n "$oldpid" ] && kill -0 "$oldpid" 2>/dev/null; then
        kill "$oldpid" 2>/dev/null
        wait "$oldpid" 2>/dev/null
    fi
fi

echo $$ > "$PIDFILE"
trap 'rm -f "$PIDFILE"' EXIT

swaymsg -t subscribe -m '["window"]' | while read -r event; do
    change=$(printf '%s' "$event" | jq -r '.change // empty')
    [ "$change" != "focus" ] && continue

    ids=$(swaymsg -t get_tree | jq -r '
        recurse(.nodes[]?, .floating_nodes[]?) |
        select(.type == "con" and .focused == false) |
        select(
            .app_id == "fuzzel" or
            (.app_id | test("^l (keybind|wallsee|autorun)$")) or
            (.name | test("^l (keybind|wallsee|autorun)$"))
        ) |
        .id
    ')

    for wid in $ids; do
        swaymsg "[con_id=$wid] kill" 2>/dev/null
    done
done
