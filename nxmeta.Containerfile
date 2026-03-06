# syntax=docker/dockerfile:1
ARG UID=1000
ARG VERSION=EDGE
ARG RELEASE=0
ARG BASE_IMAGE=quay.io/toolbx/ubuntu-toolbox:24.04

########################################
# Base stage
########################################
FROM ${BASE_IMAGE} AS base

########################################
# Download stage
########################################
FROM base AS download

WORKDIR /download

# RUN mount cache for multi-arch: https://github.com/docker/buildx/issues/549#issuecomment-1788297892
ARG TARGETARCH
ARG TARGETVARIANT

RUN --mount=type=cache,id=apt-$TARGETARCH$TARGETVARIANT,sharing=locked,target=/var/cache/apt \
    --mount=type=cache,id=aptlists-$TARGETARCH$TARGETVARIANT,sharing=locked,target=/var/lib/apt/lists \
    apt-get update && apt-get install -y --no-install-recommends curl jq && \
    FULL_VERSION=$(curl -s https://updates.networkoptix.com/metavms/releases.json | jq -r '[.releases[] | select(.product == "vms" and .publication_type == "release")] | first | .version') && \
    BUILD_NUMBER=$(echo "$FULL_VERSION" | rev | cut -d. -f1 | rev) && \
    echo "Nx Meta version: ${FULL_VERSION}, build number: ${BUILD_NUMBER}" && \
    curl -L -o /download/nxmeta-client.deb "https://updates.networkoptix.com/metavms/${BUILD_NUMBER}/linux/metavms-client-${FULL_VERSION}-linux_x64.deb"

########################################
# Final stage
########################################
FROM base AS final
ARG UID

# Make sure the cache is refreshed
ARG RELEASE

# RUN mount cache for multi-arch: https://github.com/docker/buildx/issues/549#issuecomment-1788297892
ARG TARGETARCH
ARG TARGETVARIANT

# Install Nx Meta VMS Client and runtime dependencies
RUN --mount=type=cache,id=apt-$TARGETARCH$TARGETVARIANT,sharing=locked,target=/var/cache/apt \
    --mount=type=cache,id=aptlists-$TARGETARCH$TARGETVARIANT,sharing=locked,target=/var/lib/apt/lists \
    --mount=type=bind,from=download,source=/download/nxmeta-client.deb,target=/tmp/nxmeta-client.deb \
    apt-get update && \
    apt-get install -y --no-install-recommends /tmp/nxmeta-client.deb \
    libxdamage1 libvulkan1 mesa-vulkan-drivers

# Create wrapper script for the client binary
# A symlink would cause the client's dirname-based path resolution to break,
# so we use a wrapper that exec's the actual binary with the correct $0 path
# Disable GPU for Qt WebEngine (Chromium) to prevent SharedImage/EGL crashes in containers
COPY --chmod=775 <<"EOF" /usr/local/bin/nxmeta-client
#!/bin/bash
export QTWEBENGINE_CHROMIUM_FLAGS="--disable-gpu ${QTWEBENGINE_CHROMIUM_FLAGS}"
exec /opt/networkoptix-metavms/client/*/bin/client "$@"
EOF

# Copy icon
RUN cp /usr/share/icons/hicolor/scalable/apps/vmsclient-metavms.png /usr/share/icons/nxmeta.png

# Copy desktop files
COPY --chown=$UID:0 --chmod=775 nxmeta/desktop /usr/share/applications

# Copy toolbox runner
COPY --chown=$UID:0 --chmod=775 nxmeta/runner /copy-to-host

ARG VERSION
ARG RELEASE
LABEL version=${VERSION} \
    release=${RELEASE} \
    io.k8s.display-name="toolbx-nxmeta"
