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

# 1) Prepare target layout under /pervasiveCX_mnt
mkdir -p \
  "${STAGE_DIR}/pervasiveCX_mnt/bin" \
  "${STAGE_DIR}/pervasiveCX_mnt/lib" \
  "${STAGE_DIR}/pervasiveCX_mnt/db" \
  "${STAGE_DIR}/pervasiveCX_mnt/web" \
  "${STAGE_DIR}/pervasiveCX_mnt/logs/core" \
  "${STAGE_DIR}/pervasiveCX_mnt/logs/web" \
  "${STAGE_DIR}/pervasiveCX_mnt/logs/db" \
  "${STAGE_DIR}/pervasiveCX_mnt/logs/audit" \
  "${STAGE_DIR}/pervasiveCX_mnt/config" \
  "${STAGE_DIR}/pervasiveCX_mnt/reports" \
  "${STAGE_DIR}/pervasiveCX_mnt/backups/db"

# 2) Copy scripts from REPO layout (pervasiveCX_mnt/bin), NOT from /opt
if [[ -f "${ROOT_DIR}/pervasiveCX_mnt/bin/pcx-app" ]]; then
  cp "${ROOT_DIR}/pervasiveCX_mnt/bin/pcx-app" "${STAGE_DIR}/pervasiveCX_mnt/bin/"
fi
if [[ -f "${ROOT_DIR}/pervasiveCX_mnt/bin/pcx-db-init" ]]; then
  cp "${ROOT_DIR}/pervasiveCX_mnt/bin/pcx-db-init" "${STAGE_DIR}/pervasiveCX_mnt/bin/"
fi
if [[ -f "${ROOT_DIR}/pervasiveCX_mnt/bin/pcx-collector" ]]; then
  cp "${ROOT_DIR}/pervasiveCX_mnt/bin/pcx-collector" "${STAGE_DIR}/pervasiveCX_mnt/bin/"
fi

# 3) Shared lib (still from runtime if you don't have it in repo yet)
if [[ -f /opt/pervasivecx/current/lib/pcx-common.sh ]]; then
  mkdir -p "${STAGE_DIR}/pervasiveCX_mnt/lib"
  cp /opt/pervasivecx/current/lib/pcx-common.sh "${STAGE_DIR}/pervasiveCX_mnt/lib/"
fi

# 4) Schema from repo (not from runtime)
cp "${ROOT_DIR}/packaging/db/schema.sql" "${STAGE_DIR}/pervasiveCX_mnt/db/schema.sql"

# 5) Web UI from your integration machine's /pervasiveCX_mnt/web
if [[ -d /pervasiveCX_mnt/web ]]; then
  cp -a /pervasiveCX_mnt/web/. "${STAGE_DIR}/pervasiveCX_mnt/web/"
fi

# 6) Systemd unit from repo template (not from /etc)
mkdir -p "${STAGE_DIR}/etc/systemd/system"
cp "${ROOT_DIR}/packaging/linux/pervasivecx.service" \
   "${STAGE_DIR}/etc/systemd/system/pervasivecx.service"

# 7) Create tarball
mkdir -p "${ROOT_DIR}/build"
echo "[INFO] Creating tarball ${TARBALL}"
rm -f "${TARBALL}"
tar -C "${STAGE_DIR}" -czf "${TARBALL}" .

echo "[INFO] Build artifacts ready: ${TARBALL}"
