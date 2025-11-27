#!/usr/bin/env bash
set -euo pipefail

DB_NAME="${PCX_DB_NAME:-pervasivecx}"
TARGET="${1:-/pervasiveCX_mnt/web/ui-metadata.json}"

if [[ "$EUID" -ne 0 ]]; then
  echo "[ERROR] Please run this script as root: sudo $0"
  exit 1
fi

echo "[INFO] Exporting UI metadata from database ${DB_NAME} to ${TARGET}..."

mkdir -p "$(dirname "$TARGET")"

sudo -u postgres psql -d "${DB_NAME}" -t -A <<'SQL' > "${TARGET}"
SELECT coalesce(json_agg(tab_obj), '[]'::json) FROM (
  SELECT
    t.code,
    t.title,
    t.icon,
    t.sort_order,
    t.is_default,
    (
      SELECT coalesce(json_agg(sec_obj), '[]'::json) FROM (
        SELECT
          s.code,
          s.title,
          s.subtitle,
          s.sort_order,
          (
            SELECT coalesce(json_agg(w_obj), '[]'::json) FROM (
              SELECT
                w.code,
                w.title,
                w.widget_type,
                w.sort_order,
                w.config
              FROM ui_widget w
              WHERE w.section_id = s.id AND w.is_enabled = true
              ORDER BY w.sort_order, w.id
            ) AS w_obj
          ) AS widgets
        FROM ui_section s
        WHERE s.tab_id = t.id AND s.is_enabled = true
        ORDER BY s.sort_order, s.id
      ) AS sec_obj
    ) AS sections
  FROM ui_tab t
  WHERE t.is_enabled = true
  ORDER BY t.sort_order, t.id
) AS tab_obj;
SQL

chown pervasivecx:pervasivecx "${TARGET}"

echo "[INFO] UI metadata exported successfully."
