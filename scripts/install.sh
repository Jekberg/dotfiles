#! /usr/bin/env bash
#
# This is an install script which can be run to setup the dot files on a
# computer.
#
# TODO - Prompt the user which parts should be installed or not.

set -o errexit -o nounset -o pipefail

echo "Installing home files!" > /dev/stderr
HOME_FILES=$(find  home/ -type f)
for LOCAL_PATH in $HOME_FILES
do
    if ! [[ -d "${HOME}" ]]
    then
        echo "The $HOME directory for $USER, does not exist!" > /dev/stderr
        exit 1
    fi

    TARGET_PATH="$HOME/${LOCAL_PATH#home/}"
    mkdir -p $(dirname "${TARGET_PATH}")
    cp -vr "${LOCAL_PATH}" "${TARGET_PATH}" > /dev/stderr
done
