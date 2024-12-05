#! /usr/bin/env bash

set -eu
pkill -f nwg-dock-hyprland || true

# Reloading seem to fail if we don't wait a bit after shuttinf down the
# previous instance.
sleep 0.1 && nwg-dock-hyprland -x -i 38 -mt 1 -mb 8 -iw special -c "${HOME}/.local/bin/app-launcher.sh" &
