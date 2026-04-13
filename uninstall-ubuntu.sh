#!/usr/bin/env bash
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "Run this script with sudo."
  exit 1
fi

systemctl stop neptune-radar 2>/dev/null || true
systemctl disable neptune-radar 2>/dev/null || true
rm -f /etc/systemd/system/neptune-radar.service
systemctl daemon-reload

echo "neptune-radar.service removed."
