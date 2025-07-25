#!/bin/bash
REPO="sftp:poznan-server:/mnt/drive/backups/restic_windows_images"
FILE="/mnt/virt/images/win11/win11.qcow2"
PASSWORD_FILE="/tmp/restic"

pass ResticWindowsPassword >/tmp/restic
restic -r $REPO --password-file $PASSWORD_FILE backup $FILE
rm /tmp/restic
