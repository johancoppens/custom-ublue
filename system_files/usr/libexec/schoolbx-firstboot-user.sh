#!/usr/bin/bash
set -euo pipefail

# Create a local test user on first boot for VM login.
# Defaults can be overridden via env SCHOOLBX_TEST_USER / SCHOOLBX_TEST_PASS at build-time
# or by editing this file downstream. For security, change these in production.
USER_NAME="${SCHOOLBX_TEST_USER:-tester}"
USER_PASS="${SCHOOLBX_TEST_PASS:-tester}"
USER_SHELL="/usr/bin/bash"
USER_GROUPS="wheel"

if id -u "$USER_NAME" >/dev/null 2>&1; then
  echo "User $USER_NAME already exists; nothing to do."
  exit 0
fi

# Ensure primary groups exist
getent group "$USER_GROUPS" >/dev/null 2>&1 || groupadd "$USER_GROUPS"

# Create user with home directory and add to supplemental groups
useradd -m -s "$USER_SHELL" -G "$USER_GROUPS" "$USER_NAME"

# Set password
# shellcheck disable=SC2001
printf "%s:%s\n" "$USER_NAME" "$USER_PASS" | chpasswd

echo "Created user $USER_NAME (groups: $USER_GROUPS); password set for testing."

# Mark completion to avoid reruns
mkdir -p /var/lib/schoolbx
touch /var/lib/schoolbx/user-created

exit 0
