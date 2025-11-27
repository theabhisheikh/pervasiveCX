#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WEB_SRC="${PROJECT_ROOT}/web/static"
WEB_DST="/pervasiveCX_mnt/web"

echo "[INFO] Creating UI source directories..."
mkdir -p "${WEB_SRC}/css" "${WEB_SRC}/js"

#######################################
# 1) index.html
#######################################
cat > "${WEB_SRC}/index.html" <<'HTML'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <title>pervasiveCX</title>
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <link rel="stylesheet" href="css/styles.css" />
</head>
<body>
  <header class="pcx-header">
    <div class="pcx-logo">
      <span class="pcx-logo-mark">PCX</span>
      <span class="pcx-logo-text">pervasiveCX</span>
    </div>
    <div class="pcx-header-actions">
      <button id="btn-capture" class="pcx-btn pcx-btn-primary">
        Capture Now
      </button>
    </div>
  </header>

  <nav class="pcx-tabbar" id="pcx-tabbar"></nav>

  <main class="pcx-main">
    <section id="pcx-section-container"></section>
  </main>

  <footer class="pcx-footer">
    <span>pervasiveCX • Multi-Tab System Intelligence Dashboard</span>
  </footer>

  <div id="pcx-toast" class="pcx-toast hidden"></div>

  <script src="js/app.js"></script>
</body>
</html>
HTML

#######################################
# 2) styles.css
#######################################
cat > "${WEB_SRC}/css/styles.css" <<'CSS'
:root {
  --pcx-bg: #0b1020;
  --pcx-card-bg: #151a2c;
  --pcx-card-bg-soft: #111626;
  --pcx-border: #242a3d;
  --pcx-accent: #3b82f6;
  --pcx-accent-soft: rgba(59,130,246,0.12);
  --pcx-text: #e5e7ef;
  --pcx-muted: #9ca3af;
  --pcx-danger: #f97373;
  --pcx-radius-lg: 16px;
  --pcx-radius-xl: 22px;
  --pcx-shadow-soft: 0 18px 45px rgba(0,0,0,0.45);
  --pcx-shadow-subtle: 0 10px 25px rgba(0,0,0,0.35);
  --pcx-font-sans: system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
}

*,
*::before,
*::after {
  box-sizing: border-box;
}

html,
body {
  margin: 0;
  padding: 0;
  font-family: var(--pcx-font-sans);
  background: radial-gradient(circle at top, #111827 0, #020617 55%, #000 100%);
  color: var(--pcx-text);
  min-height: 100vh;
}

body {
  display: flex;
  flex-direction: column;
}

.pcx-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 14px 24px;
  border-bottom: 1px solid rgba(148,163,184,0.22);
  backdrop-filter: blur(24px);
  background: linear-gradient(90deg, rgba(15,23,42,0.92), rgba(13,23,45,0.9));
  position: sticky;
  top: 0;
  z-index: 40;
}

.pcx-logo {
  display: flex;
  align-items: center;
  gap: 10px;
}

