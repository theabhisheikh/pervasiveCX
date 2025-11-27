Name:           pervasivecx
Version:        %{version}
Release:        1%{?dist}
Summary:        pervasiveCX server snapshot and reporting tool
License:        Proprietary
BuildArch:      x86_64

Source0:        pervasivecx-%{version}.tar.gz

%description
pervasiveCX collects server information, stores it in PostgreSQL, and presents
it via a web-based UI plus snapshot export/import and reporting.

%prep
echo "Preparing pervasivecx build..."

%build
echo "Nothing to build."

%pre
# Create system user (no shell, no home) if it doesn't exist
/usr/sbin/useradd -r -s /sbin/nologin pervasivecx >/dev/null 2>&1 || true

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}
tar -C %{buildroot} -xf %{SOURCE0}

%post
/bin/systemctl daemon-reload >/dev/null 2>&1 || true
# Ensure pervasivecx owns its tree
chown -R pervasivecx:pervasivecx /pervasiveCX_mnt >/dev/null 2>&1 || true

%preun
if [ $1 -eq 0 ]; then
  /bin/systemctl stop pervasivecx >/dev/null 2>&1 || true
fi

%postun
/bin/systemctl daemon-reload >/dev/null 2>&1 || true

%files
/pervasiveCX_mnt
/etc/systemd/system/pervasivecx.service
