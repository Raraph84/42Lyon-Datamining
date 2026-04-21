#!/usr/bin/env bash

vendor=$(/usr/sbin/dmidecode | /usr/bin/grep 'Vendor:' | /usr/bin/awk '{print $2}')
model=$(/usr/sbin/dmidecode | /usr/bin/grep -A3 '^System Information' | /usr/bin/grep 'Product Name' | /usr/bin/awk '{print $4}')
if [ "$vendor" = "Apple" ]; then
        /usr/bin/echo 10 > /sys/class/backlight/acpi_video0/brightness
elif [ "$vendor" = "Dell" ] && [ "$model" = "7400" ]; then
        /usr/bin/echo 42 > /sys/devices/LNXSYSTM:00/LNXSYBUS:00/PNP0A08:00/device:15/PNP0A05:00/DELL0501:00/backlight/dell_uart_backlight/brightness
elif [ "$vendor" = "Dell" ] && [ "$model" = "7780" ]; then
        /usr/bin/echo 42 > /sys/devices/LNXSYSTM:00/LNXSYBUS:00/PNP0A08:00/device:49/DELL0501:00/backlight/dell_uart_backlight
fi

if [ "$vendor" != "VMware," ]; then
        output=$(/usr/bin/xrandr | /usr/bin/grep " connected" | /usr/bin/awk '{ print $1 }')
        /usr/bin/xrandr --output $output --mode 1920x1080
fi