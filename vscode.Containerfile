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

# Install VSCode
RUN --mount=type=cache,id=dnf-$TARGETARCH$TARGETVARIANT,sharing=locked,target=/var/cache/dnf \
    rpm --import https://packages.microsoft.com/keys/microsoft.asc && \
    echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | tee /etc/yum.repos.d/vscode.repo > /dev/null && \
    dnf -y install code code-insiders

# Icons from https://github.com/dhanishgajjar/vscode-icons
COPY --chown=$UID:0 --chmod=775 vscode/icons /usr/share/icons

# Copy toolbox runner
COPY --chown=$UID:0 --chmod=775 vscode/runner /copy-to-host

# Set git editor
ENV GIT_EDITOR="code --wait"

ARG VERSION
ARG RELEASE
LABEL version=${VERSION} \
    release=${RELEASE} \
    io.k8s.display-name="toolbx-vscode"
