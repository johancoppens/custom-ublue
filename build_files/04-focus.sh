#!/usr/bin/env bash
set -oue pipefail

# This script configures "Focus Mode", enabling users to switch from a standard session
# to a restricted Cage session. In Focus Mode, only a single application runs,
# creating a sandboxed, distraction-free environment for student tasks.

echo "Focus mode: Installing packages..."

packages=(
    # cage is a Wayland kiosk where we can run a single application
    "cage"
    "gnome-text-editor"
)

dnf5 install -y --setopt=install_weak_deps=False "${packages[@]}"

echo "Focus mode: User creation..."
# Create user focus without password
useradd -m -s /bin/bash focus && \
    passwd -d focus


echo "Focus mode: Updating icon cache..."
gtk-update-icon-cache /usr/share/icons/hicolor

echo "Focus mode: Setting permissions..."
chmod +x /usr/bin/start-focus
