gitc() {
	repo=$(xclip -selection cliboard -o)
	cd ~/src
	git clone "$repo" && cd "$(basename "$repo" .git)"
	unset repo
}
search() {
	printf $PETAL_HONEY
	echo "Searching for "$*" in /"
	printf $PETAL_FOGGY_GRAY
	tree -fi / | grep -v \> |grep -i "$*"
}
sd() {
	printf $PETAL_HONEY
	echo "Searching for "$*" here"
	printf $PETAL_FOGGY_GRAY
	tree -fi $PWD | grep -v \> |grep -i "$*"
}
hello() {
	date=$(date +"%Y%m%d")
	if ! echo $date | cmp $HOME/temp/date - >/dev/null 2>&1
	then
		echo Dzien dobry!
		echo $date >~/temp/date
	fi
}
activate_venv() {
	mkdir "$*"
	cd "$*"
	virtualenv --no-vcs-ignore venv >/dev/null
	source venv/bin/activate
}
run_c() {
	gcc $*.c -o $* -lm
	./$*
}
nvimrc() {
	cd ~/.config/nvim
	nvim init.vim
}
rangerrc() {
	cd ~/.config/ranger
	nvim rc.conf
}
kittyrc() {
	cd ~/.config/kitty
	nvim kitty.conf
}
aliasrc() {
	cd ~/.bashrc.d
	nvim aliases.sh
}
sp() {
	cd /home/adam/code/python/SpareSnack
	source venv/bin/activate
	clear
	ranger --cmd="sparesnack_workspace"
}
sp2() {
	cd /home/adam/code/python/SpareSnack
	source venv/bin/activate
	clear
}
gor() {
	cd /home/adam/code/golang/goread/repo
	clear
	ranger --cmd="goread_workspace"
}
gor2() {
	cd /home/adam/code/golang/goread/repo
	alias run='go run main.go'
	clear
}
gog() {
	cd /home/adam/code/golang/bubble-tea/gogist
	clear
	ranger --cmd="gogist_workspace"
}
gog2() {
	cd /home/adam/code/golang/bubble-tea/gogist
	alias run='go run cmd/gogist/main.go'
	clear
}
gop() {
	cd /home/adam/code/golang/gopoker
	clear
	ranger --cmd="gopoker_workspace"
}
gop2() {
	cd /home/adam/code/golang/gopoker
	alias up='docker compose -f docker-compose.dev.yml up -d'
	alias logs='docker compose -f docker-compose.dev.yml logs -f'
	alias test='docker compose -f docker-compose.dev.yml exec backend gotestsum'
	alias down='docker compose -f docker-compose.dev.yml down'
	clear
}
gop_unsecure() {
	cd /home/adam/notes/studia/dodatkowe/put_request/poker_sniff/network-sniff-workshop
	clear
	ranger --cmd="gopoker_unsecure_workspace"
}
gop2_unsecure() {
	cd /home/adam/notes/studia/dodatkowe/put_request/poker_sniff/network-sniff-workshop
	alias dup='docker compose -f docker-compose.dev.yml up -d'
	alias dlogs='docker compose -f docker-compose.dev.yml logs -f'
	alias dtest='docker compose -f docker-compose.dev.yml exec backend gotestsum'
	alias ddown='docker compose -f docker-compose.dev.yml down'
	alias uup='docker compose -f docker-compose.unsecure.yml up -d'
	alias ulogs='docker compose -f docker-compose.unsecure.yml logs -f'
	alias udown='docker compose -f docker-compose.unsecure.yml down'
	clear
}
gotest() {
	cd /home/adam/code/sandbox/go-test
	nvim main.go
	clear
}
gac() {
	git add .
	git commit -m "$*"
}
