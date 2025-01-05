#! /usr/bin/env bash
#
# This is an install script which can be run to setup the dot files on a
# computer.
#
# TODO - Prompt the user which parts should be installed or not.

set -o errexit -o nounset -o pipefail

echo "Installing packages!"
MISSING="$(grep -vxF -f <(pacman -Qq) packages.txt || echo)"
echo $MISSING > /dev/stderr
if [[ -n "${MISSING}" ]]
then
    if ! pacman -Qi yay &> /dev/null
    then
        # Not all package dependencies are official arch packages. Some comes
        # from the AUR. Install a AUR helper to make it convinient to install
        # packages.
        echo "Please install yay:" > /dev/stderr
        echo > /dev/stderr
        echo "git clone https://aur.archlinux.org/yay.git && cd yay" > /dev/stderr
        echo "makepkg -si" > /dev/stderr
        exit 0
    fi

    # Some packages are from the AUR so we can install everything using yay
    yay -S ${MISSING}
fi

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
