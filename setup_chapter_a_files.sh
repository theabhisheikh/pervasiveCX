#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="${HOME}/pervasivecx"
PACKAGING_DIR="${PROJECT_ROOT}/packaging/linux"
RESOURCES_DIR="${PACKAGING_DIR}/resources"

echo "[INFO] Using PROJECT_ROOT=${PROJECT_ROOT}"

mkdir -p "${PACKAGING_DIR}"
mkdir -p "${RESOURCES_DIR}/systemd"
mkdir -p "${RESOURCES_DIR}/logrotate"
mkdir -p "${RESOURCES_DIR}/config-defaults"
mkdir -p "${RESOURCES_DIR}/debian"
mkdir -p "${RESOURCES_DIR}/rpm"

########################################
# 1) build_artifacts.sh
########################################
cat > "${PACKAGING_DIR}/build_artifacts.sh" <<'EOF_BUILD'
#!/usr/bin/env bash
set -euo pipefail

VERSION="${1:-}"
if [[ -z "$VERSION" ]]; then
  echo "Usage: $0 <version>"
  exit 1
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
BUILD_DIR="$ROOT_DIR/build"
STAGE_DIR="$BUILD_DIR/stage/pervasivecx-$VERSION"

rm -rf "$STAGE_DIR"
mkdir -p "$STAGE_DIR"

INSTALL_BASE="$STAGE_DIR/opt/pervasivecx/pervasivecx-$VERSION"
BIN_DIR="$INSTALL_BASE/bin"
LIB_DIR="$INSTALL_BASE/lib"
CONF_DEFAULTS_DIR="$INSTALL_BASE/config-defaults"

mkdir -p "$BIN_DIR" "$LIB_DIR" "$CONF_DEFAULTS_DIR" "$INSTALL_BASE/web"

echo "[INFO] NOTE:"
echo "  This script expects you to have built backend/collector/web already."
echo "  If not, it will stop with a clear message."

# Backend (pcx-core)
CORE_JAR=$(find "$ROOT_DIR/backend" -path "*build/libs/*.jar" -maxdepth 3 2>/dev/null | head -n1 || true)
if [[ -z "$CORE_JAR" ]]; then
  echo "[ERROR] pcx-core jar not found under backend/build/libs. Build backend first."
  exit 1
fi
cp "$CORE_JAR" "$LIB_DIR/pcx-core.jar"

# Collector
COLLECTOR_JAR=$(find "$ROOT_DIR/collector" -path "*build/libs/*.jar" -maxdepth 3 2>/dev/null | head -n1 || true)
if [[ -z "$COLLECTOR_JAR" ]]; then
  echo "[ERROR] pcx-collector jar not found under collector/build/libs. Build collector first."
  exit 1
fi
cp "$COLLECTOR_JAR" "$LIB_DIR/pcx-collector.jar"

# Web build
if [[ -d "$ROOT_DIR/web/dist" ]]; then
  cp -r "$ROOT_DIR/web/dist/." "$INSTALL_BASE/web/"
else
  echo "[WARN] Web build directory web/dist not found. Skipping web assets."
fi

# Launcher scripts
cat > "$BIN_DIR/pcx-core" <<'EOF_LAUNCH_CORE'
#!/usr/bin/env bash
set -euo pipefail
APP_HOME="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
JAVA_CMD=${JAVA_CMD:-java}
CONFIG_DIR=${PCX_CONFIG_DIR:-/pervasiveCX_mnt/config}
PORT=${PCX_CORE_PORT:-9494}
exec "$JAVA_CMD" -jar "$APP_HOME/lib/pcx-core.jar" --server.port="$PORT" --spring.config.location="$CONFIG_DIR/app.yaml"
EOF_LAUNCH_CORE
chmod +x "$BIN_DIR/pcx-core"

cat > "$BIN_DIR/pcx-collector" <<'EOF_LAUNCH_COL"
#!/usr/bin/env bash
set -euo pipefail
APP_HOME="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
JAVA_CMD=${JAVA_CMD:-java}
CONFIG_DIR=${PCX_CONFIG_DIR:-/pervasiveCX_mnt/config}
exec "$JAVA_CMD" -jar "$APP_HOME/lib/pcx-collector.jar" --spring.config.location="$CONFIG_DIR/app.yaml"
EOF_LAUNCH_COL
chmod +x "$BIN_DIR/pcx-collector"

