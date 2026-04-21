#!/usr/bin/env bash

set -e

LIB_ROOT=$(dirname -- "$0")/../../lib
echo '---[ LOGOUT SCRIPT ]---'

echo "lib root if $LIB_ROOT"
source "$LIB_ROOT/common"
source "$LIB_ROOT/iscsi"
source "$LIB_ROOT/exam"
source "$LIB_ROOT/fw"
source "$LIB_ROOT/cron"
source "$LIB_ROOT/hosts"

init

if [[ "exam" == $USER ]]; then
    exam_clean
else
    iscsi_umount
    pkill -9 -f home_watcher.py
fi

fw_user
hosts_restore
crontab_clean

echo '---[ END OF LOGOUT SCRIPT ]---'
