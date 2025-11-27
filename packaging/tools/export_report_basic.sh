#!/usr/bin/env bash
set -euo pipefail

DB_NAME="${PCX_DB_NAME:-pervasivecx}"
BASE_DIR="/pervasiveCX_mnt/reports"
STAMP="$(date +%Y%m%d_%H%M%S)"
OUT_DIR="${1:-${BASE_DIR}/report_${STAMP}}"

# Create base & report directory
sudo mkdir -p "$BASE_DIR"
sudo mkdir -p "$OUT_DIR"

echo "[INFO] Generating basic report into $OUT_DIR"

# While generating, make postgres the owner so \COPY can write files
sudo chown postgres:postgres "$OUT_DIR"
sudo chmod 770 "$OUT_DIR"

# 1) Servers summary
sudo -u postgres psql -d "$DB_NAME" -c "\
\\COPY ( \
  SELECT id, code, hostname, environment, os_name, os_version, cpu_cores, ram_mb, created_at, updated_at \
  FROM server \
  ORDER BY code \
) TO '${OUT_DIR}/servers.csv' CSV HEADER;"

# 2) Latest capture sessions
sudo -u postgres psql -d "$DB_NAME" -c "\
\\COPY ( \
  SELECT id, started_at, ended_at, status, trigger_type, triggered_by, notes \
  FROM capture_session \
  ORDER BY started_at DESC \
  LIMIT 200 \
) TO '${OUT_DIR}/capture_sessions.csv' CSV HEADER;"

# 3) Volumes (joined with server) – WITHOUT captured_at for now
sudo -u postgres psql -d "$DB_NAME" -c "\
\\COPY ( \
  SELECT s.code AS server_code, v.mount_point, v.filesystem_type, \
         v.total_gb, v.used_gb, v.available_gb, v.usage_percent \
  FROM server_volume v \
  JOIN server s ON s.id = v.server_id \
  ORDER BY s.code, v.mount_point \
) TO '${OUT_DIR}/volumes.csv' CSV HEADER;"

# 4) Simple HTML index for convenience
sudo bash -c "cat > '${OUT_DIR}/index.html'" <<HTML
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <title>pervasiveCX Report (${STAMP})</title>
  <style>
    body { font-family: system-ui, sans-serif; background:#020617; color:#e5e7eb; padding:20px; }
    h1 { font-size:1.4rem; margin-bottom:0.2rem; }
    h2 { font-size:1rem; margin-top:1.4rem; }
    a { color:#60a5fa; text-decoration:none; }
    a:hover { text-decoration:underline; }
    .pill { display:inline-block; padding:3px 8px; border-radius:999px;
            background:#111827; border:1px solid #1f2937; font-size:0.75rem; margin-left:6px; }
    ul { line-height:1.6; }
  </style>
</head>
<body>
  <h1>pervasiveCX – System Report</h1>
  <div class="pill">Generated ${STAMP}</div>

  <h2>Data Sheets</h2>
  <ul>
    <li><a href="servers.csv">servers.csv</a> – Server inventory (hostname, OS, CPU, RAM)</li>
    <li><a href="capture_sessions.csv">capture_sessions.csv</a> – Recent capture runs</li>
    <li><a href="volumes.csv">volumes.csv</a> – Disk usage per server & mount point</li>
  </ul>

  <p>Open these CSV files in Excel/Sheets and combine them into one workbook for your final colorful report.</p>
</body>
</html>
HTML

# After generation, hand ownership to pervasivecx so app/user can read & download easily
sudo chown -R pervasivecx:pervasivecx "$OUT_DIR"

echo "[INFO] Report generated: $OUT_DIR"
