#!/usr/bin/env bash
set -oue pipefail

# Configure system-wide GNOME defaults via dconf
# This sets the window button layout for all users (new and existing unless overridden).

# Ensure dconf profiles exist so the system database is consulted
install -d -m 0755 /etc/dconf/db/local.d
install -d -m 0755 /etc/dconf/profile

cat >/etc/dconf/profile/user <<'EOF'
user-db:user
system-db:local
EOF

# Set dconf defaults
cat >/etc/dconf/db/local.d/00-schoolbx <<'EOF'
[org/gnome/desktop/wm/preferences]
button-layout='appmenu:minimize,maximize,close'

[org/gnome/nautilus/list-view]
use-tree-view=true
default-zoom-level='small'

[org/gnome/nautilus/icon-view]
default-zoom-level='standard'
EOF

# Apply changes to the dconf databases
if command -v dconf >/dev/null 2>&1; then
  dconf update
else
  echo "warning: dconf not found; skipping dconf update (defaults will apply after package installs)" >&2
fi

echo "GNOME defaults configured: org.gnome.desktop.wm.preferences button-layout"
