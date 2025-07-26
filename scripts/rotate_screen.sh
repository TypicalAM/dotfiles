#!/usr/bin/env bash
#
# Rotates the screen 180° (yes) on either X11 (xrandr) or Wayland (Hyprland)

ensure_available() {
	command -v "$1" >/dev/null 2>&1 || {
		echo "[!] $1 is not available" >&2
		exit 1
	}
}

rotate_x11() {
	ensure_available "xrandr"

	local monitor
	monitor=$(xrandr --query | awk '/ connected/ {print $1; exit}')
	local rotation
	rotation=$(xrandr --query --verbose | awk '/ connected/ {getline; print}' | grep -q 'normal' && echo "inverted" || echo "normal")

	xrandr --output "$monitor" --rotate "$rotation"
}

rotate_wayland() {
	ensure_available "hyprctl"
	ensure_available "jq"

	local monitor
	monitor=$(hyprctl monitors | awk '/Monitor/ {print $2; exit}')
	local current
	current=$(hyprctl monitors -j | jq -r '.[0].transform')

	local new_transform
	if [ "$current" = "0" ]; then
		new_transform=2
	else
		new_transform=0
	fi

	hyprctl keyword monitor "$monitor,preferred,auto,1,transform,$new_transform"
}

if [ -n "$WAYLAND_DISPLAY" ]; then
	rotate_wayland
elif [ -n "$DISPLAY" ]; then
	rotate_x11
else
	echo "[!] Unknown session type. Not in X11 or Wayland?"
	exit 1
fi
