#! /usr/bin/env sh
#
# This is a utility for synching the actual files with the repository.
# This allows me to experiment with the files until I feel happy with the
# results, at which point I can sync them and commit them to this repository.
#
# Exampels:
#
# sync-files.sh /path/to/file
# sync-files.sh /path/to/dir

set -o errexit -o nounset -o pipefail

TARGET_PATH=$(realpath $1)

case $TARGET_PATH in
"${HOME}/"*)
    LOCAL_PATH="$(dirname home/${TARGET_PATH#${HOME}/})/"
    rsync -avA --delete "${TARGET_PATH}" "${LOCAL_PATH}"
esac
