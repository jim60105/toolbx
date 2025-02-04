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
# oc unpack stage
########################################
FROM base AS oc-unpacker

WORKDIR /unpacker

# https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/latest/
ADD https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/latest/openshift-client-linux.tar.gz /tmp/openshift-client-linux.tar.gz

RUN tar -xzf /tmp/openshift-client-linux.tar.gz

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

# Install kubectl
# https://kubernetes.io/zh-cn/docs/tasks/tools/install-kubectl-linux/#install-using-native-package-management
COPY <<EOF /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.32/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.32/rpm/repodata/repomd.xml.key
EOF
RUN --mount=type=cache,id=dnf-$TARGETARCH$TARGETVARIANT,sharing=locked,target=/var/cache/dnf \
    dnf -y install \
    kubectl \
    helm

# Install OpenLens
RUN --mount=type=cache,id=dnf-$TARGETARCH$TARGETVARIANT,sharing=locked,target=/var/cache/dnf \
    --mount=type=tmpfs,target=/tmp \
    curl -L https://github.com/MuhammedKalkan/OpenLens/releases/download/v6.5.2-366/OpenLens-6.5.2-366.x86_64.rpm -o /tmp/OpenLens.rpm && \
    dnf -y install /tmp/OpenLens.rpm

# Install talosctl
# https://www.talos.dev/v1.9/talos-guides/install/talosctl/
RUN curl -sL https://talos.dev/install | sh

# Install oc
COPY --from=oc-unpacker /unpacker/oc /usr/bin

# Verify installation
RUN kubectl version --client && \
    oc version --client && \
    helm version && \
    talosctl version || true

# Copy desktop file
COPY --chown=$UID:0 --chmod=775 kubernetes/icons /usr/share/icons
COPY --chown=$UID:0 --chmod=775 kubernetes/desktop /usr/share/applications

# Copy toolbox runner
COPY --chown=$UID:0 --chmod=775 kubernetes/runner /copy-to-host

ARG VERSION
ARG RELEASE
LABEL version=${VERSION} \
    release=${RELEASE} \
    io.k8s.display-name="toolbx-kubernetes"
