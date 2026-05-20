#!/bin/bash

prom_file="/usr/share/42/prometheus/workstation_info.prom"

if [ ! -r "$prom_file" ]; then
	echo "default"
	exit 0
fi

wallpaper=$(sed -nE 's/^workstation_wallpaper\{.*wallpaper="([^"]+)".*$/\1/p' "$prom_file" | head -n 1)

if [ -n "$wallpaper" ]; then
	echo "$wallpaper"
else
	echo "default"
fi
