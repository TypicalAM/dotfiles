# Kill the old polybar instance
killall -q polybar

# Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# Sleep for one second to make sure that the audio devices are initialized
sleep 1

# Launch the bar
polybar -q main -c "~/.config/polybar/theme/config.ini" &	
