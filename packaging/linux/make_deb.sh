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
