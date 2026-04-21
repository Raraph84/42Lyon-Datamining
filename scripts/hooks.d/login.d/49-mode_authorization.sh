#!/usr/bin/env bash

set -e

LIB_ROOT=$(dirname -- "$0")/../../lib

echo '---[ 42LYON MODE AUTHORIZATION ]---'

MODE=$(/usr/share/42/scripts/get-mode.sh || echo default)

echo MODE=$MODE
echo USER=$USER

if [ "$USER" == "bocal" ]; then
	echo warning: Authorization bypass
	echo '---[ END OF 42LYON MODE AUTHORIZATION]---'
	exit 0
fi

source "$LIB_ROOT/42lyon/modes"

case "$MODE" in

exam)
	exam_mode_authorization
	;;

disco)
	disco_mode_authorization
	;;

*)
	echo warning: Unsupported mode
	;;
esac

echo '---[ END OF 42LYON MODE AUTHORIZATION]---'
