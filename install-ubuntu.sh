#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SERVICE_PATH="/etc/systemd/system/neptune-radar.service"
TEMPLATE_PATH="$SCRIPT_DIR/neptune-radar.service.template"
INSTALL_DIR="${INSTALL_DIR:-/opt/neptune-radar}"

if [[ $EUID -ne 0 ]]; then
  echo "Run this script with sudo."
  exit 1
fi

apt-get update
apt-get install -y ca-certificates curl gnupg lsof

if ! command -v node >/dev/null 2>&1; then
  mkdir -p /etc/apt/keyrings
  if [[ ! -f /etc/apt/keyrings/nodesource.gpg ]]; then
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
  fi
  echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_24.x nodistro main" > /etc/apt/sources.list.d/nodesource.list
  apt-get update
  apt-get install -y nodejs
fi

chmod +x "$SCRIPT_DIR/start-radar.sh" "$SCRIPT_DIR/stop-radar.sh" "$SCRIPT_DIR/update-radar.sh"

mkdir -p "$INSTALL_DIR"

if [[ "$SCRIPT_DIR" != "$INSTALL_DIR" ]]; then
  rm -rf "$INSTALL_DIR"
  mkdir -p "$INSTALL_DIR"
  cp -a "$SCRIPT_DIR"/. "$INSTALL_DIR"/
fi

chmod +x "$INSTALL_DIR/start-radar.sh" "$INSTALL_DIR/stop-radar.sh" "$INSTALL_DIR/update-radar.sh"

sed "s|__APP_DIR__|$INSTALL_DIR|g" "$TEMPLATE_PATH" > "$SERVICE_PATH"
systemctl daemon-reload
systemctl enable neptune-radar.service
systemctl restart neptune-radar.service

sleep 2

echo
echo "Service status:"
systemctl --no-pager --full status neptune-radar.service || true
echo
echo "Local health check:"
curl -fsS "http://127.0.0.1:7823/healthz" || true

echo
echo "Ubuntu prerequisites installed."
echo "Systemd service created: neptune-radar.service"
echo "Install directory: $INSTALL_DIR"
echo
echo "Start service:"
echo "  sudo systemctl start neptune-radar"
echo
echo "Stop service:"
echo "  sudo systemctl stop neptune-radar"
echo
echo "Service logs:"
echo "  journalctl -u neptune-radar -f"
echo
echo "Open in browser:"
echo "  http://YOUR_VPS_IP:7823"
