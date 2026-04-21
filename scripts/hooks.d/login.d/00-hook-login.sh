#!/usr/bin/env bash

set -e

LIB_ROOT=$(dirname -- "$0")/../../lib
echo '---[ LOGIN SCRIPT ]---'

echo "lib root if $LIB_ROOT"
source "$LIB_ROOT/common"
source "$LIB_ROOT/iscsi"
source "$LIB_ROOT/exam"
source "$LIB_ROOT/fw"
source "$LIB_ROOT/goinfres"
source "$LIB_ROOT/docker"
source "$LIB_ROOT/radio"
source "$LIB_ROOT/hosts"
source "$LIB_ROOT/home"

init
exam_check_mode

if [[ "exam" == $USER ]]; then
    exam_init
    fw_exam
    hosts_exam
    exit 0
else
    fw_user
    hosts_restore
    iscsi_mount
    home_clean
    goinfre_mount
    goinfre_setup
    sgoinfre_mount
    sgoinfre_setup
    docker_subuid_setup
    radio_enable
fi

echo '---[ END OF LOGIN SCRIPT ]---'