# Default config files copied from packaging resources
if [[ -d "$ROOT_DIR/packaging/linux/resources/config-defaults" ]]; then
  cp "$ROOT_DIR/packaging/linux/resources/config-defaults/"*.yaml "$CONF_DEFAULTS_DIR/" || true
fi

# Systemd, pcxctl, logrotate
mkdir -p "$STAGE_DIR/etc/systemd/system"
mkdir -p "$STAGE_DIR/usr/bin"
mkdir -p "$STAGE_DIR/etc/logrotate.d"

cp "$ROOT_DIR/packaging/linux/resources/systemd/pervasivecx-core.service" \
   "$STAGE_DIR/etc/systemd/system/pervasivecx-core.service"
cp "$ROOT_DIR/packaging/linux/resources/systemd/pervasivecx-collector.service" \
   "$STAGE_DIR/etc/systemd/system/pervasivecx-collector.service"

cp "$ROOT_DIR/packaging/linux/resources/pcxctl" "$STAGE_DIR/usr/bin/pcxctl"
chmod +x "$STAGE_DIR/usr/bin/pcxctl"

cp "$ROOT_DIR/packaging/linux/resources/logrotate/pervasivecx" \
   "$STAGE_DIR/etc/logrotate.d/pervasivecx"

echo "[INFO] Stage completed at: $STAGE_DIR"
EOF_BUILD
chmod +x "${PACKAGING_DIR}/build_artifacts.sh"

########################################
# 2) make_deb.sh
########################################
cat > "${PACKAGING_DIR}/make_deb.sh" <<'EOF_DEB'
#!/usr/bin/env bash
set -euo pipefail

VERSION="${1:-}"
if [[ -z "$VERSION" ]]; then
  echo "Usage: $0 <version>"
  exit 1
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
BUILD_DIR="$ROOT_DIR/build"
STAGE_BASE="$BUILD_DIR/stage/pervasivecx-$VERSION"
DEB_DIR="$BUILD_DIR/deb/pervasivecx-$VERSION"
DIST_DIR="$ROOT_DIR/dist"

if [[ ! -d "$STAGE_BASE" ]]; then
  echo "[ERROR] Stage directory not found: $STAGE_BASE"
  echo "Run build_artifacts.sh first."
  exit 1
fi

rm -rf "$DEB_DIR"
mkdir -p "$DEB_DIR"

cp -a "$STAGE_BASE"/. "$DEB_DIR/"

mkdir -p "$DEB_DIR/DEBIAN"

CONTROL_TEMPLATE="$ROOT_DIR/packaging/linux/resources/debian/control"
sed "s/@VERSION@/$VERSION/g" "$CONTROL_TEMPLATE" > "$DEB_DIR/DEBIAN/control"

for script in postinst prerm postrm; do
  cp "$ROOT_DIR/packaging/linux/resources/debian/$script" "$DEB_DIR/DEBIAN/$script"
  chmod 755 "$DEB_DIR/DEBIAN/$script"
done

mkdir -p "$DIST_DIR"
DEB_FILE="$DIST_DIR/pervasivecx_${VERSION}_amd64.deb"

dpkg-deb --build "$DEB_DIR" "$DEB_FILE"

echo "[INFO] Built debian package: $DEB_FILE"
EOF_DEB
chmod +x "${PACKAGING_DIR}/make_deb.sh"

########################################
# 3) make_rpm.sh
########################################
cat > "${PACKAGING_DIR}/make_rpm.sh" <<'EOF_RPM'
#!/usr/bin/env bash
set -euo pipefail

VERSION="${1:-}"
if [[ -z "$VERSION" ]]; then
  echo "Usage: $0 <version>"
  exit 1
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
BUILD_DIR="$ROOT_DIR/build"
STAGE_BASE="$BUILD_DIR/stage/pervasivecx-$VERSION"
DIST_DIR="$ROOT_DIR/dist"

if [[ ! -d "$STAGE_BASE" ]]; then
  echo "[ERROR] Stage directory not found: $STAGE_BASE"
  echo "Run build_artifacts.sh first."
  exit 1
fi

RPMBUILD_DIR="$BUILD_DIR/rpmbuild"
mkdir -p "$RPMBUILD_DIR"/{BUILD,RPMS,SOURCES,SPECS,SRPMS}

TAR_SOURCE="$RPMBUILD_DIR/SOURCES/pervasivecx-$VERSION.tar.gz"
tar -czf "$TAR_SOURCE" -C "$STAGE_BASE" .

SPEC_TEMPLATE="$ROOT_DIR/packaging/linux/resources/rpm/pervasivecx.spec"
SPEC_FILE="$RPMBUILD_DIR/SPECS/pervasivecx.spec"

