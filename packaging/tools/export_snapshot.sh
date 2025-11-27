#!/usr/bin/env bash
set -euo pipefail

DB_NAME="${PCX_DB_NAME:-pervasivecx}"
OUT_DIR="${1:-/pervasiveCX_mnt/export}"
mkdir -p "$OUT_DIR"

STAMP="$(date +%Y%m%d_%H%M%S)"
OUT_FILE="${OUT_DIR}/pervasivecx_snapshot_${STAMP}.sql"

TABLES="
capture_session
server
server_volume
rpm_package
nas_connection
ftp_connection
db_snapshot
license_snapshot
app_module
media_profile
crm_integration
customization
custom_report
campaign
qa_parameter
rule_engine
metric_definition
metric_timeseries
"

echo "[INFO] Exporting data-only snapshot from DB=${DB_NAME} to ${OUT_FILE}"

sudo -u postgres pg_dump -d "$DB_NAME" --data-only \
$(for t in $TABLES; do echo "--table=$t"; done) \
> "$OUT_FILE"

chown pervasivecx:pervasivecx "$OUT_FILE"

echo "[INFO] Snapshot exported: $OUT_FILE"
