--
-- PostgreSQL database dump
--

\restrict ZYoajPCJcYRMSeQwiTurlmjRSsuIwUGBC7cA2RsUKQgZvvm3A74auf3W5KhdvbY

-- Dumped from database version 14.20
-- Dumped by pg_dump version 14.20

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: app_module; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.app_module (
    id bigint NOT NULL,
    code text NOT NULL,
    name text NOT NULL,
    type text,
    description text,
    is_enabled boolean DEFAULT true NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL
);


ALTER TABLE public.app_module OWNER TO postgres;

--
-- Name: app_module_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.app_module_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.app_module_id_seq OWNER TO postgres;

--
-- Name: app_module_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.app_module_id_seq OWNED BY public.app_module.id;


--
-- Name: campaign; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.campaign (
    id bigint NOT NULL,
    name text NOT NULL,
    type text NOT NULL,
    system_ref text,
    is_active boolean DEFAULT true NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL
);


ALTER TABLE public.campaign OWNER TO postgres;

--
-- Name: campaign_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.campaign_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.campaign_id_seq OWNER TO postgres;

--
-- Name: campaign_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.campaign_id_seq OWNED BY public.campaign.id;


--
-- Name: capture_session; Type: TABLE; Schema: public; Owner: pervasivecx
--

CREATE TABLE public.capture_session (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    started_at timestamp with time zone DEFAULT now() NOT NULL,
    ended_at timestamp with time zone,
    trigger_type text DEFAULT 'manual'::text NOT NULL,
    triggered_by text,
    status text DEFAULT 'running'::text NOT NULL,
    notes text
);


ALTER TABLE public.capture_session OWNER TO pervasivecx;

--
-- Name: crm_integration; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.crm_integration (
    id bigint NOT NULL,
    name text NOT NULL,
    vendor text,
    approach text,
    endpoint text,
    mapping_config jsonb DEFAULT '{}'::jsonb NOT NULL,
    is_active boolean DEFAULT true NOT NULL
);


ALTER TABLE public.crm_integration OWNER TO postgres;

--
-- Name: crm_integration_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.crm_integration_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.crm_integration_id_seq OWNER TO postgres;

--
-- Name: crm_integration_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.crm_integration_id_seq OWNED BY public.crm_integration.id;


--
-- Name: custom_report; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.custom_report (
    id bigint NOT NULL,
    name text NOT NULL,
    description text,
    category text,
    query_ref text,
    schedule text,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    is_active boolean DEFAULT true NOT NULL
);


ALTER TABLE public.custom_report OWNER TO postgres;

--
-- Name: custom_report_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.custom_report_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.custom_report_id_seq OWNER TO postgres;

--
-- Name: custom_report_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.custom_report_id_seq OWNED BY public.custom_report.id;


--
-- Name: customization; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.customization (
    id bigint NOT NULL,
    area text NOT NULL,
    title text NOT NULL,
    description text,
    module_code text,
    impact_level text,
    owner text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL
);


ALTER TABLE public.customization OWNER TO postgres;

--
-- Name: customization_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.customization_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.customization_id_seq OWNER TO postgres;

--
-- Name: customization_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.customization_id_seq OWNED BY public.customization.id;


