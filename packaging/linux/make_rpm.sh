#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <version>" >&2
  exit 1
fi

VERSION="$1"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

TARBALL="${ROOT_DIR}/build/pervasivecx-${VERSION}.tar.gz"
SPEC_SRC="${ROOT_DIR}/packaging/linux/pervasivecx.spec"

if [[ ! -f "$TARBALL" ]]; then
  echo "[ERROR] Tarball not found: $TARBALL" >&2
  echo "Run packaging/linux/build_artifacts.sh $VERSION first." >&2
  exit 1
fi

if [[ ! -f "$SPEC_SRC" ]]; then
  echo "[ERROR] Spec file not found: $SPEC_SRC" >&2
  exit 1
fi

RPM_ROOT="${ROOT_DIR}/build/rpmbuild"
SOURCES="${RPM_ROOT}/SOURCES"
SPECS="${RPM_ROOT}/SPECS"
RPMS="${RPM_ROOT}/RPMS"

mkdir -p "$SOURCES" "$SPECS" "$RPMS" "${RPM_ROOT}/BUILD" "${RPM_ROOT}/SRPMS"

# Copy tarball and spec
cp "$TARBALL" "${SOURCES}/pervasivecx-${VERSION}.tar.gz"
cp "$SPEC_SRC" "${SPECS}/pervasivecx.spec"

echo "[INFO] Building RPM for version ${VERSION}"

rpmbuild \
  --define "_topdir ${RPM_ROOT}" \
  --define "version ${VERSION}" \
  -bb "${SPECS}/pervasivecx.spec"

# Copy resulting RPM(s) to dist/
mkdir -p "${ROOT_DIR}/dist"
find "${RPMS}" -name "pervasivecx-*.rpm" -exec cp {} "${ROOT_DIR}/dist/" \;

echo "[INFO] RPM(s) copied to ${ROOT_DIR}/dist:"
ls -1 "${ROOT_DIR}/dist"/pervasivecx-*.rpm
