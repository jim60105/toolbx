# syntax=docker/dockerfile:1
ARG UID=1000
ARG VERSION=EDGE
ARG RELEASE=0
ARG BASE_VERSION=quay.io/jim60105/toolbx:latest
ARG RIDER_VERSION=2024.3.2

########################################
# Base stage
########################################
FROM ${BASE_VERSION} AS base

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

# Copy Rider
COPY --chown=$UID:0 --chmod=775 --from=download /rider /usr/local/bin/rider

# Copy desktop files
COPY --chown=$UID:0 --chmod=775 --from=download /rider/bin/rider.svg /usr/share/icons/
COPY --chown=$UID:0 --chmod=775 rider/desktop /usr/share/applications

ENV PATH="/usr/local/bin/rider/bin:${PATH}"

ARG VERSION
ARG RELEASE
LABEL version=${VERSION} \
    release=${RELEASE} \
    io.k8s.display-name="toolbx-rider"
