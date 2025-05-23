# syntax=docker/dockerfile:1
ARG UID=1000
ARG VERSION=EDGE
ARG RELEASE=0
ARG BASE_IMAGE=quay.io/jim60105/toolbx:latest

########################################
# Base stage
########################################
FROM ${BASE_IMAGE} AS base

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
########################################

FROM base AS uosc-unpacker

WORKDIR /uosc

ADD https://github.com/tomasklaen/uosc/releases/latest/download/uosc.zip /tmp/uosc.zip

RUN unzip /tmp/uosc.zip -d /uosc

########################################
# Anime4K unpack stage
########################################

FROM base AS anime4k-unpacker

WORKDIR /anime4K

RUN curl -o /tmp/assets.json https://api.github.com/repos/bloc97/Anime4K/releases/latest && \
    cat /tmp/assets.json \
    | jq '.assets[0].browser_download_url' \
    | xargs -I {} curl -L -o /tmp/anime4K.zip {} && \
    unzip /tmp/anime4K.zip -d /anime4K

########################################
# Final stage
########################################
FROM base AS final
ARG UID

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
COPY --chown=$UID:0 --chmod=775 --from=anime4k-unpacker /anime4K /etc/mpv/shaders

# Copy toolbox runners
COPY --chown=$UID:0 --chmod=775 video/runner /copy-to-host

# RUN mount cache for multi-arch: https://github.com/docker/buildx/issues/549#issuecomment-1788297892
ARG TARGETARCH
ARG TARGETVARIANT

# Make sure the cache is refreshed
ARG RELEASE

# Install ffmpeg
COPY --from=docker.io/mwader/static-ffmpeg:7.1.1 /ffmpeg /usr/bin/
COPY --from=docker.io/mwader/static-ffmpeg:7.1.1 /ffprobe /usr/bin/

# Install yt-dlp
ADD --chown=$UID:0 --chmod=775 https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp /usr/bin/yt-dlp

RUN --mount=type=cache,id=dnf-$TARGETARCH$TARGETVARIANT,sharing=locked,target=/var/cache/dnf \
    dnf -y install \
    # Install mpv and vapoursynth
    mpv python3-vapoursynth vapoursynth-tools \
    # Install OBS
    obs-studio \
    # Install ImageMagick
    # Why ImageMagick-heic: https://discussion.fedoraproject.org/t/imagemagick-heic-avif-disappeared-after-updates/144279/5
    ImageMagick ImageMagick-heic \
    # Install exiftool
    exiftool

# Verify installation
RUN mpv --version && \
    yt-dlp --version && \
    magick -version && \
    exiftool -ver

# Copy desktop files
RUN cp /usr/share/icons/hicolor/scalable/apps/com.obsproject.Studio.svg /usr/share/icons/obs.svg
RUN cp /usr/share/icons/hicolor/scalable/apps/mpv.svg /usr/share/icons/mpv.svg
COPY --chown=$UID:0 --chmod=775 video/desktop /usr/share/applications

ARG VERSION
LABEL version=${VERSION} \
    release=${RELEASE} \
    io.k8s.display-name="toolbx-video"
