gitc() {
	local repo
	repo=$(xclip -selection cliboard -o)
	cd "$HOME/src" || return
	git clone "$repo" && cd "$(basename "$repo" .git)" || return
}

hello() {
	local date
	date="$(date +%Y%m%d)"
	if ! echo "$date" | cmp "$HOME/temp/date" - >/dev/null 2>&1; then
		echo Dzien dobry!
		echo "$date" >~/temp/date
	fi
}
hello

venv_new() {
	python3 -m venv venv
	source "venv/bin/activate"
}

run_c() {
	gcc "$*.c" -o "$*.c" -lm
	"./$*"
}

nvimrc() {
	cd ~/.config/nvim || return
	nvim init.lua
}

rangerrc() {
	cd ~/.config/ranger || return
	nvim rc.conf
}

kittyrc() {
	cd ~/.kitty || return
	nvim kitty.conf
}

aliasrc() {
	cd ~/.bashrc.d || return
	nvim aliases.sh
}

gotest() {
	cd /home/adam/code/sandbox/go-test || return
	nvim main.go
	clear
}

pcd() {
	local choice
	if choice="$(fzf <~/additional/projects)"; then
		cd "/home/adam/$choice" || return
	fi
}

sw() {
	tmux switch-client -t "$(tmux list-sessions -F '#{session_name} - #{session_windows} windows #{session_path}' | grep -v 'random' | fzf | cut --delimiter=' ' --fields=1 | sed 's/: .*//g')"
	tmux list-sessions -F '#{session_attached} #{session_name}' | grep "^0 random" | cut --delimiter=' ' --fields=2 | xargs -I {} -- tmux kill-session -t {}
}

sdel() {
	local name
	name="$(tmux list-sessions -F '#{session_name} - #{session_windows} windows #{session_path}' | grep -v 'random' | fzf)"
	[[ -n "$name" ]] && tmux kill-session -t "$(echo "$name" | cut --delimiter=' ' --fields=1 | sed 's/: .*//g')"
}

snew() {
	local name
	name="$(fzf --print-query <~/additional/session_names | tail -n 1)"
	TMUX='' tmux new-session -d -s "$name" -c /home/adam
	tmux switch-client -t "$name"
	tmux list-sessions -F '#{session_attached} #{session_name}' | grep "^0 random" | cut --delimiter=' ' --fields=2 | xargs -I {} -- tmux kill-session -t {}
}

sdef() {
	local name
	name="random-$(tr -dc "A-Za-z1-9" </dev/urandom | head -c 5)"
	TMUX='' tmux new-session -A -s "$name" -d -c /home/adam
	tmux switch-client -t "$name"
}

ncd() {
	local choice
	if choice="$(find -- ~/notes/* -type d | fzf)"; then
		cd "$choice" || return
	fi
}

ccd() {
	local choice
	if choice="$(find -- ~/code/* -type d | fzf)"; then
		cd "$choice" || return
	fi
}

temp-diff() {
	: >/tmp/first_file
	: >/tmp/second_file
	nvim /tmp/first_file && nvim /tmp/second_file && kitty +kitten diff /tmp/first_file /tmp/second_file
}

docker_image_tags() {
	local input_path
	input_path="$*"
	IFS='/' read -r namespace repository <<<"$input_path"
	curl --silent "https://hub.docker.com/v2/namespaces/$namespace/repositories/$repository/tags?page_size=100" | jq -r '.results[].name'
}

col() {
	awk -v col="$1" '{print $col}' "${@:2}"
}
