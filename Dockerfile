FROM quay.io/fedora/fedora-toolbox:40-aarch64 AS base
RUN dnf copr enable -y @asahi/mesa && \
    dnf config-manager -y --save --setopt=*.priority=5 copr:copr.fedorainfracloud.org:group_asahi:mesa && \
    dnf copr enable -y teohhanhui/asahi-krun && \
    dnf --best install -y alsa-lib alsa-plugins-pulseaudio alsa-utils dhcpcd eglinfo glmark2 glx-utils libkrun mesa-demos mesa-dri-drivers passt pipewire-libs pulseaudio-libs pulseaudio-utils socat sommelier virglrenderer xorg-x11-server-Xwayland patchelf --exclude pipewire --exclude pipewire-pulseaudio --exclude pulseaudio

FROM base AS build
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | bash -s - -y --profile=minimal && \
    . ~/.cargo/env && \
    dnf group install -y c-development && \
    dnf install -y clang-devel libkrun-devel llvm-devel && \
    git clone https://github.com/slp/krun.git --depth=1 && \
    cd krun && \
    cargo build --release && \
    chmod +x target/release/krun{,-guest,-server}

FROM base AS rootfs
RUN dnf copr enable -y teohhanhui/fex-emu && \
    dnf install -y fex-emu && \
    dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm && \
    wget https://rootfs.fex-emu.gg/Fedora_40/2024-05-27/Fedora_40.sqsh && \
    unsquashfs -d /fex Fedora_40.sqsh && \
    rm Fedora_40.sqsh

FROM rootfs AS final
RUN mkdir -p /fex/etc/yum.repos.d && \
    cp /etc/yum.repos.d/{fedora,fedora-updates,fedora-updates-testing}.repo /fex/etc/yum.repos.d/ && \
    dnf --installroot="/fex" --forcearch=x86_64 --releasever=/ install -y system-release && \
    dnf --installroot="/fex" --forcearch=x86_64 copr enable -y @asahi/mesa && \
    dnf --installroot="/fex" --forcearch=x86_64 config-manager -y --save --setopt=*.priority=5 copr:copr.fedorainfracloud.org:group_asahi:mesa* && \
    dnf --installroot="/fex" --forcearch=x86_64 --best install -y alsa-plugins-pulseaudio alsa-utils eglinfo glmark2 glx-utils mesa-demos mesa-dri-drivers pipewire-libs pulseaudio-libs pulseaudio-utils --exclude pipewire-pulseaudio --exclude pulseaudio && \
    dnf --installroot="/fex" --forcearch=x86_64 install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm && \
    dnf --installroot="/fex" --forcearch=x86_64 install -y steam --exclude pipewire --exclude pipewire-pulseaudio --exclude pulseaudio
COPY --from=build krun/target/release/krun krun/target/release/krun-guest krun/target/release/krun-server /usr/local/bin/
ENV FEX_ROOTFS="/fex"
