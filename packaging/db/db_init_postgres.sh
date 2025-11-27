#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

DB_NAME="${DB_NAME:-pervasivecx}"
DB_USER="${DB_USER:-pervasivecx}"
DB_PASS="${DB_PASS:-Pcx@123!}"

SCHEMA_FILE="${PROJECT_ROOT}/packaging/db/schema_v1.sql"
SEED_FILE="${PROJECT_ROOT}/packaging/db/seed_ui_v1.sql"

if [[ "$EUID" -ne 0 ]]; then
  echo "[ERROR] Please run this script as root: sudo $0"
  exit 1
fi

echo "[INFO] Creating PostgreSQL role if needed..."

# 1) Create role if it does not exist (this CAN be done in a DO block)
sudo -u postgres psql -v ON_ERROR_STOP=1 <<EOF
DO \$\$
BEGIN
   IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = '${DB_USER}') THEN
      RAISE NOTICE 'Creating role ${DB_USER}';
      CREATE ROLE ${DB_USER} LOGIN PASSWORD '${DB_PASS}';
   ELSE
      RAISE NOTICE 'Role ${DB_USER} already exists, skipping.';
   END IF;
END\$\$;
EOF

echo "[INFO] Ensuring database ${DB_NAME} exists..."

# 2) Check if database exists; if not, create it OUTSIDE of DO block
DB_EXISTS=$(sudo -u postgres psql -tAc "SELECT 1 FROM pg_database WHERE datname = '${DB_NAME}'" || echo "")

if [[ "$DB_EXISTS" != "1" ]]; then
  echo "[INFO] Creating database ${DB_NAME} owned by ${DB_USER}..."
  sudo -u postgres createdb -O "${DB_USER}" "${DB_NAME}"
else
  echo "[INFO] Database ${DB_NAME} already exists, skipping creation."
fi

echo "[INFO] Applying schema from ${SCHEMA_FILE}..."
sudo -u postgres psql -v ON_ERROR_STOP=1 -d "${DB_NAME}" -f "${SCHEMA_FILE}"

echo "[INFO] Applying UI seed from ${SEED_FILE}..."
sudo -u postgres psql -v ON_ERROR_STOP=1 -d "${DB_NAME}" -f "${SEED_FILE}"

echo "[INFO] Database initialization complete. DB=${DB_NAME}, USER=${DB_USER}"

