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

# Install Lens
# https://docs.k8slens.dev/getting-started/install-lens/#install-lens-desktop-from-the-rpm-repository
RUN --mount=type=cache,id=dnf-$TARGETARCH$TARGETVARIANT,sharing=locked,target=/var/cache/dnf \
    dnf config-manager addrepo --from-repofile=https://downloads.k8slens.dev/rpm/lens.repo && \
    dnf -y install lens

# Install talosctl
# https://www.talos.dev/v1.9/talos-guides/install/talosctl/
RUN curl -sL https://talos.dev/install | sh

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
