#!/usr/bin/env bash

CURRENT_SONG="$HOME/.config/waybar/music_text.sh"
zscroll \
  --length 40 \
  --delay 0.2 \
  --scroll 1 \
  --eval-in-shell true \
  --match-command "playerctl -p cider status" \
  --match-text "Playing" "--scroll 1" \
  --match-text "Paused" "--before-text ' ' --scroll 0" \
  --update-interval 1 \
  --update-check true $CURRENT_SONG &
wait
