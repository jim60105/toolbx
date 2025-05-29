# syntax=docker/dockerfile:1
ARG UID=1000
ARG VERSION=EDGE
ARG RELEASE=0
ARG BASE_IMAGE=quay.io/jim60105/toolbx:latest
ARG RIDER_VERSION=2025.1.2

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
# Download stage
########################################
FROM base AS download

WORKDIR /rider

# Install Rider
ARG RIDER_VERSION
ADD https://download-cdn.jetbrains.com/rider/JetBrains.Rider-${RIDER_VERSION}.tar.gz /tmp/rider.tar.gz
RUN tar -xzf /tmp/rider.tar.gz -C /rider && \
    rm -f /tmp/rider.tar.gz && \
    mv /rider/"JetBrains Rider-${RIDER_VERSION}"/* /rider

########################################
# Final stage
########################################
FROM base AS final
ARG UID

# RUN mount cache for multi-arch: https://github.com/docker/buildx/issues/549#issuecomment-1788297892
ARG TARGETARCH
ARG TARGETVARIANT

# Install Azurite
RUN --mount=type=cache,id=pnpm-$TARGETARCH$TARGETVARIANT,sharing=locked,target=/pnpm/store \
    pnpm install azurite@3

# Copy Azure Functions Core Tools
COPY --chown=$UID:0 --chmod=775 --from=azure-functions-core-tools-unpacker /azure-functions-core-tools /usr/local/bin/azure-functions-core-tools
ENV PATH="/usr/local/bin/azure-functions-core-tools${PATH:+:${PATH}}"

# Copy Rider
COPY --chown=$UID:0 --chmod=775 --from=download /rider /usr/local/bin/rider

# Copy desktop files
COPY --chown=$UID:0 --chmod=775 --from=download /rider/bin/rider.svg /usr/share/icons/
COPY --chown=$UID:0 --chmod=775 rider/desktop /usr/share/applications

# Copy toolbox runner
COPY --chown=$UID:0 --chmod=775 rider/runner /copy-to-host

ENV PATH="/usr/local/bin/rider/bin:/usr/local/bin/azure-functions-core-tools:${PATH}"

ARG VERSION
ARG RELEASE
LABEL version=${VERSION} \
    release=${RELEASE} \
    io.k8s.display-name="toolbx-rider"