cp "$SPEC_TEMPLATE" "$SPEC_FILE"

rpmbuild \
  --define "_topdir $RPMBUILD_DIR" \
  --define "version $VERSION" \
  -bb "$SPEC_FILE"

mkdir -p "$DIST_DIR"
cp "$RPMBUILD_DIR/RPMS/x86_64/"pervasivecx-"$VERSION"-1*.rpm "$DIST_DIR"/

echo "[INFO] Built RPM package(s) in $DIST_DIR"
EOF_RPM
chmod +x "${PACKAGING_DIR}/make_rpm.sh"

########################################
# 4) Systemd unit files
########################################
cat > "${RESOURCES_DIR}/systemd/pervasivecx-core.service" <<'EOF_CORE'
[Unit]
Description=pervasiveCX Core Service
After=network.target

[Service]
Type=simple
User=pervasivecx
Group=pervasivecx
EnvironmentFile=-/pervasiveCX_mnt/config/app.env
ExecStart=/opt/pervasivecx/current/bin/pcx-core
Restart=on-failure
RestartSec=5
WorkingDirectory=/opt/pervasivecx/current
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF_CORE

cat > "${RESOURCES_DIR}/systemd/pervasivecx-collector.service" <<'EOF_COLLECT'
[Unit]
Description=pervasiveCX Collector Service
After=network.target pervasivecx-core.service

[Service]
Type=simple
User=pervasivecx
Group=pervasivecx
EnvironmentFile=-/pervasiveCX_mnt/config/app.env
ExecStart=/opt/pervasivecx/current/bin/pcx-collector
Restart=on-failure
RestartSec=5
WorkingDirectory=/opt/pervasivecx/current

[Install]
WantedBy=multi-user.target
EOF_COLLECT

########################################
# 5) pcxctl CLI
########################################
cat > "${RESOURCES_DIR}/pcxctl" <<'EOF_PCXCTL'
#!/usr/bin/env bash
set -euo pipefail

APP_USER="pervasivecx"
LOG_BASE="/pervasiveCX_mnt/logs"
CORE_SERVICE="pervasivecx-core"
COLLECTOR_SERVICE="pervasivecx-collector"
CORE_PORT="${PCX_CORE_PORT:-9494}"

usage() {
  cat <<EOT
pcxctl - pervasiveCX control tool

Usage:
  pcxctl service <core|collector|all> <start|stop|restart|status>
  pcxctl capture <full|metrics|config>
  pcxctl logs <core|collector|all> [follow]
  pcxctl status

Examples:
  pcxctl service core start
  pcxctl capture full
  pcxctl logs core follow
EOT
  exit 1
}

ensure_systemd() {
  if ! command -v systemctl >/dev/null 2>&1; then
    echo "systemctl not found; systemd is required."
    exit 1
  fi
}

cmd_service() {
  ensure_systemd
  local target="${1:-}"
  local action="${2:-}"
  if [[ -z "$target" || -z "$action" ]]; then usage; fi

  case "$target" in
    core)
      systemctl "$action" "$CORE_SERVICE"
      ;;
    collector)
      systemctl "$action" "$COLLECTOR_SERVICE"
      ;;
    all)
      systemctl "$action" "$CORE_SERVICE"
      systemctl "$action" "$COLLECTOR_SERVICE"
      ;;
    *)
      echo "Unknown service target: $target"
      exit 1
      ;;
  esac
}

cmd_capture() {
  local mode="${1:-full}"
  local endpoint="/api/admin/capture"
  case "$mode" in
    full)      endpoint="$endpoint/full" ;;
    metrics)   endpoint="$endpoint/metrics" ;;
    config)    endpoint="$endpoint/config" ;;
    *) echo "Unknown capture mode: $mode"; exit 1 ;;
  esac

  echo "Triggering capture ($mode)..."
  curl -fsS "http://127.0.0.1:${CORE_PORT}${endpoint}" || {
    echo "Capture request failed."
    exit 1
  }
  echo
}

cmd_logs() {
  local what="${1:-core}"
  local follow="${2:-}"
  local tail_cmd="tail"
  if [[ "$follow" == "follow" ]]; then
    tail_cmd="tail -f"
  fi

  case "$what" in
    core)
      $tail_cmd "$LOG_BASE/core/pervasiveCX-server.log"
      ;;
    collector)
      $tail_cmd "$LOG_BASE/core/pervasiveCX-collector.log"
      ;;
    all)
      $tail_cmd "$LOG_BASE/core/pervasiveCX-server.log" \
                "$LOG_BASE/core/pervasiveCX-collector.log"
      ;;
    *)
      echo "Unknown logs target: $what"
      exit 1
      ;;
  esac
}

