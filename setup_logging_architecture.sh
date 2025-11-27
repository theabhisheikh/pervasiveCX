#!/usr/bin/env bash
set -euo pipefail

if [[ "$EUID" -ne 0 ]]; then
  echo "[ERROR] Please run this script as root: sudo $0"
  exit 1
fi

APP_USER="pervasivecx"
APP_GROUP="pervasivecx"
LOG_BASE="/pervasiveCX_mnt/logs"

echo "[INFO] Creating logging directory structure under ${LOG_BASE}..."

# Core server logs
mkdir -p "${LOG_BASE}/core"
touch "${LOG_BASE}/core/pervasiveCX-server.log"
touch "${LOG_BASE}/core/pervasiveCX-server-err.log"
touch "${LOG_BASE}/core/pervasiveCX-server-fatal.log"
touch "${LOG_BASE}/core/pervasiveCX-server-framework.log"
touch "${LOG_BASE}/core/pervasiveCX-server-command.log"
touch "${LOG_BASE}/core/pervasiveCX-server-config.log"
touch "${LOG_BASE}/core/pervasiveCX-server-websocket-err.log"
touch "${LOG_BASE}/core/pervasiveCX-server-stats.log"

# DB logs
mkdir -p "${LOG_BASE}/db"
touch "${LOG_BASE}/db/db-metrics.log"
touch "${LOG_BASE}/db/db-session-usage-controller.log"
touch "${LOG_BASE}/db/querystats.log"

# Web / UI logs
mkdir -p "${LOG_BASE}/web"
touch "${LOG_BASE}/web/pervasiveCX-web.log"
touch "${LOG_BASE}/web/gwt-client.log"
mkdir -p "${LOG_BASE}/web/tomcat"
touch "${LOG_BASE}/web/tomcat/tomcat_access.log"
touch "${LOG_BASE}/web/tomcat/tomcat-metrics.log"

# Metrics / performance logs
mkdir -p "${LOG_BASE}/metrics"
touch "${LOG_BASE}/metrics/metric.log"
touch "${LOG_BASE}/metrics/pervasiveCX-server-stats.log"

# Security logs
mkdir -p "${LOG_BASE}/security"
touch "${LOG_BASE}/security/security-filter.log"
touch "${LOG_BASE}/security/auth.log"
touch "${LOG_BASE}/security/permission-violations.log"

# Audit logs
mkdir -p "${LOG_BASE}/audit"
touch "${LOG_BASE}/audit/audit.log"
touch "${LOG_BASE}/audit/pervasiveCX-ai-audit.log"
touch "${LOG_BASE}/audit/export-import.log"

# Startup / shutdown logs
mkdir -p "${LOG_BASE}/startup"
touch "${LOG_BASE}/startup/startup.log"
touch "${LOG_BASE}/startup/shutdown.log"

# JVM / process logs
mkdir -p "${LOG_BASE}/jvm"
touch "${LOG_BASE}/jvm/heap.log"
touch "${LOG_BASE}/jvm/gc.log"
touch "${LOG_BASE}/jvm/thread-dump.log"

# Generic stats/logs (if needed later)
mkdir -p "${LOG_BASE}/access"

# Fix ownership
chown -R "${APP_USER}:${APP_GROUP}" "${LOG_BASE}"

echo "[INFO] Logging directories and placeholder files created under ${LOG_BASE}."
