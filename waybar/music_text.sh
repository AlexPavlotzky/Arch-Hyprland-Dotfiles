#!/usr/bin/env bash

MPD_HOST="127.0.0.1"
MPD_PORT="6601"

TEXT=""

# MPD
if mpc -h $MPD_HOST -p $MPD_PORT status &>/dev/null; then
    MPD_STATE=$(mpc -h $MPD_HOST -p $MPD_PORT status | sed -n 2p | awk '{print $1}')
    if [[ "$MPD_STATE" == "[playing]" ]]; then
        SONG=$(mpc -h $MPD_HOST -p $MPD_PORT current)
        TEXT+="  $SONG"
    fi
fi

# Spotify
if playerctl -p spotify status &>/dev/null; then
    if [[ "$(playerctl -p spotify status)" == "Playing" ]]; then
        SONG=$(playerctl -p spotify metadata --format "{{title}} - {{artist}}")
        [[ -n "$TEXT" ]] && TEXT+=" | "
        TEXT+="  $SONG"
    fi
fi

# Brave
if playerctl -p brave status &>/dev/null; then
    if [[ "$(playerctl -p brave status)" == "Playing" ]]; then
        SONG=$(playerctl -p brave metadata --format "{{title}} - {{artist}}")
        [[ -n "$TEXT" ]] && TEXT+=" | "
        TEXT+="  $SONG"
    fi
fi

# Nada sonando
[ -z "$TEXT" ] && TEXT="No music"

echo "$TEXT"
