#!/usr/bin/env bash
set -euo pipefail

REPO_OWNER="${REPO_OWNER:-pubgdma}"
REPO_NAME="${REPO_NAME:-NEPTUNE-RADAR-LINUX}"
REPO_REF="${REPO_REF:-main}"
INSTALL_DIR="${INSTALL_DIR:-/opt/neptune-radar}"
TMP_DIR="$(mktemp -d)"
ARCHIVE_URL="https://github.com/${REPO_OWNER}/${REPO_NAME}/archive/refs/heads/${REPO_REF}.tar.gz"

cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

if [[ $EUID -ne 0 ]]; then
  echo "Run this installer with sudo."
  exit 1
fi

apt-get update
apt-get install -y ca-certificates curl tar gzip gnupg lsof

echo "Downloading ${ARCHIVE_URL}"
curl -fsSL "$ARCHIVE_URL" -o "$TMP_DIR/package.tar.gz"

tar -xzf "$TMP_DIR/package.tar.gz" -C "$TMP_DIR"

EXTRACTED_DIR="$(find "$TMP_DIR" -mindepth 1 -maxdepth 1 -type d | head -n 1)"
LINUX_DIR=""

if [[ -d "$EXTRACTED_DIR/NeptuneRadar2-LINUX" ]]; then
  LINUX_DIR="$EXTRACTED_DIR/NeptuneRadar2-LINUX"
elif [[ -f "$EXTRACTED_DIR/install-ubuntu.sh" && -f "$EXTRACTED_DIR/start-radar.sh" ]]; then
  LINUX_DIR="$EXTRACTED_DIR"
else
  echo "Linux installer content not found in the downloaded archive."
  exit 1
fi

chmod +x "$LINUX_DIR/install-ubuntu.sh" "$LINUX_DIR/start-radar.sh" "$LINUX_DIR/stop-radar.sh" "$LINUX_DIR/uninstall-ubuntu.sh" "$LINUX_DIR/update-radar.sh"

cd "$LINUX_DIR"
INSTALL_DIR="$INSTALL_DIR" ./install-ubuntu.sh

echo
echo "Installation completed."
echo "Radar is installed to: $INSTALL_DIR"
echo "Service name: neptune-radar"
echo "Local health check:"
curl -fsS "http://127.0.0.1:7823/healthz" || true
echo
echo "Open in browser: http://YOUR_VPS_IP:7823"
