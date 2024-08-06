#!/bin/sh

set -euo pipefail

SCRIPTPATH="rootfs/"
BACKUPPATH="$SCRIPTPATH/chroot/"

echo "Moving rootfs files back to original location"
# Move back files that we removed
mv "$BACKUPPATH/etc/resolv.conf" "$SCRIPTPATH/etc/"
mv "$BACKUPPATH/etc/localtime" "$SCRIPTPATH/etc/"
mv "$BACKUPPATH/etc/passwd" "$SCRIPTPATH/etc/"
mv "$BACKUPPATH/etc/passwd-" "$SCRIPTPATH/etc/"
mv "$BACKUPPATH/etc/group" "$SCRIPTPATH/etc/"
mv "$BACKUPPATH/etc/group-" "$SCRIPTPATH/etc/"
mv "$BACKUPPATH/etc/shadow" "$SCRIPTPATH/etc/"
mv "$BACKUPPATH/etc/shadow-" "$SCRIPTPATH/etc/"
mv "$BACKUPPATH/etc/gshadow" "$SCRIPTPATH/etc/"
mv "$BACKUPPATH/etc/gshadow-" "$SCRIPTPATH/etc/"
mv "$BACKUPPATH/etc/fstab" "$SCRIPTPATH/etc/"
mv "$BACKUPPATH/etc/mtab" "$SCRIPTPATH/etc/"
mv "$BACKUPPATH/etc/subuid" "$SCRIPTPATH/etc/"
mv "$BACKUPPATH/etc/subgid" "$SCRIPTPATH/etc/"
mv "$BACKUPPATH/etc/machine-id" "$SCRIPTPATH/etc/"

rmdir "$BACKUPPATH/etc"

echo "Moving rootfs folders back to original location"
# Move back folders that we removed
mv "$BACKUPPATH/boot" "$SCRIPTPATH"
mv "$BACKUPPATH/home" "$SCRIPTPATH"
mv "$BACKUPPATH/media" "$SCRIPTPATH"
mv "$BACKUPPATH/mnt" "$SCRIPTPATH"
mv "$BACKUPPATH/root" "$SCRIPTPATH"
mv "$BACKUPPATH/srv" "$SCRIPTPATH"
mv "$BACKUPPATH/tmp" "$SCRIPTPATH"
mv "$BACKUPPATH/run" "$SCRIPTPATH"

# Only move opt if it is empty
[ "$(ls -A $BACKUPPATH/opt)" ] && true || mv "$BACKUPPATH/opt" "$SCRIPTPATH"

echo "Moving rootfs folders back to original location"
mv "$BACKUPPATH/var/lib/dbus" "$SCRIPTPATH/var/lib/"
mv "$BACKUPPATH/var/tmp" "$SCRIPTPATH/var/"
mv "$BACKUPPATH/var/run" "$SCRIPTPATH/var/"
mv "$BACKUPPATH/var/lock" "$SCRIPTPATH/var/"

rmdir "$BACKUPPATH/var/cache/"
rmdir "$BACKUPPATH/var/lib/"
rmdir "$BACKUPPATH/var"

rmdir "$BACKUPPATH"

echo "Copying FEXInterpreter in to chroot"
mkdir "$SCRIPTPATH/fex/"
mkdir "$SCRIPTPATH/fex/bin/"
mkdir "$SCRIPTPATH/fex/lib64/"

cp $(which FEXInterpreter) "$SCRIPTPATH/fex/bin/"
cp $(which FEXServer) "$SCRIPTPATH/fex/bin/"

# Could probably make this dynamic based on ldd output. My bash scripting isn't good enough for that.
cp /lib64/libstdc++.so.6 "$SCRIPTPATH/fex/lib64/"
cp /lib64/libm.so.6 "$SCRIPTPATH/fex/lib64/"
cp /lib64/libgcc_s.so.1 "$SCRIPTPATH/fex/lib64/"
cp /lib64/libc.so.6 "$SCRIPTPATH/fex/lib64/"
cp /lib/ld-linux-aarch64.so.1 "$SCRIPTPATH/fex/lib64/"

# Change interpreter path and add an rpath to search for the binaries.
patchelf --set-interpreter /fex/lib64/ld-linux-aarch64.so.1 "$SCRIPTPATH/fex/bin/FEXInterpreter"
patchelf --add-rpath /fex/lib64/ "$SCRIPTPATH/fex/bin/FEXInterpreter"
patchelf --set-interpreter /fex/lib64/ld-linux-aarch64.so.1 "$SCRIPTPATH/fex/bin/FEXServer"
patchelf --add-rpath /fex/lib64/ "$SCRIPTPATH/fex/bin/FEXServer"
patchelf --add-rpath /fex/lib64/ "$SCRIPTPATH/fex/lib64/libstdc++.so.6"

echo "Changing rootfs permissions on /tmp"
# For some reason /tmp ends up being 0664
chmod 1777 "$SCRIPTPATH/tmp"

# Create and mount folders
mkdir "$SCRIPTPATH/sys"
mkdir "$SCRIPTPATH/dev"
mkdir "$SCRIPTPATH/dev/pts"
mkdir "$SCRIPTPATH/proc"

mkdir -p $SCRIPTPATH/usr/share/fex-emu/Config/
