#!/usr/bin/env bash

init() {
    # First argument must be the directory path
    DIR="$1"

    # If not provided, show a Zenity popup and exit
    if [ -z "$DIR" ]; then
        zenity --error --text="Error: Path not defined.\nYou must provide a valid script directory."
        exit 1
    fi

    shift

    # Check if the directory exists
    if [ ! -d "$DIR" ]; then
        zenity --error --text="Directory does not exist:\n$DIR"
        exit 1
    fi

    # Execute all .sh scripts in numeric order
    for script in $(find "$DIR" -maxdepth 1 -type f -name "*.sh" | sort -V); do
        if [ -x "$script" ]; then
            echo "==> Running $script"
            $script $@
            ret=$?
            if [ $ret -ne 0 ]; then
                exit $ret
            fi
        else
            echo "==> Skipped (not executable): $script"
        fi
    done
}

init /usr/share/42/scripts/hooks.d/login-user.d $@ >> /var/log/hooks.d/user.log 2>&1

exec $@ >> /var/log/hooks.d/user.log 2>&1

exit $?