cmd_status() {
  ensure_systemd
  echo "== pervasiveCX services =="
  systemctl status "$CORE_SERVICE" --no-pager || true
  echo
  systemctl status "$COLLECTOR_SERVICE" --no-pager || true
}

main() {
  local cmd="${1:-}"
  shift || true

  case "$cmd" in
    service) cmd_service "$@";;
    capture) cmd_capture "$@";;
    logs)    cmd_logs "$@";;
    status)  cmd_status "$@";;
    ""|help|-h|--help) usage;;
    *) echo "Unknown command: $cmd"; usage;;
  esac
}

main "$@"
EOF_PCXCTL
chmod +x "${RESOURCES_DIR}/pcxctl"

########################################
# 6) logrotate config
########################################
cat > "${RESOURCES_DIR}/logrotate/pervasivecx" <<'EOF_LOGR'
/pervasiveCX_mnt/logs/*.log /pervasiveCX_mnt/logs/*/*.log {
    daily
    rotate 30
    compress
    delaycompress
    missingok
    notifempty
    copytruncate
}
EOF_LOGR

########################################
# 7) Default YAML config placeholders
########################################
cat > "${RESOURCES_DIR}/config-defaults/app.yaml" <<'EOF_APPY'
server:
  port: 9494

pervasivecx:
  instanceName: "default-instance"
  environment: "dev"

logging:
  config: "/pervasiveCX_mnt/config/logging.yaml"
EOF_APPY

cat > "${RESOURCES_DIR}/config-defaults/db.yaml" <<'EOF_DBY'
datasource:
  url: "jdbc:postgresql://localhost:5432/pervasivecx"
  username: "pervasivecx"
  password: "change_me"
EOF_DBY

cat > "${RESOURCES_DIR}/config-defaults/logging.yaml" <<'EOF_LOGY'
log:
  level:
    root: INFO
EOF_LOGY

cat > "${RESOURCES_DIR}/config-defaults/collectors.yaml" <<'EOF_COLY'
collectors:
  schedule:
    enabled: false
    cron: "0 0 * * *"
EOF_COLY

cat > "${RESOURCES_DIR}/config-defaults/ui-layout.yaml" <<'EOF_UIY'
ui:
  tabs: []
EOF_UIY

########################################
# 8) Debian packaging files
########################################
cat > "${RESOURCES_DIR}/debian/control" <<'EOF_CTRL'
Package: pervasivecx
Version: @VERSION@
Section: utils
Priority: optional
Architecture: amd64
Maintainer: pervasiveCX Admin <admin@example.com>
Depends: openjdk-17-jre-headless, adduser, logrotate, curl
Description: pervasiveCX server information and metrics collector
 pervasiveCX collects and organizes server, metrics, and contact center
 data, exposing it via a modern web interface.
EOF_CTRL

cat > "${RESOURCES_DIR}/debian/postinst" <<'EOF_POSTINST'
#!/usr/bin/env bash
set -e

APP_USER="pervasivecx"
APP_GROUP="pervasivecx"
RUNTIME_BASE="/pervasiveCX_mnt"
APP_BASE="/opt/pervasivecx"

if ! id -u "${APP_USER}" >/dev/null 2>&1; then
  adduser --system --group --home "${RUNTIME_BASE}" "${APP_USER}"
fi

mkdir -p "${RUNTIME_BASE}/config" \
         "${RUNTIME_BASE}/logs" \
         "${RUNTIME_BASE}/data/reports" \
         "${RUNTIME_BASE}/data/snapshots" \
         "${RUNTIME_BASE}/runtime/pid" \
         "${RUNTIME_BASE}/runtime/tmp" \
         "${RUNTIME_BASE}/backups/config" \
         "${RUNTIME_BASE}/backups/db"

chown -R "${APP_USER}:${APP_GROUP}" "${RUNTIME_BASE}"

if [ ! -f "${RUNTIME_BASE}/config/app.yaml" ]; then
  VERSION_DIR=$(ls -1 "${APP_BASE}" | grep pervasivecx- | head -n1 || true)
  if [ -n "$VERSION_DIR" ]; then
    cp "${APP_BASE}/${VERSION_DIR}/config-defaults/"*.yaml "${RUNTIME_BASE}/config/" || true
    chown "${APP_USER}:${APP_GROUP}" "${RUNTIME_BASE}/config/"*.yaml || true
  fi
