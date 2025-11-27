-- Seed UI tabs
INSERT INTO ui_tab (code, title, icon, sort_order, is_default) VALUES
  ('DASHBOARD', 'Dashboard', 'dashboard', 1, true),
  ('SERVERS', 'Servers & OS', 'server', 2, false),
  ('ARCHITECTURE', 'Setup Architecture', 'diagram', 3, false),
  ('MODULES_CUSTOM', 'Modules & Customization', 'puzzle', 4, false),
  ('INTEGRATIONS', 'Integrations & Licenses', 'plug', 5, false),
  ('METRICS', '30-Day Metrics', 'activity', 6, false),
  ('QA_RULES', 'QA & Rule Engine', 'check-circle', 7, false),
  ('LOGS_SYSTEM', 'Logs & System Info', 'file-text', 8, false),
  ('ADMIN', 'Admin & Export', 'settings', 9, false)
ON CONFLICT (code) DO NOTHING;

-- Dashboard sections
INSERT INTO ui_section (tab_id, code, title, subtitle, sort_order) VALUES
  ((SELECT id FROM ui_tab WHERE code='DASHBOARD'), 'DB_KPIS', 'Key KPIs', 'Last 30 days overview', 1),
  ((SELECT id FROM ui_tab WHERE code='DASHBOARD'), 'SYSTEM_HEALTH', 'System Health', 'Server & service status', 2)
ON CONFLICT (tab_id, code) DO NOTHING;

-- Dashboard widgets
INSERT INTO ui_widget (section_id, code, title, widget_type, sort_order, config) VALUES
  (
    (SELECT s.id FROM ui_section s JOIN ui_tab t ON s.tab_id=t.id WHERE t.code='DASHBOARD' AND s.code='DB_KPIS'),
    'W_TOTAL_CALLS',
    'Total Calls (Last 30 Days)',
    'kpi',
    1,
    '{"metricCodes":["CALL_COUNT_30D"],"unit":"count","trendMetricCode":"CALL_COUNT_30D_TREND"}'::jsonb
  ),
  (
    (SELECT s.id FROM ui_section s JOIN ui_tab t ON s.tab_id=t.id WHERE t.code='DASHBOARD' AND s.code='DB_KPIS'),
    'W_AVG_TALK_TIME',
    'Average Talk Time',
    'kpi',
    2,
    '{"metricCodes":["AVG_TALK_TIME_30D"],"unit":"seconds"}'::jsonb
  ),
  (
    (SELECT s.id FROM ui_section s JOIN ui_tab t ON s.tab_id=t.id WHERE t.code='DASHBOARD' AND s.code='SYSTEM_HEALTH'),
    'W_SERVER_STATUS',
    'Server & Service Status',
    'table',
    1,
    '{"entity":"server","includeServices":true,"columns":["hostname","environment","os_name","cpu_cores"]}'::jsonb
  )
ON CONFLICT (section_id, code) DO NOTHING;

-- Servers tab
INSERT INTO ui_section (tab_id, code, title, subtitle, sort_order) VALUES
  ((SELECT id FROM ui_tab WHERE code='SERVERS'), 'SRV_OVERVIEW', 'Server Overview', 'Specs and OS details', 1),
  ((SELECT id FROM ui_tab WHERE code='SERVERS'), 'SRV_STORAGE', 'Storage (df -h)', 'Mount points & usage', 2)
ON CONFLICT (tab_id, code) DO NOTHING;

INSERT INTO ui_widget (section_id, code, title, widget_type, sort_order, config) VALUES
  (
    (SELECT s.id FROM ui_section s JOIN ui_tab t ON s.tab_id=t.id WHERE t.code='SERVERS' AND s.code='SRV_OVERVIEW'),
    'W_SERVERS_TABLE',
    'Servers',
    'table',
    1,
    '{"entity":"server","columns":["hostname","ip_address","environment","os_name","os_version","cpu_cores","ram_mb"]}'::jsonb
  ),
  (
    (SELECT s.id FROM ui_section s JOIN ui_tab t ON s.tab_id=t.id WHERE t.code='SERVERS' AND s.code='SRV_STORAGE'),
    'W_DF_TABLE',
    'Disk Usage',
    'table',
    1,
    '{"entity":"server_volume","columns":["server_id","mount_point","filesystem_type","total_gb","used_gb","usage_percent"]}'::jsonb
  )
ON CONFLICT (section_id, code) DO NOTHING;

-- Metrics tab
INSERT INTO ui_section (tab_id, code, title, subtitle, sort_order) VALUES
  ((SELECT id FROM ui_tab WHERE code='METRICS'), 'MTX_CALLS', 'Calls & Interactions', 'Last 30 days', 1),
  ((SELECT id FROM ui_tab WHERE code='METRICS'), 'MTX_AGENT', 'Agent & Login Metrics', 'Concurrency & usage', 2)
ON CONFLICT (tab_id, code) DO NOTHING;

INSERT INTO ui_widget (section_id, code, title, widget_type, sort_order, config) VALUES
  (
    (SELECT s.id FROM ui_section s JOIN ui_tab t ON s.tab_id=t.id WHERE t.code='METRICS' AND s.code='MTX_CALLS'),
    'W_CALLS_BY_TYPE',
    'Call Count by Type',
    'chart',
    1,
    '{"metricCode":"CALL_COUNT_30D_BY_TYPE","chartType":"bar","dimension":"callType"}'::jsonb
  ),
  (
    (SELECT s.id FROM ui_section s JOIN ui_tab t ON s.tab_id=t.id WHERE t.code='METRICS' AND s.code='MTX_AGENT'),
    'W_CONCURRENT_LOGIN',
    'Max Concurrent Agent Login',
    'kpi',
    1,
    '{"metricCodes":["AGENT_CONCURRENT_MAX_30D"],"unit":"agents"}'::jsonb
  )
ON CONFLICT (section_id, code) DO NOTHING;

