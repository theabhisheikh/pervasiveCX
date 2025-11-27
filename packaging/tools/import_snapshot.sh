#!/usr/bin/env bash
set -euo pipefail

DB_NAME="${PCX_DB_NAME:-pervasivecx}"
SNAPSHOT_FILE="${1:-}"

if [[ -z "$SNAPSHOT_FILE" || ! -f "$SNAPSHOT_FILE" ]]; then
  echo "Usage: $0 <snapshot.sql>"
  exit 1
fi

echo "[INFO] Importing snapshot ${SNAPSHOT_FILE} into DB=${DB_NAME}"
sudo -u postgres psql -d "$DB_NAME" -f "$SNAPSHOT_FILE"
echo "[INFO] Snapshot import complete."
