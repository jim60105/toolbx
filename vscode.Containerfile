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
# Azure Functions Core Tools unpack stage
########################################

FROM base AS azure-functions-core-tools-unpacker

WORKDIR /azure-functions-core-tools

RUN --mount=source=rider/download-azure-functions-core-tools.sh,target=/download-azure-functions-core-tools.sh,z \
    . /download-azure-functions-core-tools.sh

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

# Tauri Prerequisites
# https://v2.tauri.app/start/prerequisites/#linux
RUN --mount=type=cache,id=dnf-$TARGETARCH$TARGETVARIANT,sharing=locked,target=/var/cache/dnf \
    dnf -y install webkit2gtk4.1-devel \
    openssl-devel \
    curl \
    wget \
    file \
    libappindicator-gtk3-devel \
    librsvg2-devel \
    @c-development

# Install Azurite
RUN --mount=type=cache,id=pnpm-$TARGETARCH$TARGETVARIANT,sharing=locked,target=/pnpm/store \
    pnpm install -g azurite@3

# Copy Azure Functions Core Tools
COPY --chown=$UID:0 --chmod=775 --from=azure-functions-core-tools-unpacker /azure-functions-core-tools /usr/local/bin/azure-functions-core-tools

# Install vscode repository
RUN --mount=type=cache,id=dnf-$TARGETARCH$TARGETVARIANT,sharing=locked,target=/var/cache/dnf \
    rpm --import https://packages.microsoft.com/keys/microsoft.asc && \
    echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | tee /etc/yum.repos.d/vscode.repo > /dev/null

# Install VSCode
RUN --mount=type=cache,id=dnf-$TARGETARCH$TARGETVARIANT,sharing=locked,target=/var/cache/dnf \
    dnf -y install code

# Install VSCode Insiders
RUN --mount=type=cache,id=dnf-$TARGETARCH$TARGETVARIANT,sharing=locked,target=/var/cache/dnf \
    dnf -y install code-insiders

# Icons from https://github.com/dhanishgajjar/vscode-icons
COPY --chown=$UID:0 --chmod=775 vscode/icons /usr/share/icons

# Copy desktop files
COPY --chown=$UID:0 --chmod=775 vscode/desktop /usr/share/applications

# Copy toolbox runner
COPY --chown=$UID:0 --chmod=775 vscode/runner /copy-to-host

# Set git editor
ENV GIT_EDITOR="code --wait"

ARG VERSION
ARG RELEASE
LABEL version=${VERSION} \
    release=${RELEASE} \
    io.k8s.display-name="toolbx-vscode"
