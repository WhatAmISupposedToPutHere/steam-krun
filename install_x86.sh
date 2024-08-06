#!/bin/sh

set -euo pipefail

dnf copr enable -y @asahi/mesa
dnf config-manager --save --setopt=*.priority=5 copr:copr.fedorainfracloud.org:group_asahi:mesa
dnf remove -y pipewire pulseaudio
dnf --best install -y alsa-plugins-pulseaudio alsa-utils eglinfo glmark2 glx-utils mesa-demos mesa-dri-drivers mesa-libEGL-devel pulseaudio-utils --exclude pipewire --exclude pipewire-pulseaudio --exclude pulseaudio
dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
dnf install -y steam --exclude pipewire --exclude pipewire-pulseaudio --exclude pulseaudio
find /bin \! -user 1000 -exec chown -R 1000:1000 {} +
find /etc \! -user 1000 \! -name resolv.conf \! -name hosts -exec chown -R 1000:1000 {} +
find /lib \! -user 1000 -exec chown -R 1000:1000 {} +
find /lib64 \! -user 1000 -exec chown -R 1000:1000 {} +
find /sbin \! -user 1000 -exec chown -R 1000:1000 {} +
find /usr \! -user 1000 -exec chown -R 1000:1000 {} +
find /var \! -user 1000 -exec chown -R 1000:1000 {} +
