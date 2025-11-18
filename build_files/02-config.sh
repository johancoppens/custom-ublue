#!/usr/bin/env bash
set -ouex pipefail

# Enable services
systemctl enable podman.socket || true

# First-boot user toggle (only if explicitly enabled)
if [[ "${ENABLE_FIRSTBOOT_USER:-1}" == "1" ]]; then
  mkdir -p /etc/schoolbx
  touch /etc/schoolbx/enable-firstboot-user

  echo "Enabling firstboot user creation"
  systemctl enable schoolbx-firstboot-user.service

  echo "Setting locale and keyboard for testing"
  echo "LANG=nl_BE.UTF-8" > /etc/locale.conf
  echo "KEYMAP=be" > /etc/vconsole.conf
  mkdir -p /etc/X11/xorg.conf.d
  cat > /etc/X11/xorg.conf.d/00-keyboard.conf <<EOF
Section "InputClass"
        Identifier "system-keyboard"
        MatchIsKeyboard "on"
        Option "XkbLayout" "be"
EndSection
EOF
fi

# Ensure first-boot script is executable and service is enabled
chmod 0755 /usr/libexec/schoolbx-firstboot-user.sh || true

mkdir -p /usr/lib/systemd/system/multi-user.target.wants
ln -sf /usr/lib/systemd/system/schoolbx-firstboot-user.service \
  /usr/lib/systemd/system/multi-user.target.wants/schoolbx-firstboot-user.service || true

mkdir -p /usr/lib/systemd/user/timers.target.wants
ln -sf /usr/lib/systemd/user/ansible-pull.timer \
  /usr/lib/systemd/user/timers.target.wants/ansible-pull.timer

