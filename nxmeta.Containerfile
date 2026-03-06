# syntax=docker/dockerfile:1
ARG UID=1000
ARG VERSION=EDGE
ARG RELEASE=0
ARG BASE_IMAGE=quay.io/toolbx/ubuntu-toolbox:22.04

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

# Install Nx Meta VMS Client
RUN --mount=type=cache,id=apt-$TARGETARCH$TARGETVARIANT,sharing=locked,target=/var/cache/apt \
    --mount=type=cache,id=aptlists-$TARGETARCH$TARGETVARIANT,sharing=locked,target=/var/lib/apt/lists \
    --mount=type=bind,from=download,source=/download/nxmeta-client.deb,target=/tmp/nxmeta-client.deb \
    apt-get update && \
    apt-get install -y --no-install-recommends /tmp/nxmeta-client.deb

# Create stable symlink for the client binary
RUN ln -s /opt/networkoptix-metavms/client/*/bin/client /usr/local/bin/nxmeta-client

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
