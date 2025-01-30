# syntax=docker/dockerfile:1
ARG UID=1000
ARG VERSION=EDGE
ARG RELEASE=0
ARG BASE_VERSION=quay.io/jim60105/toolbx:latest
ARG RUSTROVER_VERSION=2024.3.4

########################################
# Base stage
########################################
FROM ${BASE_VERSION} AS base

########################################
# Download stage
########################################
FROM base AS download

WORKDIR /rustrover

# Install RustRover
ARG RUSTROVER_VERSION
ADD https://download-cdn.jetbrains.com/rustrover/RustRover-${RUSTROVER_VERSION}.tar.gz /tmp/rustrover.tar.gz
RUN tar -xzf /tmp/rustrover.tar.gz -C /rustrover && \
    rm -f /tmp/rustrover.tar.gz && \
    mv /rustrover/RustRover-${RUSTROVER_VERSION}/* /rustrover

########################################
# Final stage
########################################
FROM base AS final
ARG UID

# Copy RustRover
COPY --chown=$UID:0 --chmod=775 --from=download /rustrover /usr/local/bin/rustrover

# Copy desktop files
COPY --chown=$UID:0 --chmod=775 --from=download /rustrover/bin/rustrover.svg /usr/share/icons/
COPY --chown=$UID:0 --chmod=775 rustrover/desktop /usr/share/applications

# Copy toolbox runner
COPY --chown=$UID:0 --chmod=775 rustrover/runner /copy-to-host

ENV PATH="/usr/local/bin/rustrover/bin:${PATH}"

ARG VERSION
ARG RELEASE
LABEL version=${VERSION} \
    release=${RELEASE} \
    io.k8s.display-name="toolbx-rustrover"
