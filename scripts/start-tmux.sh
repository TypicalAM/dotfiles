#!/usr/bin/env bash
#
# Starts tmux on my dev VM

# Create or attach to a tmux session with a random name
SESSION="random-$(tr -dc A-Za-z1-9 </dev/urandom | head -c5)"
tmux new-session -A -s "$SESSION"

# Cleanup: Kill unattached random-* sessions, except the one we just used
tmux list-sessions -F "#{session_attached} #{session_name}" \
  | grep "^0 random" \
  | awk '{print $2}' \
  | grep -v "^$SESSION$" \
  | xargs -r tmux kill-session -t
