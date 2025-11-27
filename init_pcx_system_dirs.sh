#!/usr/bin/env bash
set -euo pipefail

if [[ "$EUID" -ne 0 ]]; then
  echo "[ERROR] Please run this script as root: sudo $0"
  exit 1
fi

APP_USER="pervasivecx"
APP_GROUP="pervasivecx"

APP_BASE="/opt/pervasivecx"
RUNTIME_BASE="/pervasiveCX_mnt"

echo "[INFO] Creating pervasiveCX system user and directories..."

if ! id -u "${APP_USER}" >/dev/null 2>&1; then
  echo "[INFO] Creating system user '${APP_USER}'..."
  useradd --system --create-home --home-dir "${RUNTIME_BASE}" --shell /usr/sbin/nologin "${APP_USER}"
else
  echo "[INFO] User '${APP_USER}' already exists, skipping."
fi

echo "[INFO] Creating application base directory at ${APP_BASE}..."
mkdir -p "${APP_BASE}"
chown -R "${APP_USER}:${APP_GROUP}" "${APP_BASE}"

echo "[INFO] Creating runtime directory structure under ${RUNTIME_BASE}..."

mkdir -p "${RUNTIME_BASE}/config"
mkdir -p "${RUNTIME_BASE}/logs/core"
mkdir -p "${RUNTIME_BASE}/logs/db"
mkdir -p "${RUNTIME_BASE}/logs/web"
mkdir -p "${RUNTIME_BASE}/logs/metrics"
mkdir -p "${RUNTIME_BASE}/logs/security"
mkdir -p "${RUNTIME_BASE}/logs/audit"
mkdir -p "${RUNTIME_BASE}/logs/startup"
mkdir -p "${RUNTIME_BASE}/logs/jvm"

mkdir -p "${RUNTIME_BASE}/data/reports"
mkdir -p "${RUNTIME_BASE}/data/snapshots"
mkdir -p "${RUNTIME_BASE}/data/temp"

mkdir -p "${RUNTIME_BASE}/runtime/pid"
mkdir -p "${RUNTIME_BASE}/runtime/tmp"

mkdir -p "${RUNTIME_BASE}/backups/config"
mkdir -p "${RUNTIME_BASE}/backups/db"

touch "${RUNTIME_BASE}/config/app.env"

chown -R "${APP_USER}:${APP_GROUP}" "${RUNTIME_BASE}"

echo "[INFO] Runtime directory structure created."
