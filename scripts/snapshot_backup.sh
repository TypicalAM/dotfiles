#!/usr/bin/env bash
#
# Backs up the latest RO snapper btrfs snapshot to a remote restic repo

SNAPSHOT_DIR="/home/.snapshots"
PASSWORD_FILE="/tmp/restic"
REPO="/mnt/temp/restic/tygrys20"

echof() {
	local prefix="$1"
	local message="$2"
	case "$prefix" in
	header) msgpfx="[\e[1;95m\e[m]" ;;
	info) msgpfx="[\e[1;97m=\e[m]" ;;
	act) msgpfx="[\e[1;92m*\e[m]" ;;
	ok) msgpfx="[\e[1;93m+\e[m]" ;;
	error) msgpfx="[\e[1;91m!\e[m]" ;;
	*) msgpfx="" ;;
	esac
	echo -e "$msgpfx $message"
}

main() {
	echof info "Backing up the latest snapshot"
	sudo -u adam pass restic/snapshot-password > /tmp/restic
	local filename=$(ls -t1 "$SNAPSHOT_DIR" | head -n 1)
	local snapshotpath="$SNAPSHOT_DIR/$filename"
	unlink $SNAPSHOT_DIR/latest
	ln -s $snapshotpath $SNAPSHOT_DIR/latest
	echof info "Using snapshot $snapshotpath"

	echof info "Mounting backup drive"
	sudo -u adam sshfs poznan-server:/mnt/drive/backups /mnt/temp -o allow_other
	cd $SNAPSHOT_DIR/latest
	echof info "Backing up via restic"
	restic -r $REPO --password-file $PASSWORD_FILE backup --exclude-file /var/home/adam/additional/dotfiles/scripts/snapshot_exclude snapshot
	echof info "Done"
	umount /mnt/temp
}

main "$*"
