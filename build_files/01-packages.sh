#!/usr/bin/env bash
set -ouex pipefail

# Speed up DNF and reduce downloads
mkdir -p /etc/dnf
cat >/etc/dnf/dnf.conf <<'EOF'
[main]
gpgcheck=1
install_weak_deps=False
fastestmirror=True
max_parallel_downloads=10
metadata_expire=48h
keepcache=True
# Optional: avoid downloading package docs to save time/space (can affect manpages)
# tsflags=nodocs
EOF

# Package selection (documented)
packages=(
  # Browser (Chromium-based)
  chromium

  # Core IPC and desktop session helpers
  dbus-daemon
  network-manager-applet

  # Locale support
  glibc-langpack-en
  glibc-langpack-nl

  # Display/login manager and GNOME desktop
  gdm
  gnome-shell
  gnome-session
  gnome-control-center
  gnome-terminal
  nautilus
  gnome-settings-daemon

  # Fonts
  dejavu-sans-mono-fonts

  # Power management
  power-profiles-daemon

  # GVFS backends
  gvfs
  gvfs-afc
  gvfs-mtp
  gvfs-smb

  # Dconf tooling (for system-wide defaults)
  dconf

  # Bootable containers tooling
  bootc
)

echo "Installing packages..."
dnf5 install -y --setopt=install_weak_deps=False "${packages[@]}"

# Remove Firefox (included in base)
echo "Removing Firefox..."
dnf5 remove -y firefox firefox-langpacks
