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
		cd "$choice" || return
	fi
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
