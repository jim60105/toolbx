# syntax=docker/dockerfile:1
ARG UID=1000
ARG VERSION=EDGE
ARG RELEASE=0

########################################
# Base stage
########################################
FROM registry.fedoraproject.org/fedora-toolbox:41 AS base

# Set dnf config
RUN cat <<-"EOF" > /etc/dnf/dnf.conf
[main]
install_weak_deps=False
tsflags=nodocs
EOF

########################################
# Build mvtools stage
########################################
FROM base AS build-mvtools

WORKDIR /build

# RUN mount cache for multi-arch: https://github.com/docker/buildx/issues/549#issuecomment-1788297892
ARG TARGETARCH
ARG TARGETVARIANT

RUN --mount=type=cache,id=dnf-$TARGETARCH$TARGETVARIANT,sharing=locked,target=/var/cache/dnf \
    dnf -y upgrade && \
    dnf -y group install c-development development-tools && \
    dnf -y install meson cmake vapoursynth-devel fftw-devel nasm

RUN --mount=source=vapoursynth-mvtools,target=/vapoursynth-mvtools,z \
    meson setup /vapoursynth-mvtools && \
    ninja install

########################################
# Font unpack stage
########################################
FROM base AS font-unpacker

WORKDIR /fonts

ADD https://github.com/ButTaiwan/iansui/releases/download/v1.000/iansui.zip /tmp/iansui.zip

RUN unzip /tmp/iansui.zip -d /fonts/iansui

########################################
# Final stage
########################################
FROM base AS final

# Create directories with correct permissions
ARG UID
RUN install -d -m 775 -o $UID -g 0 /licenses

# Copy licenses (OpenShift Policy)
COPY --chown=$UID:0 --chmod=775 LICENSE /licenses/Containerfile.LICENSE

# ffmpeg
COPY --from=docker.io/mwader/static-ffmpeg:latest /ffmpeg /usr/bin/
COPY --from=docker.io/mwader/static-ffmpeg:latest /ffprobe /usr/bin/

# Setup host-runner script and symlinks
RUN cat <<-"EOF" > /usr/local/bin/host-runner && \
    chmod 775 /usr/local/bin/host-runner
#!/bin/bash
executable="$(basename ${0})"
exec flatpak-spawn --host "${executable}" "${@}"
EOF

RUN bins=( \
    "flatpak" \
    "podman" \
    "rpm-ostree" \
    "systemctl" \
    "xdg-open" \
    "kitty" \
    ); \
    for f in "${bins[@]}"; do \
    ln -s host-runner "/usr/local/bin/$f";\
    done

# Copy fonts
COPY --chown=$UID:0 --chmod=775 --from=font-unpacker /fonts /usr/local/share/fonts

# Copy mvtools and dependencies
COPY --from=build-mvtools /lib64/libfftw3* /lib64/
COPY --from=build-mvtools /lib64/libvapoursynth* /lib64/
COPY --from=build-mvtools /usr/local/lib64/* /usr/local/lib64/

# RUN mount cache for multi-arch: https://github.com/docker/buildx/issues/549#issuecomment-1788297892
ARG TARGETARCH
ARG TARGETVARIANT

# Make sure the cache is refreshed
ARG RELEASE
RUN --mount=type=cache,id=dnf-$TARGETARCH$TARGETVARIANT,sharing=locked,target=/var/cache/dnf \
    dnf -y upgrade && \
    dnf -y install \
    # Install mpv and vapoursynth
    mpv python3-vapoursynth \
    # Install yt-dlp
    yt-dlp \
    # Install fonts
    google-noto-sans-cjk-fonts

# Copy mpv configs
COPY --chown=$UID:0 --chmod=775 mpv-config /etc/mpv

ARG VERSION
# ARG RELEASE
LABEL name="jim60105/toolbx" \
    # Authors for toolbox
    vendor="containertoolbx" \
    # Maintainer for this container image
    maintainer="jim60105" \
    # Containerfile source repository
    url="https://github.com/jim60105/toolbx" \
    version=${VERSION} \
    # This should be a number, incremented with each change
    release=${RELEASE} \
    io.k8s.display-name="toolbx-video"
# summary="" \
# description=""
