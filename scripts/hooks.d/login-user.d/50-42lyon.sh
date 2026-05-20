#!/usr/bin/env bash

set -e

LIB_ROOT=$(dirname -- "$0")/../../lib
echo '---[ 42LYON LOGIN-USER ]---'

source "$LIB_ROOT/42lyon/discord"

discord_setup

echo '---[ END OF 42LYON LOGIN-USER ]---'
echo ''
