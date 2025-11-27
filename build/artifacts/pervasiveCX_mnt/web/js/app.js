// ==========================
// Utility: toast / messages
// ==========================
function showToast(message, type = 'info') {
  const toast = document.getElementById('toast');
  if (!toast) {
    console.log('[TOAST]', type, message);
    return;
  }

  toast.textContent = message;
  toast.classList.remove('toast-info', 'toast-error', 'toast-success');
  toast.classList.add(`toast-${type}`);
  toast.style.opacity = '1';

  setTimeout(() => {
    toast.style.opacity = '0';
  }, 3000);
}

// ==========================
// Tabs (multi-tab UI shell)
// ==========================
function initTabs() {
  const tabButtons = document.querySelectorAll('[data-tab-target]');
  const tabPanels = document.querySelectorAll('[data-tab-panel]');

  if (!tabButtons.length || !tabPanels.length) {
    // UI might be static; nothing to do
    return;
  }

  tabButtons.forEach(btn => {
    btn.addEventListener('click', () => {
      const target = btn.getAttribute('data-tab-target');

      tabButtons.forEach(b => b.classList.remove('active-tab'));
      tabPanels.forEach(p => p.classList.add('hidden'));

      btn.classList.add('active-tab');
      const panel = document.querySelector(`[data-tab-panel="${target}"]`);
      if (panel) {
        panel.classList.remove('hidden');
      }
    });
  });

  // Activate first tab by default
  const firstBtn = tabButtons[0];
  if (firstBtn) firstBtn.click();
}

// ==========================
// Capture Now behaviour
// ==========================
function triggerCapture() {
  showToast('Starting capture...', 'info');

  fetch('/api/capture/full', {
    method: 'POST'
  })
    .then(r => r.json().catch(() => ({})))
    .then(data => {
      if (data.status === 'started') {
        showToast('Capture started. Refresh dashboard in a moment.', 'success');
        // optionally reload dashboard summary after a delay
        setTimeout(() => {
          initDashboardData();
        }, 3000);
      } else {
        showToast('Capture failed: ' + (data.detail || 'unknown error'), 'error');
      }
    })
    .catch(err => {
      console.error('Error calling capture API', err);
      showToast('Error calling capture API.', 'error');
    });
}

function initCaptureButton() {
  const btn = document.getElementById('btn-capture');
  if (!btn) return;
  btn.addEventListener('click', triggerCapture);
}

// ==========================
// Fetch helper
// ==========================
async function fetchJson(url) {
  const res = await fetch(url);
  if (!res.ok) {
    throw new Error('HTTP ' + res.status + ' for ' + url);
  }
  return res.json();
}

// ==========================
// Dashboard data loaders
// ==========================
async function loadDashboardSummary() {
  const debugEl = document.getElementById('debug-dashboard-json');

  try {
    const data = await fetchJson('/api/dashboard/summary');

    // Debug box, if present
    if (debugEl) {
      debugEl.textContent =
        'Dashboard summary: ' + JSON.stringify(data, null, 2);
    }

    // Total servers
    const totalEl = document.getElementById('card-total-servers-value');
    if (totalEl) {
      totalEl.textContent = data.total_servers ?? '0';
    }

    // Last capture time
    const lastTimeEl = document.getElementById('card-last-capture-time-value');
    if (lastTimeEl) {
      lastTimeEl.textContent = data.last_capture_time
        ? new Date(data.last_capture_time).toLocaleString()
        : '—';
    }

    // Last capture status pill
    const statusEl = document.getElementById('card-last-capture-status-pill');
    if (statusEl) {
      const status = data.last_capture_status || 'N/A';
      statusEl.textContent = status;
      statusEl.classList.remove('pill-ok', 'pill-error', 'pill-pending');

      if (status === 'success') {
        statusEl.classList.add('pill-ok');
      } else if (status === 'running') {
        statusEl.classList.add('pill-pending');
      } else if (status === 'failed') {
        statusEl.classList.add('pill-error');
      }
    }

    // Total captures
    const totalCapEl = document.getElementById('card-total-captures-value');
    if (totalCapEl) {
      totalCapEl.textContent = data.total_captures ?? '0';
    }
  } catch (err) {
    console.error('Failed to load dashboard summary', err);
    if (debugEl) {
      debugEl.textContent = 'Error loading dashboard: ' + err.message;
    }
  }
}

// ==========================
// Servers & volumes
// ==========================
async function loadServerList() {
  try {
    const servers = await fetchJson('/api/servers');
    const tbody = document.getElementById('table-servers-body');
    if (!tbody) return;

    tbody.innerHTML = '';

    servers.forEach(s => {
      const tr = document.createElement('tr');
      tr.innerHTML = `
        <td>${s.code || ''}</td>
        <td>${s.hostname || ''}</td>
        <td>${s.environment || ''}</td>
        <td>${s.os_name || ''}</td>
        <td>${s.cpu_cores ?? ''}</td>
        <td>${s.ram_mb ?? ''}</td>
      `;

      // Click to filter volumes by this server
      tr.addEventListener('click', () => {
        loadVolumeListForServer(s.code);
      });

      tbody.appendChild(tr);
    });
  } catch (err) {
    console.error('Failed to load servers list', err);
  }
}

async function loadVolumeListForServer(serverCode) {
  try {
    const url = serverCode
      ? `/api/volumes?server_code=${encodeURIComponent(serverCode)}`
      : '/api/volumes';

    const vols = await fetchJson(url);
    const tbody = document.getElementById('table-volumes-body');
    if (!tbody) return;

    tbody.innerHTML = '';

    vols.forEach(v => {
      const tr = document.createElement('tr');
      tr.innerHTML = `
        <td>${v.server_code || ''}</td>
        <td>${v.mount_point || ''}</td>
        <td>${v.filesystem_type || ''}</td>
        <td>${v.total_gb ?? ''}</td>
        <td>${v.used_gb ?? ''}</td>
        <td>${v.available_gb ?? ''}</td>
        <td>${v.usage_percent ?? ''}%</td>
      `;
      tbody.appendChild(tr);
    });
  } catch (err) {
    console.error('Failed to load volumes list', err);
  }
}

// ==========================
// Capture sessions table
// ==========================
async function loadCaptureList() {
  try {
    const caps = await fetchJson('/api/captures/recent');
    const tbody = document.getElementById('table-captures-body');
    if (!tbody) return;

    tbody.innerHTML = '';

    caps.forEach(c => {
      const tr = document.createElement('tr');
      tr.innerHTML = `
        <td>${c.id || ''}</td>
        <td>${c.trigger_type || ''}</td>
        <td>${c.triggered_by || ''}</td>
        <td>${c.status || ''}</td>
        <td>${c.started_at ? new Date(c.started_at).toLocaleString() : ''}</td>
        <td>${c.ended_at ? new Date(c.ended_at).toLocaleString() : ''}</td>
      `;
      tbody.appendChild(tr);
    });
  } catch (err) {
    console.error('Failed to load capture list', err);
  }
}

// ==========================
// App init
// ==========================
async function initDashboardData() {
  await loadDashboardSummary();
  await loadServerList();
  await loadCaptureList();
  await loadVolumeListForServer(null); // all volumes initially
}

function initApp() {
  initTabs();
  initCaptureButton();
  initDashboardData();
}

// Entry point
document.addEventListener('DOMContentLoaded', () => {
  initApp();
});

