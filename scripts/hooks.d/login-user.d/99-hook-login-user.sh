#!/usr/bin/env bash

set -e

LIB_ROOT=$(dirname -- "$0")/../../lib
echo '---[ LOGIN-USER SCRIPT ]---'

echo "lib root if $LIB_ROOT"
source "$LIB_ROOT/common"
source "$LIB_ROOT/goinfres"
source "$LIB_ROOT/docker"
source "$LIB_ROOT/exam"
source "$LIB_ROOT/pyenv"

init

if [[ "exam" != $USER ]]; then
	docker_setup
	pyenv_user_init
	nohup python3 "$LIB_ROOT/home_watcher.py" $USER &
fi

echo '---[ END OF LOGIN-USER SCRIPT ]---'
