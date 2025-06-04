#! /usr/bin/env bash
#
# This is just a small utility for selecting wallpapers, nothing fancy.
# Wallpapers will go into the $WALLPAPER_DIR which is scanned by this
# script, making it quick and easy to set the wallpaper.

set -o errexit -o nounset -o pipefail

WALLPAPERS_DIR="${HOME}/.local/wallpapers"
WALLPAPERS=$(find "${WALLPAPERS_DIR}/"  -type f | xargs -n1 basename)
WALLPAPER_FILE=$(echo "${WALLPAPERS}" | rofi -dmenu -p "Select wallpaper")

WALLPAPER_PATH="${WALLPAPERS_DIR}/${WALLPAPER_FILE}"

hyprctl hyprpaper reload ,"${WALLPAPER_PATH}" &&
    echo "${WALLPAPER_PATH}" > ~/.cache/selected_wallpaper
