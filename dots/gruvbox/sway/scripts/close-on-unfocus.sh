#!/bin/sh
PIDFILE="/tmp/sway-close-on-unfocus.pid"

if [ -f "$PIDFILE" ]; then
    oldpid=$(cat "$PIDFILE" 2>/dev/null)
    if [ -n "$oldpid" ] && kill -0 "$oldpid" 2>/dev/null; then
        kill "$oldpid" 2>/dev/null
        sleep 0.2
    fi
    rm -f "$PIDFILE"
fi

echo $$ > "$PIDFILE"
trap 'rm -f "$PIDFILE"' EXIT

while true; do
    swaymsg -t get_tree | jq -r '
        recurse(.nodes[]?, .floating_nodes[]?) |
        select(.name? != null) |
        select(
            (.name == "l keybind") or
            (.name == "l wallsee") or
            (.name == "l autorun")
        ) |
        select(.focused == false) |
        .pid
    ' 2>/dev/null | while read -r pid; do
        [ -n "$pid" ] && [ "$pid" != "null" ] && kill "$pid" 2>/dev/null
    done
    sleep 0.15
done
