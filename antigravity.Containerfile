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
# Final stage
########################################
FROM base AS final
ARG UID

# Make sure the cache is refreshed
ARG RELEASE

# RUN mount cache for multi-arch: https://github.com/docker/buildx/issues/549#issuecomment-1788297892
ARG TARGETARCH
ARG TARGETVARIANT

# Install antigravity repository
COPY <<EOF /etc/yum.repos.d/antigravity.repo
[antigravity-rpm]
name=Antigravity RPM Repository
baseurl=https://us-central1-yum.pkg.dev/projects/antigravity-auto-updater-dev/antigravity-rpm
enabled=1
gpgcheck=0
EOF

# Install antigravity
RUN --mount=type=cache,id=dnf-$TARGETARCH$TARGETVARIANT,sharing=locked,target=/var/cache/dnf \
    dnf -y install antigravity

# Icons
COPY --chown=$UID:0 --chmod=775 antigravity/icons /usr/share/icons

# Copy desktop files
COPY --chown=$UID:0 --chmod=775 antigravity/desktop /usr/share/applications

# Copy toolbox runner
COPY --chown=$UID:0 --chmod=775 antigravity/runner /copy-to-host

ARG VERSION
ARG RELEASE
LABEL version=${VERSION} \
    release=${RELEASE} \
    io.k8s.display-name="toolbx-antigravity"
