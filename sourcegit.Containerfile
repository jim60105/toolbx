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
# Final stage
########################################
FROM base AS final
ARG UID

# Make sure the cache is refreshed
ARG RELEASE

# RUN mount cache for multi-arch: https://github.com/docker/buildx/issues/549#issuecomment-1788297892
ARG TARGETARCH
ARG TARGETVARIANT

# Install sourcegit
RUN --mount=type=cache,id=dnf-$TARGETARCH$TARGETVARIANT,sharing=locked,target=/var/cache/dnf \
    curl https://codeberg.org/api/packages/yataro/rpm.repo | sed -e 's/gpgcheck=1/gpgcheck=0/' > sourcegit.repo && \
    dnf config-manager addrepo --from-repofile=./sourcegit.repo && \
    dnf -y install sourcegit

# Copy desktop file
COPY --chown=$UID:0 --chmod=775 sourcegit/icons /usr/share/icons
COPY --chown=$UID:0 --chmod=775 sourcegit/desktop /usr/share/applications

# Copy toolbox runner
COPY --chown=$UID:0 --chmod=775 sourcegit/runner /copy-to-host

ARG VERSION
ARG RELEASE
LABEL version=${VERSION} \
    release=${RELEASE} \
    io.k8s.display-name="toolbx-sourcegit"
