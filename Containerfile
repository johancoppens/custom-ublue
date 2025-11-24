# Allow build scripts to be referenced without being copied into the final image
# - FROM scratch: "scratch" is a special, minimal image that is completely empty.
#   It's used here as a clean, temporary holding area for your build files.
# - AS ctx: This gives the stage a name ("ctx") so it can be referenced later.
FROM scratch AS ctx
COPY build_files /
COPY features /features

# Base Image
# FROM ghcr.io/ublue-os/bazzite:stable
# FROM quay.io/fedora/fedora-silverblue:43
FROM ghcr.io/ublue-os/base-main:43

# Image metadata
ARG SHA_HEAD_SHORT=local
ARG IMAGE_VERSION=latest
ARG ENABLE_FIRSTBOOT_USER=1
LABEL \
    org.opencontainers.image.title="coolbx OS" \
    org.opencontainers.image.description="Fedora bootable container image with GNOME and Chromium" \
    org.opencontainers.image.vendor="coolbx" \
    org.opencontainers.image.licenses="MIT" \
    org.opencontainers.image.version="${IMAGE_VERSION}" \
    org.opencontainers.image.revision="${SHA_HEAD_SHORT}" \
    containers.bootc="1"

## Other possible base images include:
# FROM ghcr.io/ublue-os/bazzite:latest
# FROM ghcr.io/ublue-os/bluefin-nvidia:stable
# 
# ... and so on, here are more base images
# Universal Blue Images: https://github.com/orgs/ublue-os/packages
# Fedora base image: quay.io/fedora/fedora-bootc:41
# CentOS base images: quay.io/centos-bootc/centos-bootc:stream10

### MODIFICATIONS
## Make your image changes in the build scripts under build_files/:
##  - 01-packages.sh: heavy, cacheable package installs and repos
##  - 02-config.sh:   lightweight enablement, flags, and post-config
##  - 03-gnome-dconf.sh: GNOME defaults (dconf), system-wide tweaks

# Include system files (tmpfiles.d, presets, drop-ins, etc.)
# 1) Install packages in a separate, cacheable layer
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /usr/bin/bash /ctx/01-packages.sh

# 2) Copy system files after the heavy install step so package layer stays cached on tweaks
COPY system_files /

# 3) Do lightweight config post-step (enable units, first-boot flag, perms)
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    ENABLE_FIRSTBOOT_USER=${ENABLE_FIRSTBOOT_USER} /usr/bin/bash /ctx/02-config.sh

# 4) GNOME defaults via dconf (system-wide)
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /usr/bin/bash /ctx/03-gnome-dconf.sh

# 5) Optional Focus Mode feature (comment this block out to disable)
COPY features/focus-mode/system_files/ /
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /usr/bin/bash /ctx/features/focus-mode/install.sh
    
    
### LINTING
## Verify final image and contents are correct.
RUN bootc container lint