fi

LATEST_VERSION=$(ls -1 "${APP_BASE}" | grep pervasivecx- | sort --version-sort | tail -n1 || true)
if [ -n "$LATEST_VERSION" ]; then
  ln -sfn "${APP_BASE}/${LATEST_VERSION}" "${APP_BASE}/current"
fi

if command -v systemctl >/dev/null 2>&1; then
  systemctl daemon-reload
  systemctl enable pervasivecx-core.service
  systemctl enable pervasivecx-collector.service
fi

echo "pervasiveCX installation complete."
EOF_POSTINST
chmod +x "${RESOURCES_DIR}/debian/postinst"

cat > "${RESOURCES_DIR}/debian/prerm" <<'EOF_PRERM'
#!/usr/bin/env bash
set -e

if command -v systemctl >/dev/null 2>&1; then
  systemctl stop pervasivecx-core.service || true
  systemctl stop pervasivecx-collector.service || true
  systemctl disable pervasivecx-core.service || true
  systemctl disable pervasivecx-collector.service || true
fi
EOF_PRERM
chmod +x "${RESOURCES_DIR}/debian/prerm"

cat > "${RESOURCES_DIR}/debian/postrm" <<'EOF_POSTRM'
#!/usr/bin/env bash
set -e
# Keep /pervasiveCX_mnt data
EOF_POSTRM
chmod +x "${RESOURCES_DIR}/debian/postrm"

########################################
# 9) RPM spec file
########################################
cat > "${RESOURCES_DIR}/rpm/pervasivecx.spec" <<'EOF_SPEC'
Name:           pervasivecx
Version:        %{version}
Release:        1%{?dist}
Summary:        pervasiveCX server information and metrics collector
License:        Proprietary
URL:            https://example.com/pervasivecx
Group:          Applications/System
BuildArch:      x86_64

Requires:       java-17-openjdk, logrotate, curl

%description
pervasiveCX collects and organizes server information, metrics, and
contact center data, exposing it via a modern web interface.

%prep

%build

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}
tar -xzf %{SOURCE0} -C %{buildroot}

%post
APP_USER="pervasivecx"
APP_GROUP="pervasivecx"
RUNTIME_BASE="/pervasiveCX_mnt"
APP_BASE="/opt/pervasivecx"

if ! id "${APP_USER}" &>/dev/null; then
    useradd -r -s /sbin/nologin -d "${RUNTIME_BASE}" "${APP_USER}" || :
fi

mkdir -p "${RUNTIME_BASE}/config" \
         "${RUNTIME_BASE}/logs" \
         "${RUNTIME_BASE}/data/reports" \
         "${RUNTIME_BASE}/data/snapshots" \
         "${RUNTIME_BASE}/runtime/pid" \
         "${RUNTIME_BASE}/runtime/tmp" \
         "${RUNTIME_BASE}/backups/config" \
         "${RUNTIME_BASE}/backups/db"

chown -R "${APP_USER}:${APP_GROUP}" "${RUNTIME_BASE}"

LATEST_VERSION=$(ls -1 "${APP_BASE}" | grep pervasivecx- | sort -V | tail -n1 || true)
if [ -n "$LATEST_VERSION" ]; then
  ln -sfn "${APP_BASE}/${LATEST_VERSION}" "${APP_BASE}/current"
fi

if command -v systemctl >/dev/null 2>&1; then
  systemctl daemon-reload
  systemctl enable pervasivecx-core.service
  systemctl enable pervasivecx-collector.service
fi

%preun
if [ $1 -eq 0 ]; then
  if command -v systemctl >/dev/null 2>&1; then
    systemctl stop pervasivecx-core.service || :
    systemctl stop pervasivecx-collector.service || :
    systemctl disable pervasivecx-core.service || :
    systemctl disable pervasivecx-collector.service || :
  fi
fi

%postun
# Keep /pervasiveCX_mnt

%files
%defattr(-,root,root,-)
/opt/pervasivecx/
/etc/systemd/system/pervasivecx-core.service
/etc/systemd/system/pervasivecx-collector.service
/etc/logrotate.d/pervasivecx
/usr/bin/pcxctl

%changelog
* Thu Nov 27 2025 pervasiveCX Admin <admin@example.com> - %{version}-1
- Initial pervasivecx release
EOF_SPEC

echo "[INFO] Chapter A files created."
