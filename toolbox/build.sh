#!/usr/bin/env bash
# Build a toolbox AppImage on a remote Linux host and fetch it back.
#
#   ./toolbox/build.sh goralek16              # core profile
#   ./toolbox/build.sh goralek16 k8s          # a named profile from tools.nix
#   ./toolbox/build.sh goralek16 base,net,aws # ad-hoc mix of groups
#   ./toolbox/build.sh goralek16 --list       # what profiles and groups exist
#   OUT=~/Downloads ./toolbox/build.sh goralek16 aws
set -euo pipefail

host=${1:?usage: build.sh <ssh-host> [profile | group,group,... | --list]}
what=${2:-core}
out=${OUT:-.}
src=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
remote=/tmp/toolbox-src
nix="nix --extra-experimental-features 'nix-command flakes'"

rsync -a --delete --exclude .git --exclude __pycache__ "$src/" "$host:$remote/"

# Nix snippets go over as files: quoting them through ssh + the remote shell is
# not worth the debugging.
send_expr() { ssh "$host" "cat > $remote/.expr.nix"; }

if [ "$what" = --list ]; then
	send_expr <<-NIX
		let f = (builtins.getFlake "path:$remote").lib.\${builtins.currentSystem}; in
		builtins.concatStringsSep "\n"
		  (map (p: p + ": " + builtins.concatStringsSep " " f.profiles.\${p})
		    (builtins.attrNames f.profiles))
	NIX
	ssh "$host" "$nix eval --impure --raw --file $remote/.expr.nix"
	echo
	exit 0
fi

if [ "${what#*,}" != "$what" ]; then
	# comma list -> ad-hoc groups, resolved through the flake's lib.mkToolbox
	groups=$(printf '"%s" ' ${what//,/ })
	name=toolbox-custom
	send_expr <<-NIX
		((builtins.getFlake "path:$remote").lib.\${builtins.currentSystem}.mkToolbox {
		  groups = [ $groups ];
		}).appimage
	NIX
	path=$(ssh "$host" "$nix build --no-write-lock-file --no-link --print-out-paths \
		--impure --file $remote/.expr.nix")
else
	if [ "$what" = core ]; then name=toolbox; else name="toolbox-$what"; fi
	path=$(ssh "$host" "cd $remote && $nix build --no-write-lock-file --no-link --print-out-paths .#$name")
fi

echo "built $path"
scp "$host:$path" "$out/$name.AppImage"
chmod +x "$out/$name.AppImage"
ls -lh "$out/$name.AppImage"
