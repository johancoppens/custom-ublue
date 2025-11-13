#!/usr/bin/env bash
set -oue pipefail

# Remove default wallpapers and keep only custom coolbx set
shopt -s extglob
rm -f /usr/share/gnome-background-properties/!(coolbx).xml

# Compile GSettings schemas and overrides
if command -v glib-compile-schemas >/dev/null 2>&1; then
  glib-compile-schemas /usr/share/glib-2.0/schemas
fi


