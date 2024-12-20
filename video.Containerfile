# syntax=docker/dockerfile:1
ARG UID=1000
ARG VERSION=EDGE
ARG RELEASE=0
ARG BASE_VERSION=quay.io/jim60105/toolbx:latest

########################################
# Base stage
########################################
FROM ${BASE_VERSION} AS base

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

RUN --mount=source=video/vapoursynth-mvtools,target=/vapoursynth-mvtools,z \
    meson setup /vapoursynth-mvtools && \
    ninja install

########################################
# UOSC unpack stage
# (Mpv configs)
########################################

FROM base AS uosc-unpacker

WORKDIR /uosc

ADD https://github.com/tomasklaen/uosc/releases/latest/download/uosc.zip /tmp/uosc.zip

RUN unzip /tmp/uosc.zip -d /uosc

########################################
# Final stage
########################################
FROM base AS final
ARG UID

# ffmpeg
COPY --from=docker.io/mwader/static-ffmpeg:latest /ffmpeg /usr/bin/
COPY --from=docker.io/mwader/static-ffmpeg:latest /ffprobe /usr/bin/

# Copy mvtools and dependencies
COPY --from=build-mvtools /lib64/libfftw3q_threads.so /lib64/
COPY --from=build-mvtools /lib64/libfftw3q_omp.so /lib64/
COPY --from=build-mvtools /lib64/libfftw3q.so /lib64/
COPY --from=build-mvtools /lib64/libfftw3l_threads.so /lib64/
COPY --from=build-mvtools /lib64/libfftw3l_omp.so /lib64/
COPY --from=build-mvtools /lib64/libfftw3l.so /lib64/
COPY --from=build-mvtools /lib64/libfftw3f_threads.so /lib64/
COPY --from=build-mvtools /lib64/libfftw3f_omp.so /lib64/
COPY --from=build-mvtools /lib64/libfftw3f.so /lib64/
COPY --from=build-mvtools /lib64/libvapoursynth-script.so /lib64/
COPY --from=build-mvtools /lib64/libvapoursynth.so /lib64/
COPY --from=build-mvtools /usr/local/lib64/libmvtools.so /usr/local/lib64/

# Copy mpv configs
COPY --chown=$UID:0 --chmod=775 video/mpv-config /etc/mpv
COPY --chown=$UID:0 --chmod=775 --from=uosc-unpacker /uosc /etc/mpv
COPY --chown=$UID:0 --chmod=775 video/thumbfast/thumbfast.conf /etc/mpv/scripts-opts
COPY --chown=$UID:0 --chmod=775 video/thumbfast/thumbfast.lua /etc/mpv/scripts
ADD --chown=$UID:0 --chmod=775 https://github.com/mpv-player/mpv/raw/refs/heads/master/TOOLS/lua/autoload.lua /etc/mpv/scripts/autoload.lua

# RUN mount cache for multi-arch: https://github.com/docker/buildx/issues/549#issuecomment-1788297892
ARG TARGETARCH
ARG TARGETVARIANT

# Make sure the cache is refreshed
ARG RELEASE
RUN --mount=type=cache,id=dnf-$TARGETARCH$TARGETVARIANT,sharing=locked,target=/var/cache/dnf \
    dnf -y install \
    # Install mpv and vapoursynth
    mpv python3-vapoursynth vapoursynth-tools \
    # Install yt-dlp
    yt-dlp

# Copy desktop files
COPY --chown=$UID:0 --chmod=775 video/icons /usr/share/icons
COPY --chown=$UID:0 --chmod=775 video/desktop /usr/share/applications

ARG VERSION
LABEL version=${VERSION} \
    release=${RELEASE} \
    io.k8s.display-name="toolbx-video"
