#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="${HOME}/pervasivecx"

echo "[INFO] Creating project workspace at: ${PROJECT_ROOT}"

mkdir -p "${PROJECT_ROOT}/backend"
mkdir -p "${PROJECT_ROOT}/collector"
mkdir -p "${PROJECT_ROOT}/web"

mkdir -p "${PROJECT_ROOT}/packaging/linux/resources/systemd"
mkdir -p "${PROJECT_ROOT}/packaging/linux/resources/logrotate"
mkdir -p "${PROJECT_ROOT}/packaging/linux/resources/config-defaults"
mkdir -p "${PROJECT_ROOT}/packaging/linux/resources/debian"
mkdir -p "${PROJECT_ROOT}/packaging/linux/resources/rpm"

mkdir -p "${PROJECT_ROOT}/build"
mkdir -p "${PROJECT_ROOT}/dist"

echo "[INFO] Project workspace structure created."
