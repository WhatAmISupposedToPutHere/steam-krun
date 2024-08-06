#!/bin/sh

set -euo pipefail

SCRIPTPATH="rootfs/"
BACKUPPATH="$SCRIPTPATH/chroot/"

mkdir "$BACKUPPATH"

rmdir "$SCRIPTPATH/sys"
rmdir "$SCRIPTPATH/dev/pts/"
rmdir "$SCRIPTPATH/dev"
rmdir "$SCRIPTPATH/proc"

# Remove FEXConfig directory
rm -Rf $SCRIPTPATH/usr/share/fex-emu

# Move files from etc that we need to remove
echo "Backing up chroot files"
mkdir -p "$BACKUPPATH/etc/"
mv "$SCRIPTPATH/etc/resolv.conf" "$BACKUPPATH/etc/"
mv "$SCRIPTPATH/etc/localtime" "$BACKUPPATH/etc/"
mv "$SCRIPTPATH/etc/passwd" "$BACKUPPATH/etc/"
mv "$SCRIPTPATH/etc/passwd-" "$BACKUPPATH/etc/"
mv "$SCRIPTPATH/etc/group" "$BACKUPPATH/etc/"
mv "$SCRIPTPATH/etc/group-" "$BACKUPPATH/etc/"
mv "$SCRIPTPATH/etc/shadow" "$BACKUPPATH/etc/"
mv "$SCRIPTPATH/etc/shadow-" "$BACKUPPATH/etc/"
mv "$SCRIPTPATH/etc/gshadow" "$BACKUPPATH/etc/"
mv "$SCRIPTPATH/etc/gshadow-" "$BACKUPPATH/etc/"
mv "$SCRIPTPATH/etc/fstab" "$BACKUPPATH/etc/"
mv "$SCRIPTPATH/etc/mtab" "$BACKUPPATH/etc/"
mv "$SCRIPTPATH/etc/subuid" "$BACKUPPATH/etc/"
mv "$SCRIPTPATH/etc/subgid" "$BACKUPPATH/etc/"
mv "$SCRIPTPATH/etc/machine-id" "$BACKUPPATH/etc/"

# Move various folders
mv "$SCRIPTPATH/boot" "$BACKUPPATH"
mv "$SCRIPTPATH/home" "$BACKUPPATH"
mv "$SCRIPTPATH/media" "$BACKUPPATH"
mv "$SCRIPTPATH/mnt" "$BACKUPPATH"
mv "$SCRIPTPATH/root" "$BACKUPPATH"
mv "$SCRIPTPATH/srv" "$BACKUPPATH"
mv "$SCRIPTPATH/tmp" "$BACKUPPATH"
mv "$SCRIPTPATH/run" "$BACKUPPATH"

echo "Removing FEX copy from rootfs"
rm -Rf "$SCRIPTPATH/fex/"

# Only move opt if it is empty
[ "$(ls -A $SCRIPTPATH/opt)" ] && true || mv "$SCRIPTPATH/opt" "$BACKUPPATH"

mkdir -p "$BACKUPPATH/var/cache/"
mkdir -p "$BACKUPPATH/var/lib/"
mkdir -p "$BACKUPPATH/var/lib/dbus/"

mv "$SCRIPTPATH/var/tmp" "$BACKUPPATH/var/"
mv "$SCRIPTPATH/var/run" "$BACKUPPATH/var/"
mv "$SCRIPTPATH/var/lock" "$BACKUPPATH/var/"
