#!@shell@
# Single entrypoint of the toolbox AppImage.
#
# Everything mutable lives in a state directory next to the .AppImage file, so
# deleting that directory (or the folder the image was dropped into) leaves no
# trace on the host.
set -eu

# Started from inside a toolbox, whose environment is still exported. Normally
# the AppImage runtime already fails on FUSE before getting here (and the
# toolbox shell refuses it at the prompt), but extract-and-run gets this far; a
# toolbox in a toolbox only stacks namespaces and state dirs.
if [ -n "${TOOLBOX_ENV-}" ]; then
	printf '%s: already inside %s (state: %s); exit to get back to the host\n' \
		@name@ "${TOOLBOX_NAME:-a toolbox}" "${TOOLBOX_ROOT:-?}" >&2
	exit 1
fi

TOOLBOX_NAME=@name@
TOOLBOX_ENV=@env@
TOOLBOX_SEED=@seed@
TOOLBOX_STAMP=@stamp@

export TOOLBOX_NAME TOOLBOX_ENV TOOLBOX_SEED

# --- environment -------------------------------------------------------------

export PATH="$TOOLBOX_ENV/bin:${PATH:-/usr/bin:/bin}"
export SSL_CERT_FILE="@cacert@/etc/ssl/certs/ca-bundle.crt"
export NIX_SSL_CERT_FILE="$SSL_CERT_FILE"
export CURL_CA_BUNDLE="$SSL_CERT_FILE"
export GIT_SSL_CAINFO="$SSL_CERT_FILE"
export LOCALE_ARCHIVE="@localeArchive@"
export TERMINFO_DIRS="@terminfo@/share/terminfo:${TERMINFO_DIRS:-/usr/share/terminfo:/lib/terminfo}"
export LANG="${LANG:-C.UTF-8}"
export TERM="${TERM:-xterm-256color}"

# --- state directory ---------------------------------------------------------

# $APPIMAGE is set by the AppImage runtime and points at the image file on the
# host filesystem (still reachable: AppRun bind-mounts everything but /nix).
image="${APPIMAGE:-${ARGV0:-$0}}"
root="$(cd -- "$(dirname -- "$image")" && pwd)"
state="${TOOLBOX_STATE:-$root/.$TOOLBOX_NAME}"

# Installed somewhere read-only (/usr/bin on an image-based system), the state
# can't live next to the image, so it goes to the host's config dir instead.
# Resolved here, before XDG_CONFIG_HOME is repointed into the state itself.
state_fallback=
if [ -z "${TOOLBOX_STATE-}" ] && [ ! -d "$state" ] && [ ! -w "$root" ]; then
	state="${XDG_CONFIG_HOME:-${HOME:?}/.config}/$TOOLBOX_NAME"
	state_fallback=1
fi

export TOOLBOX_ROOT="$state"
export HOME="$state/home"
export ZDOTDIR="$HOME"
export XDG_CONFIG_HOME="$state/config"
export XDG_DATA_HOME="$state/data"
export XDG_STATE_HOME="$state/state"
export XDG_CACHE_HOME="$state/cache"
export XDG_RUNTIME_DIR="$state/run"
export TMPDIR="$state/tmp"
export SHELL="$TOOLBOX_ENV/bin/zsh"
export EDITOR=nvim VISUAL=nvim PAGER=less

seed() {
	mkdir -p "$HOME" "$XDG_CONFIG_HOME" "$XDG_DATA_HOME" "$XDG_STATE_HOME" \
		"$XDG_CACHE_HOME" "$XDG_RUNTIME_DIR" "$TMPDIR"
	chmod 700 "$XDG_RUNTIME_DIR"

	# Configs are copied out of the read-only image so they stay editable in
	# place -- tweak something during a debug session and it survives until you
	# delete the folder.
	cp -RL "$TOOLBOX_SEED/config/." "$XDG_CONFIG_HOME/"
	cp -RL "$TOOLBOX_SEED/home/." "$HOME/"
	# prefetched nvim plugins; copied out of the image so lazy can write
	# helptags and build artifacts into them
	cp -RL "$TOOLBOX_SEED/data/." "$XDG_DATA_HOME/"
	chmod -R u+w "$XDG_CONFIG_HOME" "$HOME" "$XDG_DATA_HOME"
	printf '%s\n' "$TOOLBOX_STAMP" >"$state/.stamp"
}

if [ ! -e "$state/.stamp" ]; then
	if [ -n "$state_fallback" ]; then
		printf '%s: %s is not writable, keeping state in %s instead\n' \
			"$TOOLBOX_NAME" "$root" "$state" >&2
	fi
	seed
elif [ "$(cat "$state/.stamp")" != "$TOOLBOX_STAMP" ]; then
	printf '%s: state in %s was seeded by a different build; run --reseed to refresh configs\n' \
		"$TOOLBOX_NAME" "$state" >&2
fi

usage() {
	cat <<EOF
$TOOLBOX_NAME -- portable debug toolbox

  ./$TOOLBOX_NAME.AppImage                 interactive shell with all tools on PATH
  ./$TOOLBOX_NAME.AppImage <tool> [args]   run one tool directly
  ./$TOOLBOX_NAME.AppImage -c '<cmd>'      run a command line in the toolbox shell

  --list      list every tool in the image
  --where     print the state directory
  --reseed    re-copy configs from the image (keeps history and caches)
  --purge     delete the state directory
  --help      this

State lives in $state (next to the image, or in \$XDG_CONFIG_HOME when that
folder is read-only; set TOOLBOX_STATE to put it elsewhere).
Delete it (or the whole folder) and nothing of this toolbox remains on the host.
EOF
}

# busybox-style: symlink or rename the image to a tool name and it runs that tool
argv0="$(basename -- "${ARGV0:-$0}")"
argv0="${argv0%.AppImage}"
argv0="${argv0%.appimage}"

# zsh treats an exported ARGV0 as "use this as argv[0] for every command you
# exec". The AppImage runtime exports it, which breaks every multi-call binary in
# the image (coreutils dispatches on argv[0]). We already read it, so drop it.
unset ARGV0

if [ "$argv0" != "$TOOLBOX_NAME" ] && [ -x "$TOOLBOX_ENV/bin/$argv0" ]; then
	exec "$TOOLBOX_ENV/bin/$argv0" "$@"
fi

case "${1-}" in
"" | --shell)
	# -d: ignore the host's /etc/zsh* so the shell is ours, not the host's
	export TOOLBOX_SHELL_SESSION=1
	exec "$SHELL" -di
	;;
--list | -l)
	exec ls "$TOOLBOX_ENV/bin"
	;;
--where)
	printf '%s\n' "$state"
	;;
--reseed)
	seed
	printf 'reseeded %s\n' "$state"
	;;
--purge)
	rm -rf -- "$state"
	printf 'removed %s\n' "$state"
	;;
--help | -h)
	usage
	;;
-c)
	shift
	[ $# -gt 0 ] || { usage >&2; exit 2; }
	exec "$SHELL" -dic "$*"
	;;
*)
	tool="$1"
	if [ -x "$TOOLBOX_ENV/bin/$tool" ]; then
		shift
		exec "$TOOLBOX_ENV/bin/$tool" "$@"
	fi
	printf '%s: no such tool: %s (try --list)\n' "$TOOLBOX_NAME" "$tool" >&2
	exit 127
	;;
esac
