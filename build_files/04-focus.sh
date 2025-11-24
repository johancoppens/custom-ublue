#!/usr/bin/env bash
set -oue pipefail

# This script configures "Focus Mode", enabling users to switch from a standard session
# to a restricted Cage session. In Focus Mode, only a single application runs,
# creating a sandboxed, distraction-free environment for student tasks.

echo "Focus mode: Installing packages..."

packages=(
    # cage is a Wayland kiosk where we can run a single application
    "cage"
)

dnf5 install -y --setopt=install_weak_deps=False "${packages[@]}"

echo "Focus mode: Installing focus-app RPM..."
RPM_DIR="/ctx/local_rpms"
FOCUS_RPM=$(find "$RPM_DIR" -maxdepth 1 -type f -name 'focus-app-*.rpm' | sort | tail -n 1)
if [[ -z "${FOCUS_RPM:-}" ]]; then
    echo "No focus-app RPM found in $RPM_DIR" >&2
    exit 1
fi
dnf5 install -y "$FOCUS_RPM"

echo "Focus mode: User creation..."
# Create user focus without password
useradd -m -s /bin/bash focus && \
    passwd -d focus


echo "Focus mode: Updating icon cache..."
gtk-update-icon-cache /usr/share/icons/hicolor

echo "Focus mode: Setting permissions..."
chmod +x /usr/bin/start-focus
