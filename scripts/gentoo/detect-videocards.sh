#!/usr/bin/env bash
#
# This is a simple script which aims to detect which video card use flags
# should be used. A system may have more than a single graphics card, and
# some cards require multiple use flags to be selected.

hw_to_videocards() {
    local description=$(cat /dev/stdin)
    case $description in
        "Navi 31 [Radeon RX 7900 XT/7900 XTX/7900 GRE/7900M]"| \
        "Phoenix1")
            echo "amdgpu"
            echo "radeonsi"
            ;;
        *)
            # We have not seen this video card before
            echo "Unknown video card: $description" > /dev/stderr
            exit 1
            ;;
    esac
}

lshw -class display -json 2> /dev/null |  jq -r '.[].product' | hw_to_videocards | uniq
