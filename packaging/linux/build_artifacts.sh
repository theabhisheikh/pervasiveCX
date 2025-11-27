#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <version>" >&2
  exit 1
fi

VERSION="$1"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

STAGE_DIR="${ROOT_DIR}/build/artifacts"
TARBALL="${ROOT_DIR}/build/pervasivecx-${VERSION}.tar.gz"

echo "[INFO] Staging artifacts in ${STAGE_DIR}"
rm -rf "${STAGE_DIR}"
mkdir -p "${STAGE_DIR}"

# 1) /opt/pervasivecx/current
mkdir -p "${STAGE_DIR}/opt/pervasivecx"
if [[ -d /opt/pervasivecx/current ]]; then
  cp -a /opt/pervasivecx/current "${STAGE_DIR}/opt/pervasivecx/current"
else
  echo "[ERROR] /opt/pervasivecx/current not found on this machine." >&2
  exit 1
fi

# 2) /pervasiveCX_mnt structure
mkdir -p \
  "${STAGE_DIR}/pervasiveCX_mnt/web" \
  "${STAGE_DIR}/pervasiveCX_mnt/logs/core" \
  "${STAGE_DIR}/pervasiveCX_mnt/logs/web" \
  "${STAGE_DIR}/pervasiveCX_mnt/logs/db" \
  "${STAGE_DIR}/pervasiveCX_mnt/logs/audit" \
  "${STAGE_DIR}/pervasiveCX_mnt/config" \
  "${STAGE_DIR}/pervasiveCX_mnt/reports" \
  "${STAGE_DIR}/pervasiveCX_mnt/backups/db"

if [[ -d /pervasiveCX_mnt/web ]]; then
  cp -a /pervasiveCX_mnt/web/. "${STAGE_DIR}/pervasiveCX_mnt/web/"
fi

# 3) Single systemd unit
mkdir -p "${STAGE_DIR}/etc/systemd/system"
if [[ -f /etc/systemd/system/pervasivecx.service ]]; then
  cp /etc/systemd/system/pervasivecx.service "${STAGE_DIR}/etc/systemd/system/pervasivecx.service"
else
  echo "[WARN] /etc/systemd/system/pervasivecx.service not found, skipping."
fi

# 4) Optional logrotate & cron (if you already use them)
mkdir -p "${STAGE_DIR}/etc/logrotate.d" "${STAGE_DIR}/etc/cron.d"

if [[ -f /etc/logrotate.d/pervasivecx ]]; then
  cp /etc/logrotate.d/pervasivecx "${STAGE_DIR}/etc/logrotate.d/pervasivecx"
fi

if [[ -f /etc/cron.d/pervasivecx-backup ]]; then
  cp /etc/cron.d/pervasivecx-backup "${STAGE_DIR}/etc/cron.d/pervasivecx-backup"
fi

# 5) No pcxctl anymore

# ---- Create tarball ----
mkdir -p "${ROOT_DIR}/build"
echo "[INFO] Creating tarball ${TARBALL}"
rm -f "${TARBALL}"
tar -C "${STAGE_DIR}" -czf "${TARBALL}" .

echo "[INFO] Build artifacts ready: ${TARBALL}"
