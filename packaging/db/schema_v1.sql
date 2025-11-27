-- pervasiveCX Database Schema v1
-- This schema focuses on:
-- - Core entities (servers, services, RPMs, connections)
-- - Capture sessions (grouping a snapshot of collected data)
-- - Metrics (last 30 days stats, etc.)
-- - Customizations, QA, rule engines
-- - UI metadata (tabs/sections/widgets)

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-------------------------
-- 1. Capture session
-------------------------
CREATE TABLE IF NOT EXISTS capture_session (
    id              uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    started_at      timestamptz NOT NULL DEFAULT now(),
    ended_at        timestamptz,
    trigger_type    text NOT NULL DEFAULT 'manual', -- manual | schedule | api
    triggered_by    text,                           -- username or system
    status          text NOT NULL DEFAULT 'running', -- running|success|failed|partial
    notes           text
);

-------------------------
-- 2. Servers & system
-------------------------
CREATE TABLE IF NOT EXISTS server (
    id              bigserial PRIMARY KEY,
    code            text UNIQUE NOT NULL,           -- e.g. "SRV_SEC_01"
    hostname        text NOT NULL,
    ip_address      text,
    environment     text,                           -- dev|qa|prod|dr etc.
    os_name         text,
    os_version      text,
    cpu_cores       integer,
    ram_mb          integer,
    tags            jsonb NOT NULL DEFAULT '{}'::jsonb,
    created_at      timestamptz NOT NULL DEFAULT now(),
    updated_at      timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS server_volume (
    id                  bigserial PRIMARY KEY,
    server_id           bigint NOT NULL REFERENCES server(id) ON DELETE CASCADE,
    capture_session_id  uuid REFERENCES capture_session(id),
    mount_point         text NOT NULL,
    filesystem_type     text,
    total_gb            numeric(12,2),
    used_gb             numeric(12,2),
    available_gb        numeric(12,2),
    usage_percent       numeric(5,2),
    raw_df_output       text,
    collected_at        timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS service_instance (
    id                  bigserial PRIMARY KEY,
    server_id           bigint NOT NULL REFERENCES server(id) ON DELETE CASCADE,
    capture_session_id  uuid REFERENCES capture_session(id),
    name                text NOT NULL,              -- e.g. tomcat, postgres, ameyo-core
    type                text,                       -- systemd|docker|custom
    status              text,                       -- running|stopped|failed|unknown
    port                integer,
    extra_info          jsonb NOT NULL DEFAULT '{}'::jsonb,
    collected_at        timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS rpm_package (
    id                  bigserial PRIMARY KEY,
    server_id           bigint NOT NULL REFERENCES server(id) ON DELETE CASCADE,
    capture_session_id  uuid REFERENCES capture_session(id),
    name                text NOT NULL,
    version             text,
    release             text,
    arch                text,
    is_ameyo_rpm        boolean NOT NULL DEFAULT false,
    dependencies        jsonb NOT NULL DEFAULT '[]'::jsonb,
    installed_at        timestamptz,
    collected_at        timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS nas_connection (
    id                  bigserial PRIMARY KEY,
    server_id           bigint NOT NULL REFERENCES server(id) ON DELETE CASCADE,
    capture_session_id  uuid REFERENCES capture_session(id),
    name                text NOT NULL,
    mount_point         text NOT NULL,
    endpoint            text,
    protocol            text, -- NFS, SMB, etc.
    options             jsonb NOT NULL DEFAULT '{}'::jsonb,
    is_active           boolean NOT NULL DEFAULT true,
    collected_at        timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS ftp_connection (
    id                  bigserial PRIMARY KEY,
    server_id           bigint NOT NULL REFERENCES server(id) ON DELETE CASCADE,
    capture_session_id  uuid REFERENCES capture_session(id),
    name                text NOT NULL,
    host                text NOT NULL,
    port                integer,
    username            text,
    is_sftp             boolean NOT NULL DEFAULT false,
    options             jsonb NOT NULL DEFAULT '{}'::jsonb,
    is_active           boolean NOT NULL DEFAULT true,
    collected_at        timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS db_snapshot (
    id                  bigserial PRIMARY KEY,
    capture_session_id  uuid REFERENCES capture_session(id),
    server_id           bigint REFERENCES server(id) ON DELETE SET NULL,
    db_name             text NOT NULL,
    size_mb             numeric(18,2),
    min_data_ts         timestamptz,
    max_data_ts         timestamptz,
    extra_info          jsonb NOT NULL DEFAULT '{}'::jsonb,
    collected_at        timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS license_snapshot (
    id                  bigserial PRIMARY KEY,
    capture_session_id  uuid REFERENCES capture_session(id),
    server_id           bigint REFERENCES server(id) ON DELETE SET NULL,
    raw_output          text NOT NULL,
    parsed_json         jsonb NOT NULL DEFAULT '{}'::jsonb,
    collected_at        timestamptz NOT NULL DEFAULT now()
);

-------------------------
-- 3. Application modules & customizations
-------------------------
CREATE TABLE IF NOT EXISTS app_module (
    id              bigserial PRIMARY KEY,
    code            text UNIQUE NOT NULL,      -- e.g. "ACD", "DIALER", "REPORTING"
    name            text NOT NULL,
    type            text,                     -- system|acp|integration|other
    description     text,
    is_enabled      boolean NOT NULL DEFAULT true,
    metadata        jsonb NOT NULL DEFAULT '{}'::jsonb
);

CREATE TABLE IF NOT EXISTS media_profile (
    id              bigserial PRIMARY KEY,
    name            text NOT NULL,
    channel_type    text NOT NULL,            -- voice|chat|email|social etc.
    config          jsonb NOT NULL DEFAULT '{}'::jsonb,
    is_active       boolean NOT NULL DEFAULT true
);

CREATE TABLE IF NOT EXISTS crm_integration (
    id              bigserial PRIMARY KEY,
    name            text NOT NULL,
    vendor          text,
    approach        text,                     -- API|DB|File|iPaaS etc.
    endpoint        text,
    mapping_config  jsonb NOT NULL DEFAULT '{}'::jsonb,
    is_active       boolean NOT NULL DEFAULT true
);

CREATE TABLE IF NOT EXISTS customization (
    id              bigserial PRIMARY KEY,
    area            text NOT NULL,            -- others|blaster|inbound|autodial|reports|ui etc.
    title           text NOT NULL,
    description     text,
    module_code     text REFERENCES app_module(code),
    impact_level    text,                     -- low|medium|high
    owner           text,
    created_at      timestamptz NOT NULL DEFAULT now(),
    updated_at      timestamptz NOT NULL DEFAULT now(),
    metadata        jsonb NOT NULL DEFAULT '{}'::jsonb
);

CREATE TABLE IF NOT EXISTS custom_report (
    id              bigserial PRIMARY KEY,
    name            text NOT NULL,
    description     text,
    category        text,
    query_ref       text,                     -- e.g. stored procedure name or report id
    schedule        text,                     -- cron expression or schedule description
    metadata        jsonb NOT NULL DEFAULT '{}'::jsonb,
    is_active       boolean NOT NULL DEFAULT true
);

-------------------------
-- 4. Campaigns, QA & rules
-------------------------
CREATE TABLE IF NOT EXISTS campaign (
    id              bigserial PRIMARY KEY,
    name            text NOT NULL,
    type            text NOT NULL,            -- inbound|outbound|blended|chat etc.
    system_ref      text,                     -- external system id
    is_active       boolean NOT NULL DEFAULT true,
    metadata        jsonb NOT NULL DEFAULT '{}'::jsonb
);

CREATE TABLE IF NOT EXISTS qa_parameter (
    id              bigserial PRIMARY KEY,
    name            text NOT NULL,
    category        text,
    description     text,
    max_score       numeric(10,2),
    weight          numeric(10,2),
    is_active       boolean NOT NULL DEFAULT true,
    metadata        jsonb NOT NULL DEFAULT '{}'::jsonb
);

CREATE TABLE IF NOT EXISTS rule_engine (
    id              bigserial PRIMARY KEY,
    name            text NOT NULL,
    type            text,                     -- routing|scoring|dialer|workflow etc.
    description     text,
    config          jsonb NOT NULL DEFAULT '{}'::jsonb,
    is_active       boolean NOT NULL DEFAULT true
);

-------------------------
-- 5. Metrics (time series)
-------------------------
CREATE TABLE IF NOT EXISTS metric_definition (
    id              bigserial PRIMARY KEY,
    code            text UNIQUE NOT NULL,     -- e.g. CALL_COUNT_30D
    name            text NOT NULL,
    category        text NOT NULL,           -- call|chat|system|agent etc.
    unit            text,                    -- count|seconds|percent etc.
    description     text,
    aggregation     text,                    -- sum|avg|max|min etc.
    metadata        jsonb NOT NULL DEFAULT '{}'::jsonb
);

CREATE TABLE IF NOT EXISTS metric_timeseries (
    id                  bigserial PRIMARY KEY,
    metric_id           bigint NOT NULL REFERENCES metric_definition(id) ON DELETE CASCADE,
    capture_session_id  uuid REFERENCES capture_session(id),
    server_id           bigint REFERENCES server(id) ON DELETE SET NULL,
    campaign_id         bigint REFERENCES campaign(id) ON DELETE SET NULL,
    ts                  timestamptz NOT NULL,   -- time bucket: minute/hour/day
    value               numeric(18,4) NOT NULL,
    dimensions          jsonb NOT NULL DEFAULT '{}'::jsonb
    -- dimensions example: {"callType":"inbound", "channel":"voice"}
);

-------------------------
-- 6. UI metadata (tabs/sections/widgets)
-------------------------
CREATE TABLE IF NOT EXISTS ui_tab (
    id              bigserial PRIMARY KEY,
    code            text UNIQUE NOT NULL,     -- e.g. DASHBOARD, SERVERS, METRICS
    title           text NOT NULL,
    icon            text,
    sort_order      integer NOT NULL DEFAULT 0,
    is_default      boolean NOT NULL DEFAULT false,
    is_enabled      boolean NOT NULL DEFAULT true
);

CREATE TABLE IF NOT EXISTS ui_section (
    id              bigserial PRIMARY KEY,
    tab_id          bigint NOT NULL REFERENCES ui_tab(id) ON DELETE CASCADE,
    code            text NOT NULL,
    title           text NOT NULL,
    subtitle        text,
    sort_order      integer NOT NULL DEFAULT 0,
    is_enabled      boolean NOT NULL DEFAULT true,
    UNIQUE(tab_id, code)
);

CREATE TABLE IF NOT EXISTS ui_widget (
    id              bigserial PRIMARY KEY,
    section_id      bigint NOT NULL REFERENCES ui_section(id) ON DELETE CASCADE,
    code            text NOT NULL,
    title           text NOT NULL,
    widget_type     text NOT NULL,           -- kpi|chart|table|details|timeline etc.
    sort_order      integer NOT NULL DEFAULT 0,
    config          jsonb NOT NULL DEFAULT '{}'::jsonb,
    is_enabled      boolean NOT NULL DEFAULT true,
    UNIQUE(section_id, code)
);

-- ui_widget.config is where we store:
-- - which metric codes to show
-- - which entity/table to read from
-- - which fields to display
-- - how to render (chart type, filters, etc.)

-------------------------
-- 7. Helpful indexes
-------------------------
CREATE INDEX IF NOT EXISTS idx_server_code ON server(code);
CREATE INDEX IF NOT EXISTS idx_metric_timeseries_metric_ts ON metric_timeseries(metric_id, ts);
CREATE INDEX IF NOT EXISTS idx_metric_timeseries_dims ON metric_timeseries USING gin(dimensions);
CREATE INDEX IF NOT EXISTS idx_customization_area ON customization(area);
CREATE INDEX IF NOT EXISTS idx_capture_session_started_at ON capture_session(started_at);