.pcx-logo-mark {
  background: linear-gradient(135deg, #3b82f6, #22c55e);
  color: white;
  font-weight: 700;
  font-size: 0.8rem;
  padding: 4px 9px;
  border-radius: 999px;
  letter-spacing: 0.08em;
  text-transform: uppercase;
}

.pcx-logo-text {
  font-weight: 600;
  letter-spacing: 0.04em;
  text-transform: uppercase;
  font-size: 0.9rem;
  color: #e5e7eb;
}

.pcx-header-actions {
  display: flex;
  align-items: center;
  gap: 10px;
}

.pcx-btn {
  border: none;
  border-radius: 999px;
  padding: 7px 14px;
  font-size: 0.85rem;
  font-weight: 500;
  cursor: pointer;
  display: inline-flex;
  align-items: center;
  gap: 6px;
  transition: all 0.16s ease-out;
}

.pcx-btn-primary {
  background: linear-gradient(135deg, #3b82f6, #6366f1);
  color: white;
  box-shadow: 0 10px 25px rgba(37,99,235,0.55);
}

.pcx-btn-primary:hover {
  transform: translateY(-1px);
  box-shadow: 0 18px 35px rgba(37,99,235,0.75);
}

.pcx-tabbar {
  display: flex;
  gap: 4px;
  padding: 10px 16px 0;
  overflow-x: auto;
  scrollbar-width: thin;
}

.pcx-tab {
  padding: 7px 14px;
  border-radius: 999px;
  font-size: 0.8rem;
  color: var(--pcx-muted);
  border: 1px solid transparent;
  background: transparent;
  cursor: pointer;
  white-space: nowrap;
  display: inline-flex;
  align-items: center;
  gap: 6px;
  transition: all 0.16s ease-out;
}

.pcx-tab span.pcx-tab-dot {
  width: 6px;
  height: 6px;
  border-radius: 999px;
  background: rgba(148,163,184,0.4);
}

.pcx-tab-active {
  color: var(--pcx-text);
  border-color: rgba(148,163,184,0.25);
  background: radial-gradient(circle at top left, rgba(59,130,246,0.28), rgba(15,23,42,0.95));
  box-shadow: var(--pcx-shadow-subtle);
}

.pcx-tab-active span.pcx-tab-dot {
  background: #22c55e;
}

.pcx-main {
  flex: 1;
  padding: 10px 18px 18px;
}

#pcx-section-container {
  max-width: 1280px;
  margin: 0 auto;
}

.pcx-sections-grid {
  display: grid;
  grid-template-columns: minmax(0,1fr);
  gap: 16px;
}

@media (min-width: 900px) {
  .pcx-sections-grid {
    grid-template-columns: minmax(0,1.3fr) minmax(0,1fr);
    align-items: flex-start;
  }
}

.pcx-section-card {
  background: radial-gradient(circle at top, rgba(30,64,175,0.18), rgba(15,23,42,0.96));
  border-radius: var(--pcx-radius-xl);
  padding: 14px 14px 12px;
  border: 1px solid rgba(30,64,175,0.5);
  box-shadow: var(--pcx-shadow-soft);
  position: relative;
  overflow: hidden;
}

.pcx-section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 10px;
}

.pcx-section-title-group {
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.pcx-section-title {
  font-size: 0.95rem;
  font-weight: 600;
  letter-spacing: 0.04em;
  text-transform: uppercase;
  color: #e5e7eb;
}

.pcx-section-subtitle {
  font-size: 0.78rem;
  color: var(--pcx-muted);
}

.pcx-section-pill {
  font-size: 0.75rem;
  padding: 4px 9px;
  border-radius: 999px;
  background: rgba(15,23,42,0.8);
  border: 1px solid rgba(148,163,184,0.4);
  color: var(--pcx-muted);
}

.pcx-widget-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
  gap: 10px;
}

.pcx-widget-card {
  background: var(--pcx-card-bg);
  border-radius: 16px;
  padding: 10px 11px;
  border: 1px solid var(--pcx-border);
  box-shadow: var(--pcx-shadow-subtle);
}

.pcx-widget-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 6px;
}

.pcx-widget-title {
  font-size: 0.82rem;
  font-weight: 500;
}

.pcx-widget-tag {
  font-size: 0.7rem;
  padding: 2px 7px;
  border-radius: 999px;
  background: rgba(15,23,42,0.8);
  color: var(--pcx-muted);
}

.pcx-kpi-value {
  font-size: 1.5rem;
  font-weight: 600;
  letter-spacing: 0.02em;
}

.pcx-kpi-label {
  font-size: 0.72rem;
  color: var(--pcx-muted);
}

.pcx-table {
  width: 100%;
  border-collapse: collapse;
  font-size: 0.8rem;
}

.pcx-table thead {
  background: var(--pcx-card-bg-soft);
}

.pcx-table th,
.pcx-table td {
  padding: 6px 8px;
  border-bottom: 1px solid rgba(31,41,55,0.9);
}

.pcx-table th {
  text-align: left;
  font-weight: 500;
  color: var(--pcx-muted);
  text-transform: uppercase;
  font-size: 0.7rem;
}

.pcx-table-placeholder {
  font-size: 0.75rem;
  color: var(--pcx-muted);
  padding: 5px 2px 0;
}

