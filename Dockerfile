FROM quay.io/fedora/fedora-toolbox:40-aarch64 AS base
RUN dnf copr enable -y @asahi/mesa && \
    dnf config-manager -y --save --setopt=*.priority=5 copr:copr.fedorainfracloud.org:group_asahi:mesa && \
    dnf copr enable -y teohhanhui/asahi-krun && \
    dnf --best install -y alsa-lib alsa-plugins-pulseaudio alsa-utils dhcpcd eglinfo glmark2 glx-utils libkrun mesa-demos mesa-dri-drivers passt pipewire-libs pulseaudio-libs pulseaudio-utils socat sommelier virglrenderer xorg-x11-server-Xwayland patchelf --exclude pipewire --exclude pipewire-pulseaudio --exclude pulseaudio && \
    dnf copr enable -y teohhanhui/fex-emu && \
    dnf install -y fex-emu

FROM base AS build
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | bash -s - -y --profile=minimal && \
    . ~/.cargo/env && \
    dnf group install -y c-development && \
    dnf install -y clang-devel libkrun-devel llvm-devel && \
    git clone https://github.com/slp/krun.git --depth=1 && \
    cd krun && \
    cargo build --release && \
    chmod +x target/release/krun{,-guest,-server}

FROM base AS rootfs_unpack
COPY unbreak_chroot.sh /
RUN wget https://rootfs.fex-emu.gg/Fedora_40/2024-05-27/Fedora_40.sqsh && \
    unsquashfs -d rootfs Fedora_40.sqsh && \
    rm Fedora_40.sqsh && \
    bash unbreak_chroot.sh

FROM scratch AS x86_deploy
COPY --from=rootfs_unpack /rootfs /
COPY install_x86.sh /
ENV FEX_ROOTFS=""
RUN ["/fex/bin/FEXInterpreter", "/bin/bash", "/install_x86.sh"]

FROM base AS rootfs_repack
COPY break_chroot.sh /
COPY --from=x86_deploy / /rootfs
RUN bash break_chroot.sh

FROM base AS final
COPY --from=build krun/target/release/krun krun/target/release/krun-guest krun/target/release/krun-server /usr/local/bin/
COPY --from=rootfs_repack /rootfs /fex
ENV FEX_ROOTFS="/fex"
