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
# Download stage
########################################
FROM base AS download

WORKDIR /rustrover

# Install RustRover
ADD https://download-cdn.jetbrains.com/rustrover/RustRover-2024.3.1.tar.gz /tmp/rustrover.tar.gz
RUN tar -xzf /tmp/rustrover.tar.gz -C /rustrover

########################################
# Final stage
########################################
FROM base AS final
ARG UID

# Copy RustRover
COPY --chown=$UID:0 --chmod=775 --from=download /rustrover /usr/local/bin

ARG VERSION
ARG RELEASE
LABEL version=${VERSION} \
    release=${RELEASE} \
    io.k8s.display-name="toolbx-rustrover"
