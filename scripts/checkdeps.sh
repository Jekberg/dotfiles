#! /usr/bin/env bash
#
# Check for dependencies and print any which are not installed on the system.
# This scripts succeeds only if all dependencies are installed.
#
# Simply run as:
#
# scripts/checkdeps.sh

set -o errexit -o nounset -o pipefail

echo "Checking for missing packages..." > /dev/stderr
MISSING_PKGS="$(grep -vxF -f <(pacman -Qq) packages.txt || echo)"
if [[ -z "${MISSING_PKGS}" ]]
then
    echo "All good!" > /dev/stderr
    exit 0
fi

echo "There are missing packages..." > /dev/stderr
echo "${MISSING_PKGS}"
exit 1
