#! /usr/bin/env bash
#
# wlogout will add round up the number of buttons per row, e.g. if there are 2
# buttons configured then wlogout will round up to 3 buttons. To work around this,
# just set the the number of buttons per row. I want all buttons in a single row,
# so we must keep this up to date with the number of buttons configured.

set -o errexit -o nounset -o pipefail
wlogout --buttons-per-row 4
