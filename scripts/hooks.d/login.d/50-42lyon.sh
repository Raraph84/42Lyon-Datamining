#!/usr/bin/env bash

set -e

LIB_ROOT=$(dirname -- "$0")/../../lib
echo ''
echo '---[ 42LYON LOGIN ]---'

source "$LIB_ROOT/42lyon/radio"
source "$LIB_ROOT/42lyon/fw"

radio_off
fw_antispoof

echo '---[ END OF 42LYON LOGIN ]---'
echo ''
