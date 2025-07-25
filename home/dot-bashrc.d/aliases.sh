# Package management related stuff
alias inst='sudo dnf -y install'
alias uninst='sudo dnf -y remove'
alias upt='sudo dnf -y update'
alias ds='sudo dnf search'

# Configuration files
alias zshrc='nvim ~/.zshrc'
alias i3rc='nvim ~/.config/i3/config'
alias ra='. ranger'
alias cal='calcurse'

# Git aliases
alias ga='git add .'
alias gc='git commit'
alias gs='git status'
alias gd='git diff | bat'

# Navigation and file operations
alias lx='eza -alhG --group-directories-first'
alias cd.='cd ../'
alias cd..='cd ../../'
alias x='xdg-open'
alias kdiff="kitty +kitten diff"
alias mv='mv -v'
alias mvr='bash "/home/adam/code/scripts/move_recent_downloads.sh"'
alias cpp='rsync -r --info=progress2 '
alias rf='rm -r -f'

# Other
alias v='xclip -selection clipboard -o'
alias c='xclip -selection clipboard'
alias s="grep -i --color"
alias e='exit'
alias q='exit'
alias vix='/bin/vim -x'
alias vi='nvim'
alias jar='java -jar'
alias ka='killall'
alias hs='history |s'
alias mp='python3 manage.py'
alias mr='python3 manage.py runserver'
alias ms='python3 manage.py shell'
alias mt='python3 manage.py test'
alias mm='python3 manage.py migrate'
alias mmm='python3 manage.py makemigrations'
alias py='python3'
alias mount='sudo mount'
alias umount='sudo umount'
alias disks='fdisk -l |s dev'
alias check_keys="xev -event keyboard  | egrep -o 'keycode.*\)'"
alias dc='docker compose'
alias todo='nvim "$HOME/notes/luzne notatki/todo.md"'
alias virsh='virsh --connect=qemu:///system'
alias dev='kitty +kitten ssh nix-dev -t /mnt/share/additional/dotfiles/scripts/start-tmux.sh'
alias restic_qcow='restic -r sftp:poznan-server:/mnt/drive/backups/restic_windows_images --password-command "pass ResticWindowsPassword" backup /mnt/virt/images/win11/win11.qcow2'
