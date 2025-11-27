#!/usr/bin/env bash
set -euo pipefail

# Default app.env location (can be overridden via PCX_ENV_FILE if ever needed)
PCX_ENV_FILE="${PCX_ENV_FILE:-/pervasiveCX_mnt/config/app.env}"

# Load app.env if present
if [[ -f "$PCX_ENV_FILE" ]]; then
  # shellcheck disable=SC1090
  . "$PCX_ENV_FILE"
fi

# Load DB env; all scripts must call this before using psql/pg_dump.
pcx_load_db_env() {
  DB_NAME="${PCX_DB_NAME:?PCX_DB_NAME not set in app.env}"
  DB_USER="${PCX_DB_USER:?PCX_DB_USER not set in app.env}"
  DB_PASS="${PCX_DB_PASS-}"   # optional
  DB_HOST="${PCX_DB_HOST:?PCX_DB_HOST not set in app.env}"
  DB_PORT="${PCX_DB_PORT:-5432}"

  if [[ -n "$DB_PASS" ]]; then
    export PGPASSWORD="$DB_PASS"
  else
    unset PGPASSWORD || true
  fi
}
