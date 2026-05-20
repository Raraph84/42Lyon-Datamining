#!/usr/bin/env bash

set -e

LIB_ROOT=$(dirname -- "$0")/../../lib

echo "---[ 42LYON MODE AUTHORIZATION ]---"

MODE=$(/usr/share/42/scripts/get-mode.sh || echo "default")

echo "MODE=$MODE"
echo "USER=$USER"

# Always allow user `bocal` to log in
if [ "$USER" == "bocal" ]; then
	echo "warning: Authorization bypass"
	echo "---[ END OF 42LYON MODE AUTHORIZATION]---"
	exit 0
fi

source "$LIB_ROOT/42lyon/modes"

# Only allow user `exam` to log in when mode is exam
if [ "$USER" == "exam" ] && [ "$MODE" != "exam" ]; then
	access_denied "Please use an Exam workstation."
fi

# Mode specific checks
case "$MODE" in
exam)
	exam_mode_authorization
	;;

disco)
	disco_mode_authorization
	;;

maintenance)
	maintenance_mode_authorization
	;;

*)
	echo "warning: Unsupported mode"
	;;
esac

echo "Access Granted"
echo "---[ END OF 42LYON MODE AUTHORIZATION]---"
