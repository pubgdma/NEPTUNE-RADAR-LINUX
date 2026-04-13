#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_PATH="$SCRIPT_DIR/config/config.toml"
SERVER_PATH="$SCRIPT_DIR/neptune-direct-server.js"
RUNTIME_DIR="$SCRIPT_DIR/runtime"

if ! command -v node >/dev/null 2>&1; then
  echo "Node.js is not installed."
  echo "Run ./install-ubuntu.sh or install Node.js 24+ manually."
  exit 1
fi

if [[ ! -f "$SERVER_PATH" ]]; then
  echo "Radar server file not found:"
  echo "$SERVER_PATH"
  exit 1
fi

SERVER_IP="127.0.0.1"
SERVER_PORT="7823"
BROWSER_IP="127.0.0.1"

if [[ -f "$CONFIG_PATH" ]]; then
  ip_value="$(grep -E '^[[:space:]]*ip[[:space:]]*=' "$CONFIG_PATH" | head -n 1 | sed -E 's/^[^"]*"([^"]+)".*$/\1/' || true)"
  port_value="$(grep -E '^[[:space:]]*port[[:space:]]*=' "$CONFIG_PATH" | head -n 1 | sed -E 's/^[^0-9]*([0-9]+).*$/\1/' || true)"
  if [[ -n "${ip_value:-}" && "$ip_value" != "$CONFIG_PATH" ]]; then
    SERVER_IP="$ip_value"
  fi
  if [[ -n "${port_value:-}" ]]; then
    SERVER_PORT="$port_value"
  fi
fi

if [[ "$SERVER_IP" != "0.0.0.0" && "$SERVER_IP" != "::" ]]; then
  BROWSER_IP="$SERVER_IP"
fi

mkdir -p "$RUNTIME_DIR"

if command -v lsof >/dev/null 2>&1; then
  old_pids="$(lsof -t -iTCP:"$SERVER_PORT" -sTCP:LISTEN 2>/dev/null | sort -u || true)"
  if [[ -n "${old_pids:-}" ]]; then
    kill -9 $old_pids 2>/dev/null || true
  fi
fi

pkill -f "$SERVER_PATH" 2>/dev/null || true

export NEPTUNE_RADAR_ROOT="$SCRIPT_DIR"
export NEPTUNE_RADAR_IP="$SERVER_IP"
export NEPTUNE_RADAR_PORT="$SERVER_PORT"

echo
echo "Neptune Radar is starting..."
echo "IP: $BROWSER_IP"
echo "Port: $SERVER_PORT"
echo
echo "Under Web Radar Config, enter the following IP and Port, then press Connect Web Radar:"
echo "IP: $BROWSER_IP"
echo "Port: $SERVER_PORT"
echo "Open your browser and go to: http://$BROWSER_IP:$SERVER_PORT"
echo "Keep this window open while using the radar."
echo

while true; do
  if node "$SERVER_PATH"; then
    exit_code=0
  else
    exit_code=$?
  fi

  echo
  echo "Radar server stopped."
  echo "Exit code: $exit_code"
  echo "Restarting radar server in 2 seconds. Press Ctrl+C to stop."
  sleep 2
done