.pcx-chart-placeholder {
  height: 140px;
  border-radius: 12px;
  background: radial-gradient(circle at top, rgba(59,130,246,0.2), rgba(15,23,42,0.9));
  border: 1px dashed rgba(148,163,184,0.4);
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 0.78rem;
  color: var(--pcx-muted);
}

.pcx-footer {
  padding: 8px 16px 12px;
  font-size: 0.75rem;
  color: var(--pcx-muted);
  text-align: center;
  border-top: 1px solid rgba(15,23,42,0.9);
  background: #020617;
}

.pcx-toast {
  position: fixed;
  right: 16px;
  bottom: 16px;
  min-width: 200px;
  max-width: 320px;
  padding: 9px 12px;
  border-radius: 12px;
  font-size: 0.78rem;
  background: rgba(15,23,42,0.95);
  border: 1px solid rgba(59,130,246,0.6);
  box-shadow: 0 16px 35px rgba(0,0,0,0.65);
  z-index: 50;
}

.pcx-toast.hidden {
  display: none;
}
CSS

#######################################
# 3) app.js
#######################################
cat > "${WEB_SRC}/js/app.js" <<'JS'
const state = {
  tabs: [],
  activeTabCode: null
};

function showToast(message) {
  const el = document.getElementById('pcx-toast');
  if (!el) return;
  el.textContent = message;
  el.classList.remove('hidden');
  setTimeout(() => el.classList.add('hidden'), 2500);
}

function renderTabs() {
  const tabbar = document.getElementById('pcx-tabbar');
  tabbar.innerHTML = '';
  state.tabs.forEach(tab => {
    const btn = document.createElement('button');
    btn.className = 'pcx-tab' + (tab.code === state.activeTabCode ? ' pcx-tab-active' : '');
    btn.dataset.tabCode = tab.code;

    const dot = document.createElement('span');
    dot.className = 'pcx-tab-dot';

    const text = document.createElement('span');
    text.textContent = tab.title;

    btn.appendChild(dot);
    btn.appendChild(text);

    btn.addEventListener('click', () => {
      state.activeTabCode = tab.code;
      renderTabs();
      renderSections();
    });

    tabbar.appendChild(btn);
  });
}

function createWidgetElement(widget) {
  const card = document.createElement('div');
  card.className = 'pcx-widget-card';

  const header = document.createElement('div');
  header.className = 'pcx-widget-header';

  const title = document.createElement('div');
  title.className = 'pcx-widget-title';
  title.textContent = widget.title;

  const tag = document.createElement('div');
  tag.className = 'pcx-widget-tag';
  tag.textContent = widget.widget_type.toUpperCase();

  header.appendChild(title);
  header.appendChild(tag);
  card.appendChild(header);

  const config = widget.config || {};
  const body = document.createElement('div');

  if (widget.widget_type === 'kpi') {
    const value = document.createElement('div');
    value.className = 'pcx-kpi-value';
    value.textContent = '—';

    const label = document.createElement('div');
    label.className = 'pcx-kpi-label';
    label.textContent = (config.metricCodes || []).join(', ') || 'Metric';

    body.appendChild(value);
    body.appendChild(label);
  } else if (widget.widget_type === 'table') {
    const table = document.createElement('table');
    table.className = 'pcx-table';

    const thead = document.createElement('thead');
    const trh = document.createElement('tr');
    (config.columns || []).forEach(col => {
      const th = document.createElement('th');
      th.textContent = col;
      trh.appendChild(th);
    });
    thead.appendChild(trh);
    table.appendChild(thead);

    const tbody = document.createElement('tbody');
    const tr = document.createElement('tr');
    const cols = config.columns || [];
    cols.forEach(() => {
      const td = document.createElement('td');
      td.textContent = '—';
      tr.appendChild(td);
    });
    if (cols.length > 0) {
      tbody.appendChild(tr);
    }
    table.appendChild(tbody);

    body.appendChild(table);

    const hint = document.createElement('div');
    hint.className = 'pcx-table-placeholder';
    hint.textContent = 'Data wiring will be added in a later chapter.';
    body.appendChild(hint);
  } else if (widget.widget_type === 'chart') {
    const placeholder = document.createElement('div');
    placeholder.className = 'pcx-chart-placeholder';
    const metric = config.metricCode || (config.metricCodes || [])[0] || 'metric';
    placeholder.textContent = 'Chart placeholder for ' + metric;
    body.appendChild(placeholder);
  } else {
    const text = document.createElement('div');
    text.className = 'pcx-table-placeholder';
    text.textContent = 'Unknown widget type: ' + widget.widget_type;
    body.appendChild(text);
  }

  card.appendChild(body);
  return card;
}

