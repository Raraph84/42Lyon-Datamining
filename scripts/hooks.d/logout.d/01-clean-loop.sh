#!/usr/bin/env bash

set -e

UMOUNTABLE_DEVICES=()

echo "cleaning $USER mounts"

# unmouting any usb device on logout
for device in /sys/block/*
do
    if udevadm info --query=property --path=$device | grep -q ^ID_BUS=usb
    then
        echo Found $device to unmount
        DEVTO=`echo $device|awk -F"/" 'NF>1{print $NF}'`
        echo `df -h|grep "$(ls /dev/$DEVTO*)"|awk '{print $1}'` is the exact device
        UM=`df -h|grep "$(ls /dev/$DEVTO*)"|awk '{print $1}'`
        if sudo umount $UM
            then echo Done umounting
        fi
    fi
done

# Checking for mounted loop device backed by a file in vm's home
while IFS= read -r line;
do
    DEVICE="$(echo $line | awk '{print $1}')"
    BACKEND="$(echo $line | awk '{print $2}')"
    if echo "$BACKEND" | grep -E "^$HOME"; then
        echo "backed by something in the home ? $DEVICE $BACKEND"
        UMOUNTABLE_DEVICES+=($DEVICE)
    fi
done <<< "$(losetup -a -n --output NAME,BACK-FILE)"


for (( i= 0; i < ${#UMOUNTABLE_DEVICES[@]}; i++)); do
    DEVICE="${UMOUNTABLE_DEVICES[$i]}"
    echo "checking $DEVICE"
    while IFS= read -r line;
    do
        MOUNTED_DISK="$(echo $line | awk '{print $1}')"
        echo "unmounting $MOUNTED_DISK"
        umount $MOUNTED_DISK
    done <<< "$(mount | grep -E "^$DEVICE")"
done

