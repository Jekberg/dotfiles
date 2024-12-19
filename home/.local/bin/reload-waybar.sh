#! /usr/bin/env bash
#
# This script is a utility for reloading waybar. Nothing much special going on
# here. Just annoying that waybar does not automatically reload on config
# changes.
set -eu
pkill waybar || true
waybar &
