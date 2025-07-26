#!/usr/bin/env bash
#
# Pastes clipboard contents to a GitHub Gist and replaces the clipboard
# with the resulting Gist URL. Supports Wayland and X11.
# Logs to /tmp/gist_clip.log

LOGFILE=$(mktemp /tmp/gist_clip.XXXXXX.log)
exec > >(tee -a "$LOGFILE") 2>&1

ROFI_COMMAND="rofi -dmenu -i -theme ~/.config/rofi/default_no_icons_small.rasi"
ICON="/usr/share/icons/McMojave-circle-purple/status/32/dialog-information.svg"
EXAMPLE_NAMES="script.sh\ndocument.md\nprogram.c\ntest.py\ntest.go"
EXAMPLE_DESCRIPTIONS="Shared with <3 by Adam\nKod"

echo "[INFO] Starting script at $(date)"
echo "[INFO] Using log file: $LOGFILE"
echo "[INFO] WAYLAND_DISPLAY=$WAYLAND_DISPLAY"

get_clip() {
	if command -v wl-paste >/dev/null && [ "$WAYLAND_DISPLAY" ]; then
		echo "[INFO] Using wl-paste"
		wl-paste
	elif command -v xclip >/dev/null; then
		echo "[INFO] Using xclip"
		xclip -selection clipboard -o
	elif command -v xsel >/dev/null; then
		echo "[INFO] Using xsel"
		xsel --clipboard --output
	else
		echo "[ERROR] No clipboard tool found (xclip, xsel, wl-paste)"
		exit 1
	fi
}

set_clip() {
	if command -v wl-copy >/dev/null && [ "$WAYLAND_DISPLAY" ]; then
		echo "[INFO] Using wl-copy"
		wl-copy
	elif command -v xclip >/dev/null; then
		echo "[INFO] Using xclip to set clipboard"
		xclip -selection clipboard
	elif command -v xsel >/dev/null; then
		echo "[INFO] Using xsel to set clipboard"
		xsel --clipboard --input
	else
		echo "[ERROR] No clipboard tool found (xclip, xsel, wl-copy)"
		exit 1
	fi
}

ensure_available() {
	command -v "${1}" >/dev/null 2>&1 || {
		echo -e "[ERROR] ${1} isn't available!" >&2
		exit 1
	}
	echo "[OK] Found: $1"
}

paste_gist() {
	local chosen_name
	chosen_name="$(echo -e "${EXAMPLE_NAMES}" | ${ROFI_COMMAND} -p Filename)"
	[[ "$chosen_name" == "" ]] && echo "[INFO] Cancelled at filename step" && exit 0

	TMPFILE="/tmp/${chosen_name}"
	get_clip >"$TMPFILE"
	echo "[INFO] Clipboard saved to $TMPFILE"

	local description
	description="$(echo -e "${EXAMPLE_DESCRIPTIONS}" | ${ROFI_COMMAND} -p Description)"
	[[ "$description" == "" ]] && echo "[INFO] Cancelled at description step" && exit 0

	local output
	output=$(gist --private --description "${description}" "$TMPFILE")
	echo "[INFO] Gist URL: $output"

	echo "$output" | set_clip
	notify-send "Gist has been saved" "It is available at $output" -i "$ICON" || echo "[WARN] notify-send failed"
}

ensure_available "gist"
ensure_available "rofi"

paste_gist
