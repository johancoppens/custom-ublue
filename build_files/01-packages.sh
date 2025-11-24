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
    "ansible-core"
    "git"
    # "dconf"
    # "bootc"
    "plymouth-plugin-script"
    "libreoffice"
    "libreoffice-langpack-nl"
    # "fleetctl"  # Added fleet-osquery package
    # "cage"
)


echo "Installing packages..."
dnf5 install -y --setopt=install_weak_deps=False "${packages[@]}"



# Remove Firefox (included in base)
echo "Removing Firefox..."
dnf5 remove -y firefox firefox-langpacks

dnf5 clean all 

# Installeer de community.general collectie (voor flatpak support)
# We installeren dit system-wide (-p /usr/share/ansible/collections)
ansible-galaxy collection install community.general -p /usr/share/ansible/collections



