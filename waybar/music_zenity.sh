#!/usr/bin/env bash

PLAYERS=()

if playerctl -p spotify status &>/dev/null; then
    PLAYERS+=("Spotify")
fi

if playerctl -p brave status &>/dev/null; then
    PLAYERS+=("Brave")
fi

if mpc -h 127.0.0.1 -p 6601 status &>/dev/null; then
    STATE=$(mpc -h 127.0.0.1 -p 6601 status | sed -n 2p | awk '{print $1}')
    if [[ "$STATE" == "[playing]" ]]; then
        PLAYERS+=("MPD")
    fi
fi

# Si no hay nada sonando
if [[ ${#PLAYERS[@]} -eq 0 ]]; then
    GTK_THEME=Graphite-green-Dark-compact zenity --info --text="🎵 No hay música reproduciéndose." --title="Music Control" 2>/dev/null
    exit 0
fi

# Si hay varios, elegir uno
if [[ ${#PLAYERS[@]} -gt 1 ]]; then
    PLAYER=$(GTK_THEME=Graphite-green-Dark-compact zenity --list \
        --title="Selecciona un reproductor" \
        --column="Reproductor" \
        "${PLAYERS[@]}" 2>/dev/null)
else
    PLAYER="${PLAYERS[0]}"
fi

[ -z "$PLAYER" ] && exit 0  # Si cancela

# Obtener título y artista según el reproductor
if [[ "$PLAYER" == "Spotify" ]]; then
    TITLE=$(playerctl -p spotify metadata title 2>/dev/null)
    ARTIST=$(playerctl -p spotify metadata artist 2>/dev/null)
elif [[ "$PLAYER" == "Brave" ]]; then
    TITLE=$(playerctl -p brave metadata title 2>/dev/null)
    ARTIST=$(playerctl -p brave metadata artist 2>/dev/null)
elif [[ "$PLAYER" == "MPD" ]]; then
    TITLE=$(mpc -h 127.0.0.1 -p 6601 current)
    ARTIST=""
fi

[ -z "$TITLE" ] && TITLE="Título desconocido"
[ -z "$ARTIST" ] && ARTIST="Artista desconocido"

CURRENT="$ICON\n🎵 $TITLE\n👤 $ARTIST"

# Mostrar ventana de control con título y artista
GTK_THEME=Graphite-green-Dark-compact zenity --info \
	--window-icon=none \
  	--title="🎶 Control de $PLAYER" \
	--text="$CURRENT" \
	--ok-label="⏯ Play/Pause" \
	--extra-button="⏮ Previous" \
	--extra-button="⏭ Next" 2>/dev/null

ACTION=$?

# Ejecutar según acción
case $ACTION in
    0)  # OK → Play/Pause
        [[ "$PLAYER" == "Spotify" ]] && playerctl -p spotify play-pause
        [[ "$PLAYER" == "Brave" ]] && playerctl -p brave play-pause
        [[ "$PLAYER" == "MPD" ]] && mpc -h 127.0.0.1 -p 6601 toggle
        ;;
    1)  # Cancel → Solo salir de Zenity (ESCAPE)
        exit 0
        ;;
    256)  # Extra button → Previous
        [[ "$PLAYER" == "Spotify" ]] && playerctl -p spotify previous
        [[ "$PLAYER" == "Brave" ]] && playerctl -p brave previous
        [[ "$PLAYER" == "MPD" ]] && mpc -h 127.0.0.1 -p 6601 prev
        ;;
    257)  # Extra button → Next
        [[ "$PLAYER" == "Spotify" ]] && playerctl -p spotify next
        [[ "$PLAYER" == "Brave" ]] && playerctl -p brave next
        [[ "$PLAYER" == "MPD" ]] && mpc -h 127.0.0.1 -p 6601 next
        ;;
esac
