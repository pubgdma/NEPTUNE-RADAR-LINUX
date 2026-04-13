#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SERVER_PATH="$SCRIPT_DIR/neptune-direct-server.js"
CONFIG_PATH="$SCRIPT_DIR/config/config.toml"
SERVER_PORT="7823"

if [[ -f "$CONFIG_PATH" ]]; then
  port_value="$(grep -E '^[[:space:]]*port[[:space:]]*=' "$CONFIG_PATH" | head -n 1 | sed -E 's/^[^0-9]*([0-9]+).*$/\1/' || true)"
  if [[ -n "${port_value:-}" ]]; then
    SERVER_PORT="$port_value"
  fi
fi

pkill -f "$SERVER_PATH" 2>/dev/null || true

if command -v lsof >/dev/null 2>&1; then
  old_pids="$(lsof -t -iTCP:"$SERVER_PORT" -sTCP:LISTEN 2>/dev/null | sort -u || true)"
  if [[ -n "${old_pids:-}" ]]; then
    kill -9 $old_pids 2>/dev/null || true
  fi
fi

echo "Radar stopped."
