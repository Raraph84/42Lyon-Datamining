#!/usr/bin/env bash

source /usr/share/42/ft_lock.conf

IDLE_LIMIT=$(($TIMEOUT_LOCK_MINUTES * 60))
KILL_LIMIT=$(($TIMEOUT_DELOG_FORCED_MINUTES * 60))
LOG_FILE="/var/log/idle-watch.log"

while true; do
    USER_SESSION=$(loginctl show-session "$(loginctl show-seat seat0 -p ActiveSession --value)" -p Name --value)

    if [ "$USER_SESSION" = "lightdm" ] || [ -z "$USER_SESSION" ]; then
        echo "$(date '+%F %T') - User 'lightdm' detected, skipping" | tee -a "$LOG_FILE"
        sleep 10
        continue
    fi

    DISPLAY=":0"
    XAUTHORITY="$(getent passwd $USER_SESSION | cut -d ':' -f 6)/.Xauthority"
    DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u "$USER_SESSION")/bus"

    idle_ms=$(sudo -u "$USER_SESSION" DISPLAY="$DISPLAY" XAUTHORITY="$XAUTHORITY" xprintidle 2>/dev/null)

    if ! [[ "$idle_ms" =~ ^[0-9]+$ ]]; then
        echo "$(date '+%F %T') - Failed to retrieve idle time for $USER_SESSION" | tee -a "$LOG_FILE"
        sleep 10
        continue
    fi

    echo "$(date '+%F %T') - Idle: $(printf '%02dh %02dm %02ds' $((idle_ms/1000/3600)) $(( (idle_ms/1000%3600)/60 )) $((idle_ms/1000%60 ))) for $USER_SESSION" | tee -a "$LOG_FILE"

    PID=$(ps -u "$USER_SESSION" -o pid=,cmd= | awk '$2=="ft_lock"{print $1; exit}')
    runtime=0

    if [ -z "$PID" ]; then
        if [ "$idle_ms" -ge "$((IDLE_LIMIT * 1000))" ]; then
            echo "$(date '+%F %T') - Starting ft_lock for $USER_SESSION" | tee -a "$LOG_FILE"

            sudo -u "$USER_SESSION" DBUS_SESSION_BUS_ADDRESS="$DBUS_SESSION_BUS_ADDRESS" dbus-send \
                --session --dest=org.gnome.Shell --type=method_call \
                /org/gnome/Shell org.freedesktop.DBus.Properties.Set \
                string:org.gnome.Shell string:OverviewActive variant:boolean:false

            sudo -u "$USER_SESSION" DISPLAY="$DISPLAY" XAUTHORITY="$XAUTHORITY" /usr/local/bin/ft_lock &
        fi
    else
        runtime=$(( $(date +%s) - $(date -d "$(ps -o lstart= -p $PID)" +%s) ))
        echo "$(date '+%F %T') - ft_lock running for $(printf '%02dh %02dm %02ds' $((runtime/3600)) $(( (runtime%3600)/60 )) $((runtime%60)))" | tee -a "$LOG_FILE"
    fi

    if [[ "$runtime" -ge $((KILL_LIMIT - IDLE_LIMIT)) || "$idle_ms" -ge $(((KILL_LIMIT - IDLE_LIMIT) * 1000)) ]]; then
        echo "$(date '+%F %T') - Idle or ft_lock exceeds limit, terminating user $USER_SESSION" | tee -a "$LOG_FILE"
        loginctl terminate-user "$USER_SESSION"
    fi

    sleep 10
done