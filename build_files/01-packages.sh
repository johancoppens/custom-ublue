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
    "chromium"
    "dbus-daemon"
    "network-manager-applet"
    "glibc-langpack-en"
    "glibc-langpack-nl"
    "gdm"
    "gnome-shell"
    "gnome-session"
    "gnome-control-center"
    "gnome-terminal"
    "nautilus"
    "gnome-settings-daemon"
    "dejavu-sans-mono-fonts"
    "power-profiles-daemon"
    "gvfs"
    "gvfs-afc"
    "gvfs-mtp"
    "gvfs-smb"
    "dconf"
    "bootc"
    "plymouth-plugin-script"
    "libreoffice"
    "libreoffice-langpack-nl"
)

echo "Installing packages..."
dnf5 install -y --setopt=install_weak_deps=False "${packages[@]}"

echo "Installing local RPMs..."
dnf5 install -y /rpms/fleetd.rpm

# Remove Firefox (included in base)
echo "Removing Firefox..."
dnf5 remove -y firefox firefox-langpacks