function renderSections() {
  const container = document.getElementById('pcx-section-container');
  container.innerHTML = '';

  const tab = state.tabs.find(t => t.code === state.activeTabCode);
  if (!tab) return;

  const wrapper = document.createElement('div');
  wrapper.className = 'pcx-sections-grid';

  (tab.sections || []).forEach((section, index) => {
    const card = document.createElement('div');
    card.className = 'pcx-section-card';

    const header = document.createElement('div');
    header.className = 'pcx-section-header';

    const titleGroup = document.createElement('div');
    titleGroup.className = 'pcx-section-title-group';

    const title = document.createElement('div');
    title.className = 'pcx-section-title';
    title.textContent = section.title;

    const subtitle = document.createElement('div');
    subtitle.className = 'pcx-section-subtitle';
    subtitle.textContent = section.subtitle || '';

    titleGroup.appendChild(title);
    if (section.subtitle) {
      titleGroup.appendChild(subtitle);
    }

    const pill = document.createElement('div');
    pill.className = 'pcx-section-pill';
    pill.textContent = (tab.code === 'DASHBOARD' && index === 0)
      ? 'Key KPIs • Last 30 Days'
      : 'Section • ' + section.code;

    header.appendChild(titleGroup);
    header.appendChild(pill);

    card.appendChild(header);

    const widgetsGrid = document.createElement('div');
    widgetsGrid.className = 'pcx-widget-grid';

    (section.widgets || []).forEach(widget => {
      widgetsGrid.appendChild(createWidgetElement(widget));
    });

    card.appendChild(widgetsGrid);
    wrapper.appendChild(card);
  });

  container.appendChild(wrapper);
}

function initCaptureButton() {
  const btn = document.getElementById('btn-capture');
  if (!btn) return;

  btn.addEventListener('click', () => {
    showToast('Capture trigger requested. (Backend wiring will be added later.)');
  });
}

function loadUiMetadata() {
  fetch('ui-metadata.json?' + Date.now())
    .then(r => {
      if (!r.ok) throw new Error('Failed to load UI metadata');
      return r.json();
    })
    .then(data => {
      if (!Array.isArray(data)) data = [];
      state.tabs = data;

      const defaultTab = state.tabs.find(t => t.is_default) || state.tabs[0];
      state.activeTabCode = defaultTab ? defaultTab.code : null;

      renderTabs();
      renderSections();
    })
    .catch(err => {
      console.error(err);
      showToast('Unable to load UI metadata. Have you exported ui-metadata.json?');
    });
}

document.addEventListener('DOMContentLoaded', () => {
  initCaptureButton();
  loadUiMetadata();
});
JS

#######################################
# 4) export_ui_metadata.sh
#######################################
mkdir -p "${PROJECT_ROOT}/web/scripts"

cat > "${PROJECT_ROOT}/web/scripts/export_ui_metadata.sh" <<'SH'
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
SH

chmod +x "${PROJECT_ROOT}/web/scripts/export_ui_metadata.sh"

#######################################
# 5) Copy static files to /pervasiveCX_mnt/web
#######################################
echo "[INFO] Syncing static UI to ${WEB_DST}..."
mkdir -p "${WEB_DST}"
cp -r "${WEB_SRC}/." "${WEB_DST}/"

chown -R pervasivecx:pervasivecx "${WEB_DST}"

echo "[INFO] Chapter E UI scaffold created."
echo "[INFO] Next steps:"
echo "  1) Export UI metadata JSON: sudo ${PROJECT_ROOT}/web/scripts/export_ui_metadata.sh"
echo "  2) Serve /pervasiveCX_mnt/web on port 9494 (e.g. python3 -m http.server 9494)."
