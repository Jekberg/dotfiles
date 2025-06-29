#! /usr/bin/env bash
#
# List firmware which is loaded in the kernel logs. This is useful for when
# wanting to remove unused firmware files.

LOAD_FW_MESSAGE="Loading firmware"
journalctl -kg "${LOAD_FW_MESSAGE}" \
    | sed "s/^.*${LOAD_FW_MESSAGE}: //g"
