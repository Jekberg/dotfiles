#! /usr/bin/env bash
#
# Start hyprpaper and load the last set wallpaper if there was one. This means
# the system will recall the settings on each startup.

set -o errexit -o nounset -o pipefail

if ! pidof hyprpaper > /dev/null
then
    hyprpaper &
    sleep 1
fi

WALLPAPER_PATH=$(cat ~/.cache/selected_wallpaper)
[[ -f "${WALLPAPER_PATH}" ]] && hyprctl hyprpaper reload ",${WALLPAPER_PATH}"
