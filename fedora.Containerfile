# syntax=docker/dockerfile:1
ARG UID=1000
ARG VERSION=EDGE
ARG RELEASE=0

########################################
# Install stage
########################################
FROM registry.fedoraproject.org/fedora-toolbox:41 AS base

# Create directories with correct permissions
ARG UID
RUN install -d -m 775 -o $UID -g 0 /licenses

# Copy licenses (OpenShift Policy)
COPY --chown=$UID:0 --chmod=775 LICENSE /licenses/Containerfile.LICENSE

RUN cat <<-"EOF" > /usr/local/bin/host-runner
#!/bin/bash
executable="$(basename ${0})"
exec flatpak-spawn --host "${executable}" "${@}"
EOF

# Setup host-runner script and symlinks
RUN chmod 775 /usr/local/bin/host-runner && \
    bins=( \
    "flatpak" \
    "podman" \
    "docker" \
    "rpm-ostree" \
    "systemctl" \
    "xdg-open" \
    "kitty" \
    ); \
    for f in "${bins[@]}"; do \
        ln -s host-runner /usr/local/bin/$f;\
    done

########################################
# Install stage
########################################
FROM base AS install

# Make sure the cache is refreshed
ARG RELEASE

# RUN mount cache for multi-arch: https://github.com/docker/buildx/issues/549#issuecomment-1788297892
ARG TARGETARCH
ARG TARGETVARIANT

# Set dnf config
RUN cat <<-"EOF" > /etc/dnf/dnf.conf
install_weak_deps=False
tsflags=nodocs
EOF

RUN --mount=type=cache,id=dnf-$TARGETARCH$TARGETVARIANT,sharing=locked,target=/var/cache/dnf \
    dnf -y upgrade && \
    # Install os keyring
    # Following this guide to setup os keyring to use gnome-libsecret: https://code.visualstudio.com/docs/editor/settings-sync#_recommended-configure-the-keyring-to-use-with-vs-code
    dnf -y install seahorse && \
    # Install VSCode
    rpm --import https://packages.microsoft.com/keys/microsoft.asc && \
    echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | tee /etc/yum.repos.d/vscode.repo > /dev/null && \
    dnf -y install code && \
    # Install .NET
    dnf -y install dotnet-sdk-8.0 && \
    # Install git-credential-manager
    dotnet tool install -g git-credential-manager && \
    /root/.dotnet/tools/git-credential-manager configure && \
    # Install sourcegit
    wget -O /tmp/sourcegit.rpm https://github.com/sourcegit-scm/sourcegit/releases/download/v8.42/sourcegit-8.42-1.x86_64.rpm && \
    dnf -y install /tmp/sourcegit.rpm && \
    rm -f /tmp/sourcegit.rpm && \
    # Fonts
    dnf -y install google-noto-sans-cjk-fonts

########################################
# Final stage
########################################
FROM install AS final

ENV GCM_CREDENTIAL_STORE=gpg

ARG VERSION
ARG RELEASE
LABEL name="jim60105/toolbx" \
    # Authors for toolbox
    vendor="containertoolbx" \
    # Maintainer for this container image
    maintainer="jim60105" \
    # Containerfile source repository
    url="https://github.com/jim60105/toolbx" \
    version=${VERSION} \
    # This should be a number, incremented with each change
    release=${RELEASE} \
    io.k8s.display-name="toolbx"
    # summary="" \
    # description=""