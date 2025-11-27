Name:           pervasivecx
Version:        %{version}
Release:        1%{?dist}
Summary:        pervasiveCX server information and metrics collector
License:        Proprietary
URL:            https://example.com/pervasivecx
Group:          Applications/System
BuildArch:      x86_64

# This tells rpmbuild what %{SOURCE0} is:
Source0:        pervasivecx-%{version}.tar.gz

Requires:       logrotate, curl

%description
pervasiveCX collects and organizes server information, metrics, and
contact center data, exposing it via a modern web interface.

%prep
# Nothing to prep

%build
# Nothing to build

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