--
-- Name: db_snapshot; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.db_snapshot (
    id bigint NOT NULL,
    capture_session_id uuid,
    server_id bigint,
    db_name text NOT NULL,
    size_mb numeric(18,2),
    min_data_ts timestamp with time zone,
    max_data_ts timestamp with time zone,
    extra_info jsonb DEFAULT '{}'::jsonb NOT NULL,
    collected_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.db_snapshot OWNER TO postgres;

--
-- Name: db_snapshot_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.db_snapshot_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.db_snapshot_id_seq OWNER TO postgres;

--
-- Name: db_snapshot_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.db_snapshot_id_seq OWNED BY public.db_snapshot.id;


--
-- Name: ftp_connection; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ftp_connection (
    id bigint NOT NULL,
    server_id bigint NOT NULL,
    capture_session_id uuid,
    name text NOT NULL,
    host text NOT NULL,
    port integer,
    username text,
    is_sftp boolean DEFAULT false NOT NULL,
    options jsonb DEFAULT '{}'::jsonb NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    collected_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.ftp_connection OWNER TO postgres;

--
-- Name: ftp_connection_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.ftp_connection_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ftp_connection_id_seq OWNER TO postgres;

--
-- Name: ftp_connection_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.ftp_connection_id_seq OWNED BY public.ftp_connection.id;


--
-- Name: license_snapshot; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.license_snapshot (
    id bigint NOT NULL,
    capture_session_id uuid,
    server_id bigint,
    raw_output text NOT NULL,
    parsed_json jsonb DEFAULT '{}'::jsonb NOT NULL,
    collected_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.license_snapshot OWNER TO postgres;

--
-- Name: license_snapshot_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.license_snapshot_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.license_snapshot_id_seq OWNER TO postgres;

--
-- Name: license_snapshot_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.license_snapshot_id_seq OWNED BY public.license_snapshot.id;


--
-- Name: media_profile; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.media_profile (
    id bigint NOT NULL,
    name text NOT NULL,
    channel_type text NOT NULL,
    config jsonb DEFAULT '{}'::jsonb NOT NULL,
    is_active boolean DEFAULT true NOT NULL
);


ALTER TABLE public.media_profile OWNER TO postgres;

--
-- Name: media_profile_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.media_profile_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.media_profile_id_seq OWNER TO postgres;

--
-- Name: media_profile_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.media_profile_id_seq OWNED BY public.media_profile.id;


--
-- Name: metric_definition; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.metric_definition (
    id bigint NOT NULL,
    code text NOT NULL,
    name text NOT NULL,
    category text NOT NULL,
    unit text,
    description text,
    aggregation text,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL
);


ALTER TABLE public.metric_definition OWNER TO postgres;

--
-- Name: metric_definition_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.metric_definition_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.metric_definition_id_seq OWNER TO postgres;

--
-- Name: metric_definition_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.metric_definition_id_seq OWNED BY public.metric_definition.id;


--
-- Name: metric_timeseries; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.metric_timeseries (
    id bigint NOT NULL,
    metric_id bigint NOT NULL,
    capture_session_id uuid,
    server_id bigint,
    campaign_id bigint,
    ts timestamp with time zone NOT NULL,
    value numeric(18,4) NOT NULL,
    dimensions jsonb DEFAULT '{}'::jsonb NOT NULL
);


ALTER TABLE public.metric_timeseries OWNER TO postgres;

--
-- Name: metric_timeseries_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.metric_timeseries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.metric_timeseries_id_seq OWNER TO postgres;

--
-- Name: metric_timeseries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.metric_timeseries_id_seq OWNED BY public.metric_timeseries.id;


--
-- Name: nas_connection; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.nas_connection (
    id bigint NOT NULL,
    server_id bigint NOT NULL,
    capture_session_id uuid,
    name text NOT NULL,
    mount_point text NOT NULL,
    endpoint text,
    protocol text,
    options jsonb DEFAULT '{}'::jsonb NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    collected_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.nas_connection OWNER TO postgres;

--
-- Name: nas_connection_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.nas_connection_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.nas_connection_id_seq OWNER TO postgres;

--
-- Name: nas_connection_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.nas_connection_id_seq OWNED BY public.nas_connection.id;


--
-- Name: qa_parameter; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.qa_parameter (
    id bigint NOT NULL,
    name text NOT NULL,
    category text,
    description text,
    max_score numeric(10,2),
    weight numeric(10,2),
    is_active boolean DEFAULT true NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL
);


ALTER TABLE public.qa_parameter OWNER TO postgres;

--
-- Name: qa_parameter_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.qa_parameter_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.qa_parameter_id_seq OWNER TO postgres;

--
-- Name: qa_parameter_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.qa_parameter_id_seq OWNED BY public.qa_parameter.id;


--
-- Name: rpm_package; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rpm_package (
    id bigint NOT NULL,
    server_id bigint NOT NULL,
    capture_session_id uuid,
    name text NOT NULL,
    version text,
    release text,
    arch text,
    is_ameyo_rpm boolean DEFAULT false NOT NULL,
    dependencies jsonb DEFAULT '[]'::jsonb NOT NULL,
    installed_at timestamp with time zone,
    collected_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.rpm_package OWNER TO postgres;

--
-- Name: rpm_package_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.rpm_package_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.rpm_package_id_seq OWNER TO postgres;

--
-- Name: rpm_package_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.rpm_package_id_seq OWNED BY public.rpm_package.id;


--
-- Name: rule_engine; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rule_engine (
    id bigint NOT NULL,
    name text NOT NULL,
    type text,
    description text,
    config jsonb DEFAULT '{}'::jsonb NOT NULL,
    is_active boolean DEFAULT true NOT NULL
);


ALTER TABLE public.rule_engine OWNER TO postgres;

--
-- Name: rule_engine_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.rule_engine_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.rule_engine_id_seq OWNER TO postgres;

--
-- Name: rule_engine_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.rule_engine_id_seq OWNED BY public.rule_engine.id;


--
-- Name: server; Type: TABLE; Schema: public; Owner: pervasivecx
--

CREATE TABLE public.server (
    id bigint NOT NULL,
    code text NOT NULL,
    hostname text NOT NULL,
    ip_address text,
    environment text,
    os_name text,
    os_version text,
    cpu_cores integer,
    ram_mb integer,
    tags jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.server OWNER TO pervasivecx;

--
-- Name: server_id_seq; Type: SEQUENCE; Schema: public; Owner: pervasivecx
--

CREATE SEQUENCE public.server_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.server_id_seq OWNER TO pervasivecx;

--
-- Name: server_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pervasivecx
--

ALTER SEQUENCE public.server_id_seq OWNED BY public.server.id;


--
-- Name: server_volume; Type: TABLE; Schema: public; Owner: pervasivecx
--

CREATE TABLE public.server_volume (
    id bigint NOT NULL,
    server_id bigint NOT NULL,
    capture_session_id uuid,
    mount_point text NOT NULL,
    filesystem_type text,
    total_gb numeric(12,2),
    used_gb numeric(12,2),
    available_gb numeric(12,2),
    usage_percent numeric(5,2),
    raw_df_output text,
    collected_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.server_volume OWNER TO pervasivecx;

--
-- Name: server_volume_id_seq; Type: SEQUENCE; Schema: public; Owner: pervasivecx
--

CREATE SEQUENCE public.server_volume_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.server_volume_id_seq OWNER TO pervasivecx;

--
-- Name: server_volume_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pervasivecx
--

ALTER SEQUENCE public.server_volume_id_seq OWNED BY public.server_volume.id;


--
-- Name: service_instance; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.service_instance (
    id bigint NOT NULL,
    server_id bigint NOT NULL,
    capture_session_id uuid,
    name text NOT NULL,
    type text,
    status text,
    port integer,
    extra_info jsonb DEFAULT '{}'::jsonb NOT NULL,
    collected_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.service_instance OWNER TO postgres;

--
-- Name: service_instance_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.service_instance_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.service_instance_id_seq OWNER TO postgres;

--
-- Name: service_instance_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.service_instance_id_seq OWNED BY public.service_instance.id;


--
-- Name: ui_section; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ui_section (
    id bigint NOT NULL,
    tab_id bigint NOT NULL,
    code text NOT NULL,
    title text NOT NULL,
    subtitle text,
    sort_order integer DEFAULT 0 NOT NULL,
    is_enabled boolean DEFAULT true NOT NULL
);


ALTER TABLE public.ui_section OWNER TO postgres;

--
-- Name: ui_section_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.ui_section_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ui_section_id_seq OWNER TO postgres;

--
-- Name: ui_section_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.ui_section_id_seq OWNED BY public.ui_section.id;


--
-- Name: ui_tab; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ui_tab (
    id bigint NOT NULL,
    code text NOT NULL,
    title text NOT NULL,
    icon text,
    sort_order integer DEFAULT 0 NOT NULL,
    is_default boolean DEFAULT false NOT NULL,
    is_enabled boolean DEFAULT true NOT NULL
);


ALTER TABLE public.ui_tab OWNER TO postgres;

--
-- Name: ui_tab_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.ui_tab_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ui_tab_id_seq OWNER TO postgres;

--
-- Name: ui_tab_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.ui_tab_id_seq OWNED BY public.ui_tab.id;


--
-- Name: ui_widget; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ui_widget (
    id bigint NOT NULL,
    section_id bigint NOT NULL,
    code text NOT NULL,
    title text NOT NULL,
    widget_type text NOT NULL,
    sort_order integer DEFAULT 0 NOT NULL,
    config jsonb DEFAULT '{}'::jsonb NOT NULL,
    is_enabled boolean DEFAULT true NOT NULL
);


ALTER TABLE public.ui_widget OWNER TO postgres;

--
-- Name: ui_widget_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.ui_widget_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ui_widget_id_seq OWNER TO postgres;

--
-- Name: ui_widget_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.ui_widget_id_seq OWNED BY public.ui_widget.id;


--
-- Name: app_module id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.app_module ALTER COLUMN id SET DEFAULT nextval('public.app_module_id_seq'::regclass);


--
-- Name: campaign id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.campaign ALTER COLUMN id SET DEFAULT nextval('public.campaign_id_seq'::regclass);


--
-- Name: crm_integration id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.crm_integration ALTER COLUMN id SET DEFAULT nextval('public.crm_integration_id_seq'::regclass);


--
-- Name: custom_report id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.custom_report ALTER COLUMN id SET DEFAULT nextval('public.custom_report_id_seq'::regclass);


--
-- Name: customization id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customization ALTER COLUMN id SET DEFAULT nextval('public.customization_id_seq'::regclass);


--
-- Name: db_snapshot id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.db_snapshot ALTER COLUMN id SET DEFAULT nextval('public.db_snapshot_id_seq'::regclass);


--
-- Name: ftp_connection id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ftp_connection ALTER COLUMN id SET DEFAULT nextval('public.ftp_connection_id_seq'::regclass);


--
-- Name: license_snapshot id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.license_snapshot ALTER COLUMN id SET DEFAULT nextval('public.license_snapshot_id_seq'::regclass);


--
-- Name: media_profile id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.media_profile ALTER COLUMN id SET DEFAULT nextval('public.media_profile_id_seq'::regclass);


--
-- Name: metric_definition id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.metric_definition ALTER COLUMN id SET DEFAULT nextval('public.metric_definition_id_seq'::regclass);


--
-- Name: metric_timeseries id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.metric_timeseries ALTER COLUMN id SET DEFAULT nextval('public.metric_timeseries_id_seq'::regclass);


--
-- Name: nas_connection id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.nas_connection ALTER COLUMN id SET DEFAULT nextval('public.nas_connection_id_seq'::regclass);


--
-- Name: qa_parameter id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.qa_parameter ALTER COLUMN id SET DEFAULT nextval('public.qa_parameter_id_seq'::regclass);


--
-- Name: rpm_package id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rpm_package ALTER COLUMN id SET DEFAULT nextval('public.rpm_package_id_seq'::regclass);


--
-- Name: rule_engine id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rule_engine ALTER COLUMN id SET DEFAULT nextval('public.rule_engine_id_seq'::regclass);


--
-- Name: server id; Type: DEFAULT; Schema: public; Owner: pervasivecx
--

ALTER TABLE ONLY public.server ALTER COLUMN id SET DEFAULT nextval('public.server_id_seq'::regclass);


--
-- Name: server_volume id; Type: DEFAULT; Schema: public; Owner: pervasivecx
--

ALTER TABLE ONLY public.server_volume ALTER COLUMN id SET DEFAULT nextval('public.server_volume_id_seq'::regclass);


--
-- Name: service_instance id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.service_instance ALTER COLUMN id SET DEFAULT nextval('public.service_instance_id_seq'::regclass);


--
-- Name: ui_section id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ui_section ALTER COLUMN id SET DEFAULT nextval('public.ui_section_id_seq'::regclass);


--
-- Name: ui_tab id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ui_tab ALTER COLUMN id SET DEFAULT nextval('public.ui_tab_id_seq'::regclass);


--
-- Name: ui_widget id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ui_widget ALTER COLUMN id SET DEFAULT nextval('public.ui_widget_id_seq'::regclass);


--
-- Name: app_module app_module_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.app_module
    ADD CONSTRAINT app_module_code_key UNIQUE (code);


--
-- Name: app_module app_module_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.app_module
    ADD CONSTRAINT app_module_pkey PRIMARY KEY (id);


--
-- Name: campaign campaign_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.campaign
    ADD CONSTRAINT campaign_pkey PRIMARY KEY (id);


--
-- Name: capture_session capture_session_pkey; Type: CONSTRAINT; Schema: public; Owner: pervasivecx
--

ALTER TABLE ONLY public.capture_session
    ADD CONSTRAINT capture_session_pkey PRIMARY KEY (id);


--
-- Name: crm_integration crm_integration_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.crm_integration
    ADD CONSTRAINT crm_integration_pkey PRIMARY KEY (id);


--
-- Name: custom_report custom_report_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.custom_report
    ADD CONSTRAINT custom_report_pkey PRIMARY KEY (id);


--
-- Name: customization customization_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customization
    ADD CONSTRAINT customization_pkey PRIMARY KEY (id);


--
-- Name: db_snapshot db_snapshot_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.db_snapshot
    ADD CONSTRAINT db_snapshot_pkey PRIMARY KEY (id);


--
-- Name: ftp_connection ftp_connection_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ftp_connection
    ADD CONSTRAINT ftp_connection_pkey PRIMARY KEY (id);


--
-- Name: license_snapshot license_snapshot_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.license_snapshot
    ADD CONSTRAINT license_snapshot_pkey PRIMARY KEY (id);


--
-- Name: media_profile media_profile_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.media_profile
    ADD CONSTRAINT media_profile_pkey PRIMARY KEY (id);


--
-- Name: metric_definition metric_definition_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.metric_definition
    ADD CONSTRAINT metric_definition_code_key UNIQUE (code);


--
-- Name: metric_definition metric_definition_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.metric_definition
    ADD CONSTRAINT metric_definition_pkey PRIMARY KEY (id);


--
-- Name: metric_timeseries metric_timeseries_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.metric_timeseries
    ADD CONSTRAINT metric_timeseries_pkey PRIMARY KEY (id);


--
-- Name: nas_connection nas_connection_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.nas_connection
    ADD CONSTRAINT nas_connection_pkey PRIMARY KEY (id);


--
-- Name: qa_parameter qa_parameter_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.qa_parameter
    ADD CONSTRAINT qa_parameter_pkey PRIMARY KEY (id);


--
-- Name: rpm_package rpm_package_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rpm_package
    ADD CONSTRAINT rpm_package_pkey PRIMARY KEY (id);


--
-- Name: rule_engine rule_engine_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rule_engine
    ADD CONSTRAINT rule_engine_pkey PRIMARY KEY (id);


--
-- Name: server server_code_key; Type: CONSTRAINT; Schema: public; Owner: pervasivecx
--

ALTER TABLE ONLY public.server
    ADD CONSTRAINT server_code_key UNIQUE (code);


--
-- Name: server server_pkey; Type: CONSTRAINT; Schema: public; Owner: pervasivecx
--

ALTER TABLE ONLY public.server
    ADD CONSTRAINT server_pkey PRIMARY KEY (id);


--
-- Name: server_volume server_volume_pkey; Type: CONSTRAINT; Schema: public; Owner: pervasivecx
--

ALTER TABLE ONLY public.server_volume
    ADD CONSTRAINT server_volume_pkey PRIMARY KEY (id);


--
-- Name: service_instance service_instance_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.service_instance
    ADD CONSTRAINT service_instance_pkey PRIMARY KEY (id);


--
-- Name: ui_section ui_section_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ui_section
    ADD CONSTRAINT ui_section_pkey PRIMARY KEY (id);


--
-- Name: ui_section ui_section_tab_id_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ui_section
    ADD CONSTRAINT ui_section_tab_id_code_key UNIQUE (tab_id, code);


--
-- Name: ui_tab ui_tab_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ui_tab
    ADD CONSTRAINT ui_tab_code_key UNIQUE (code);


--
-- Name: ui_tab ui_tab_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ui_tab
    ADD CONSTRAINT ui_tab_pkey PRIMARY KEY (id);


--
-- Name: ui_widget ui_widget_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ui_widget
    ADD CONSTRAINT ui_widget_pkey PRIMARY KEY (id);


--
-- Name: ui_widget ui_widget_section_id_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ui_widget
    ADD CONSTRAINT ui_widget_section_id_code_key UNIQUE (section_id, code);


--
-- Name: idx_capture_session_started_at; Type: INDEX; Schema: public; Owner: pervasivecx
--

CREATE INDEX idx_capture_session_started_at ON public.capture_session USING btree (started_at);


--
-- Name: idx_customization_area; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_customization_area ON public.customization USING btree (area);


--
-- Name: idx_metric_timeseries_dims; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_metric_timeseries_dims ON public.metric_timeseries USING gin (dimensions);


--
-- Name: idx_metric_timeseries_metric_ts; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_metric_timeseries_metric_ts ON public.metric_timeseries USING btree (metric_id, ts);


--
-- Name: idx_server_code; Type: INDEX; Schema: public; Owner: pervasivecx
--

CREATE INDEX idx_server_code ON public.server USING btree (code);


--
-- Name: customization customization_module_code_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customization
    ADD CONSTRAINT customization_module_code_fkey FOREIGN KEY (module_code) REFERENCES public.app_module(code);


--
-- Name: db_snapshot db_snapshot_capture_session_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.db_snapshot
    ADD CONSTRAINT db_snapshot_capture_session_id_fkey FOREIGN KEY (capture_session_id) REFERENCES public.capture_session(id);


--
-- Name: db_snapshot db_snapshot_server_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.db_snapshot
    ADD CONSTRAINT db_snapshot_server_id_fkey FOREIGN KEY (server_id) REFERENCES public.server(id) ON DELETE SET NULL;


--
-- Name: ftp_connection ftp_connection_capture_session_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ftp_connection
    ADD CONSTRAINT ftp_connection_capture_session_id_fkey FOREIGN KEY (capture_session_id) REFERENCES public.capture_session(id);


--
-- Name: ftp_connection ftp_connection_server_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ftp_connection
    ADD CONSTRAINT ftp_connection_server_id_fkey FOREIGN KEY (server_id) REFERENCES public.server(id) ON DELETE CASCADE;


--
-- Name: license_snapshot license_snapshot_capture_session_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.license_snapshot
    ADD CONSTRAINT license_snapshot_capture_session_id_fkey FOREIGN KEY (capture_session_id) REFERENCES public.capture_session(id);


--
-- Name: license_snapshot license_snapshot_server_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.license_snapshot
    ADD CONSTRAINT license_snapshot_server_id_fkey FOREIGN KEY (server_id) REFERENCES public.server(id) ON DELETE SET NULL;


--
-- Name: metric_timeseries metric_timeseries_campaign_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.metric_timeseries
    ADD CONSTRAINT metric_timeseries_campaign_id_fkey FOREIGN KEY (campaign_id) REFERENCES public.campaign(id) ON DELETE SET NULL;


--
-- Name: metric_timeseries metric_timeseries_capture_session_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.metric_timeseries
    ADD CONSTRAINT metric_timeseries_capture_session_id_fkey FOREIGN KEY (capture_session_id) REFERENCES public.capture_session(id);


--
-- Name: metric_timeseries metric_timeseries_metric_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.metric_timeseries
    ADD CONSTRAINT metric_timeseries_metric_id_fkey FOREIGN KEY (metric_id) REFERENCES public.metric_definition(id) ON DELETE CASCADE;


--
-- Name: metric_timeseries metric_timeseries_server_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.metric_timeseries
    ADD CONSTRAINT metric_timeseries_server_id_fkey FOREIGN KEY (server_id) REFERENCES public.server(id) ON DELETE SET NULL;


--
-- Name: nas_connection nas_connection_capture_session_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.nas_connection
    ADD CONSTRAINT nas_connection_capture_session_id_fkey FOREIGN KEY (capture_session_id) REFERENCES public.capture_session(id);


--
-- Name: nas_connection nas_connection_server_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.nas_connection
    ADD CONSTRAINT nas_connection_server_id_fkey FOREIGN KEY (server_id) REFERENCES public.server(id) ON DELETE CASCADE;


--
-- Name: rpm_package rpm_package_capture_session_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rpm_package
    ADD CONSTRAINT rpm_package_capture_session_id_fkey FOREIGN KEY (capture_session_id) REFERENCES public.capture_session(id);


--
-- Name: rpm_package rpm_package_server_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rpm_package
    ADD CONSTRAINT rpm_package_server_id_fkey FOREIGN KEY (server_id) REFERENCES public.server(id) ON DELETE CASCADE;


--
-- Name: server_volume server_volume_capture_session_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pervasivecx
--

ALTER TABLE ONLY public.server_volume
    ADD CONSTRAINT server_volume_capture_session_id_fkey FOREIGN KEY (capture_session_id) REFERENCES public.capture_session(id);


--
-- Name: server_volume server_volume_server_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pervasivecx
--

ALTER TABLE ONLY public.server_volume
    ADD CONSTRAINT server_volume_server_id_fkey FOREIGN KEY (server_id) REFERENCES public.server(id) ON DELETE CASCADE;


--
-- Name: service_instance service_instance_capture_session_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.service_instance
    ADD CONSTRAINT service_instance_capture_session_id_fkey FOREIGN KEY (capture_session_id) REFERENCES public.capture_session(id);


--
-- Name: service_instance service_instance_server_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.service_instance
    ADD CONSTRAINT service_instance_server_id_fkey FOREIGN KEY (server_id) REFERENCES public.server(id) ON DELETE CASCADE;


--
-- Name: ui_section ui_section_tab_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ui_section
    ADD CONSTRAINT ui_section_tab_id_fkey FOREIGN KEY (tab_id) REFERENCES public.ui_tab(id) ON DELETE CASCADE;


--
-- Name: ui_widget ui_widget_section_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ui_widget
    ADD CONSTRAINT ui_widget_section_id_fkey FOREIGN KEY (section_id) REFERENCES public.ui_section(id) ON DELETE CASCADE;


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: pervasivecx
--

REVOKE ALL ON SCHEMA public FROM postgres;
REVOKE ALL ON SCHEMA public FROM PUBLIC;
GRANT ALL ON SCHEMA public TO pervasivecx;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- Name: TABLE app_module; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.app_module TO pervasivecx;


--
-- Name: SEQUENCE app_module_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.app_module_id_seq TO pervasivecx;


--
-- Name: TABLE campaign; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.campaign TO pervasivecx;


--
-- Name: SEQUENCE campaign_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.campaign_id_seq TO pervasivecx;


--
-- Name: TABLE crm_integration; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.crm_integration TO pervasivecx;


--
-- Name: SEQUENCE crm_integration_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.crm_integration_id_seq TO pervasivecx;


--
-- Name: TABLE custom_report; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.custom_report TO pervasivecx;


--
-- Name: SEQUENCE custom_report_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.custom_report_id_seq TO pervasivecx;


--
-- Name: TABLE customization; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.customization TO pervasivecx;


--
-- Name: SEQUENCE customization_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.customization_id_seq TO pervasivecx;


--
-- Name: TABLE db_snapshot; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.db_snapshot TO pervasivecx;


--
-- Name: SEQUENCE db_snapshot_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.db_snapshot_id_seq TO pervasivecx;


--
-- Name: TABLE ftp_connection; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.ftp_connection TO pervasivecx;


--
-- Name: SEQUENCE ftp_connection_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.ftp_connection_id_seq TO pervasivecx;


--
-- Name: TABLE license_snapshot; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.license_snapshot TO pervasivecx;


--
-- Name: SEQUENCE license_snapshot_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.license_snapshot_id_seq TO pervasivecx;


--
-- Name: TABLE media_profile; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.media_profile TO pervasivecx;


--
-- Name: SEQUENCE media_profile_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.media_profile_id_seq TO pervasivecx;


--
-- Name: TABLE metric_definition; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.metric_definition TO pervasivecx;


--
-- Name: SEQUENCE metric_definition_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.metric_definition_id_seq TO pervasivecx;


--
-- Name: TABLE metric_timeseries; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.metric_timeseries TO pervasivecx;


--
-- Name: SEQUENCE metric_timeseries_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.metric_timeseries_id_seq TO pervasivecx;


--
-- Name: TABLE nas_connection; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.nas_connection TO pervasivecx;


--
-- Name: SEQUENCE nas_connection_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.nas_connection_id_seq TO pervasivecx;


--
-- Name: TABLE qa_parameter; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.qa_parameter TO pervasivecx;


--
-- Name: SEQUENCE qa_parameter_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.qa_parameter_id_seq TO pervasivecx;


--
-- Name: TABLE rpm_package; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.rpm_package TO pervasivecx;


--
-- Name: SEQUENCE rpm_package_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.rpm_package_id_seq TO pervasivecx;


--
-- Name: TABLE rule_engine; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.rule_engine TO pervasivecx;


--
-- Name: SEQUENCE rule_engine_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.rule_engine_id_seq TO pervasivecx;


--
-- Name: TABLE service_instance; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.service_instance TO pervasivecx;


--
-- Name: SEQUENCE service_instance_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.service_instance_id_seq TO pervasivecx;


--
-- Name: TABLE ui_section; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.ui_section TO pervasivecx;


--
-- Name: SEQUENCE ui_section_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.ui_section_id_seq TO pervasivecx;


--
-- Name: TABLE ui_tab; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.ui_tab TO pervasivecx;


--
-- Name: SEQUENCE ui_tab_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.ui_tab_id_seq TO pervasivecx;


--
-- Name: TABLE ui_widget; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.ui_widget TO pervasivecx;


--
-- Name: SEQUENCE ui_widget_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.ui_widget_id_seq TO pervasivecx;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES  TO pervasivecx;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES  TO pervasivecx;


--
-- PostgreSQL database dump complete
--

\unrestrict ZYoajPCJcYRMSeQwiTurlmjRSsuIwUGBC7cA2RsUKQgZvvm3A74auf3W5KhdvbY

