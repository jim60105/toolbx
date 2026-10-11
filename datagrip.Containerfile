# syntax=docker/dockerfile:1
ARG UID=1000
ARG VERSION=EDGE
ARG RELEASE=0
ARG BASE_IMAGE=quay.io/jim60105/toolbx:latest
ARG DATAGRIP_VERSION=2025.3.5

########################################
# Base stage
########################################
FROM ${BASE_IMAGE} AS base

# RUN mount cache for multi-arch: https://github.com/docker/buildx/issues/549#issuecomment-1788297892
ARG TARGETARCH
ARG TARGETVARIANT

# Install Java 25
RUN --mount=type=cache,id=dnf-$TARGETARCH$TARGETVARIANT,sharing=locked,target=/var/cache/dnf \
    dnf -y install java-25-openjdk

########################################
# Download stage
########################################
FROM base AS download

WORKDIR /datagrip

# Install DataGrip
ARG DATAGRIP_VERSION
ADD https://download.jetbrains.com/datagrip/datagrip-${DATAGRIP_VERSION}.tar.gz /tmp/datagrip.tar.gz
RUN tar -xzf /tmp/datagrip.tar.gz -C /datagrip && \
    rm -f /tmp/datagrip.tar.gz && \
    mv /datagrip/"DataGrip-${DATAGRIP_VERSION}"/* /datagrip

########################################
# Final stage
########################################
FROM base AS final
ARG UID

# Copy DataGrip
COPY --chown=$UID:0 --chmod=775 --from=download /datagrip /usr/local/bin/datagrip

# Copy desktop files
COPY --chown=$UID:0 --chmod=775 --from=download /datagrip/bin/datagrip.svg /usr/share/icons/
COPY --chown=$UID:0 --chmod=775 datagrip/desktop /usr/share/applications

# Copy toolbox runner
COPY --chown=$UID:0 --chmod=775 datagrip/runner /copy-to-host

ENV PATH="/usr/local/bin/datagrip/bin:${PATH}"

ARG VERSION
ARG RELEASE
LABEL version=${VERSION} \
    release=${RELEASE} \
    io.k8s.display-name="toolbx-datagrip"
