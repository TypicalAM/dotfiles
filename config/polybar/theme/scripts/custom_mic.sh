#!/usr/bin/env bash

# Get the volume of the microphone
output=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@)

# Check if we are muted or unmuted
if [[ "$output" == *"[MUTED]" ]]; then
	# The microphone is muted
  echo " Muted"
else 
	# The microphone is not muted, drop the first 11 characters
	# Because we only want the value, not the "Volume: 0." prefix
	echo " $(echo $output|cut -c 11-)%"
fi 
