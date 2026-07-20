#!/usr/bin/env bash

set -e

LIB_ROOT=$(dirname -- "$0")/../../lib
echo ''
echo '---[ 42LYON LOGIN ]---'

source "$LIB_ROOT/42lyon/radio"
source "$LIB_ROOT/42lyon/fw"
source "$LIB_ROOT/goinfres"

radio_off
fw_antispoof

# Unmount sgoinfre in piscine and disco modes
MODE=$(/usr/share/42/scripts/get-mode.sh || echo "default")
if [ "$MODE" = "piscine" ] || [ "$MODE" = "disco" ]; then
    echo "Unmounting sgoinfre in $MODE mode"
    sgoinfre_umount
fi

echo '---[ END OF 42LYON LOGIN ]---'
echo ''
