#! /usr/bin/env bash
set -eu

if [ "$EUID" -ne 0 ]
then
    echo "Run as root"
    exit
fi

if ! findmnt "/backup" > /dev/null
then
    echo "/backup mount point required"
    exit
fi

rsync --archive --delete -AXHv --exclude='/backup/*' --exclude='/dev/*' --exclude='/proc/*' --exclude='/sys/*' --exclude='/tmp/*' --exclude='/run/*' --exclude='/mnt/*' --exclude='/media/*' --exclude='/home/*/.cache/*'  --exclude='/lost+found/' --exclude='/var/cache/*' / /backup
