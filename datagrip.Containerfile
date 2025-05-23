# syntax=docker/dockerfile:1
ARG UID=1000
ARG VERSION=EDGE
ARG RELEASE=0
ARG BASE_IMAGE=quay.io/jim60105/toolbx:latest
ARG DATAGRIP_VERSION=2025.1.2

########################################
# Base stage
########################################
FROM ${BASE_IMAGE} AS base

########################################
# Download stage
########################################
FROM base AS download

WORKDIR /datagrip

# Install DataGrip
ARG DATAGRIP_VERSION
ADD https://download-cdn.jetbrains.com/datagrip/datagrip-${DATAGRIP_VERSION}.tar.gz /tmp/datagrip.tar.gz
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
