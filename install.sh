#!/usr/bin/env bash
# install.sh — Install WatchDog on Debian/Ubuntu or RHEL/CentOS
#
# Expected layout (place all files alongside this script before running):
#   ./watchdog          pre-built release binary  (cargo build --release)
#   ./dist/             pre-built React frontend  (npm run build → frontend/dist/)
#   ./config.json       default configuration
#   ./watchdog.service  systemd unit file
#
# Usage: sudo ./install.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

BINARY="${SCRIPT_DIR}/watchdog"
FRONTEND_DIST="${SCRIPT_DIR}/dist"
CONFIG_SRC="${SCRIPT_DIR}/config.json"
SERVICE_SRC="${SCRIPT_DIR}/watchdog.service"

INSTALL_BIN="/usr/local/bin/watchdog"
CONFIG_DIR="/etc/watchdog"
STATIC_DIR="/var/www/watchdog"
LOG_DIR="/var/log/watchdog"

# ── root check ────────────────────────────────────────────────────────────────
if [[ $EUID -ne 0 ]]; then
  echo "Please run as root (sudo ./install.sh)"
  exit 1
fi

# ── pre-flight: confirm all build artefacts are present ───────────────────────
missing=0
for f in "${BINARY}" "${CONFIG_SRC}" "${SERVICE_SRC}"; do
  if [[ ! -f "$f" ]]; then
    echo "ERROR: required file not found: $f"
    missing=1
  fi
done
if [[ ! -d "${FRONTEND_DIST}" ]]; then
  echo "ERROR: frontend dist directory not found: ${FRONTEND_DIST}"
  missing=1
fi
if [[ $missing -ne 0 ]]; then
  echo ""
  echo "Build artefacts are missing.  On your dev machine run:"
  echo "  cargo build --release && cp target/release/watchdog ."
  echo "  cd frontend && npm run build && cp -r dist ../dist && cd .."
  echo "Then re-run this installer."
  exit 1
fi

# ── step 1: binary ────────────────────────────────────────────────────────────
echo "[1/5] Installing binary to ${INSTALL_BIN}..."
install -m 755 "${BINARY}" "${INSTALL_BIN}"

# ── step 2: frontend assets ───────────────────────────────────────────────────
echo "[2/5] Installing frontend assets to ${STATIC_DIR}..."
mkdir -p "${STATIC_DIR}"
cp -r "${FRONTEND_DIST}/." "${STATIC_DIR}/"

# ── step 3: configuration ─────────────────────────────────────────────────────
echo "[3/5] Installing configuration..."
mkdir -p "${CONFIG_DIR}"
if [[ ! -f "${CONFIG_DIR}/config.json" ]]; then
  install -m 640 "${CONFIG_SRC}" "${CONFIG_DIR}/config.json"
  # Point static_dir at the system install path
  sed -i "s|\"static_dir\":.*|\"static_dir\": \"${STATIC_DIR}\"|" "${CONFIG_DIR}/config.json"
  echo "       Config installed to ${CONFIG_DIR}/config.json"
  echo "       *** Edit the config and update credentials + SMTP before use ***"
else
  echo "       Config already exists at ${CONFIG_DIR}/config.json — skipping"
fi

# ── step 4: log directory ─────────────────────────────────────────────────────
echo "[4/5] Creating log directory..."
mkdir -p "${LOG_DIR}"
chmod 750 "${LOG_DIR}"

# ── step 5: systemd service ───────────────────────────────────────────────────
echo "[5/5] Installing and enabling systemd service..."
install -m 644 "${SERVICE_SRC}" /etc/systemd/system/watchdog.service
systemctl daemon-reload
systemctl enable watchdog
systemctl restart watchdog

echo ""
echo "WatchDog installed and running."
echo "  Dashboard : http://127.0.0.1:8081  (change bind in ${CONFIG_DIR}/config.json)"
echo "  Config    : ${CONFIG_DIR}/config.json"
echo "  Status    : systemctl status watchdog"
echo "  Logs      : journalctl -u watchdog -f"
echo "  Events    : tail -f ${LOG_DIR}/watchdog-\$(date +%Y-%m-%d).log"
