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
FOCUS_RPM="/ctx/features/focus-mode/local_rpms/focus-app-0.0.0-1.fc43.x86_64.rpm"
if [[ ! -f "$FOCUS_RPM" ]]; then
    echo "Missing focus RPM at $FOCUS_RPM" >&2
    exit 1
fi
dnf5 install -y "$FOCUS_RPM"

echo "Focus mode: Updating icon cache..."
gtk-update-icon-cache /usr/share/icons/hicolor

echo "Focus mode: Setting permissions..."
chmod +x /usr/bin/start-focus
