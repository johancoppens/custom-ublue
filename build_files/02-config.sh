#!/usr/bin/env bash
set -ouex pipefail

# Enable services
systemctl enable podman.socket || true

# First-boot user toggle (only if explicitly enabled)
if [[ "${ENABLE_FIRSTBOOT_USER:-1}" == "1" ]]; then
  mkdir -p /etc/schoolbx
  touch /etc/schoolbx/enable-firstboot-user
fi

# Ensure first-boot script is executable and service is enabled
chmod 0755 /usr/libexec/schoolbx-firstboot-user.sh || true
mkdir -p /usr/lib/systemd/system/multi-user.target.wants
ln -sf /usr/lib/systemd/system/schoolbx-firstboot-user.service \
  /usr/lib/systemd/system/multi-user.target.wants/schoolbx-firstboot-user.service || true
