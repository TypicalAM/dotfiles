#!/usr/bin/env bash

get_mic_status() {
  output=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@)
  if [[ "$output" == *"[MUTED]" ]]; then
    echo " Muted"
  else
    echo " $(echo "$output" | cut -c 11-)%"
  fi
}

if [[ "$1" == "loop" ]]; then
  prev=""
  while true; do
    current=$(get_mic_status)
    if [[ "$current" != "$prev" ]]; then
      echo "$current"
      prev="$current"
    fi
    sleep 0.2
  done
else
  get_mic_status
fi
