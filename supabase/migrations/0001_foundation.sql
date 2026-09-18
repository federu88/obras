-- =============================================================================
-- 0001_foundation.sql  ·  Fase 1 — Foundation
-- Identidad, roles, proyectos y la base monetaria (FX).
-- =============================================================================

create extension if not exists "pgcrypto";

-- -----------------------------------------------------------------------------
-- Enums
-- -----------------------------------------------------------------------------
create type app_role as enum ('admin', 'manager', 'viewer', 'investor');

create type project_status as enum (
  'idea', 'evaluacion', 'aprobado', 'en_construccion',
  'terminado', 'vendido', 'cerrado'
);

-- El rol dentro de UN proyecto. Distinto del rol global: alguien puede ser
-- manager del negocio y a la vez inversor de una sola casa.
create type project_member_role as enum ('manager', 'arquitecto', 'inversor', 'viewer');

create type currency as enum ('ARS', 'USD');

-- -----------------------------------------------------------------------------
-- updated_at automatico
-- -----------------------------------------------------------------------------
create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $fn$
begin
  new.updated_at = now();
  return new;
end;
$fn$;

-- -----------------------------------------------------------------------------
-- profiles — extiende auth.users. Una fila por usuario que puede iniciar sesion.
-- -----------------------------------------------------------------------------
create table public.profiles (
  id          uuid primary key references auth.users(id) on delete cascade,
  full_name   text not null default '',
  email       text,
  phone       text,
  role        app_role not null default 'viewer',
  is_active   boolean not null default true,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

create trigger profiles_set_updated_at
  before update on public.profiles
  for each row execute function public.set_updated_at();

-- Alta automatica del perfil al registrarse un usuario.
-- Rol por defecto 'viewer': nadie nace con permisos de escritura.
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $fn$
begin
  insert into public.profiles (id, full_name, email)
  values (
    new.id,
    coalesce(new.raw_user_meta_data ->> 'full_name', ''),
    new.email
  );
  return new;
end;
$fn$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- -----------------------------------------------------------------------------
-- fx_rates — una sola fuente de verdad del tipo de cambio.
-- Existe desde la Fase 1 a proposito: el Excel actual hardcodea 1400 en cada
-- fila y por eso el presupuesto en USD quedo mal calculado. Aca la cotizacion
-- es un dato con fecha, no una constante repetida.
-- -----------------------------------------------------------------------------
create table public.fx_rates (
  id          uuid primary key default gen_random_uuid(),
  rate_date   date not null,
  source      text not null default 'MEP',   -- 'MEP' | 'oficial' | 'operacion'
  ars_per_usd numeric(18,4) not null check (ars_per_usd > 0),
  note        text,
  created_by  uuid references public.profiles(id),
  created_at  timestamptz not null default now(),
  unique (rate_date, source)
);

create index fx_rates_date_idx on public.fx_rates (rate_date desc);

-- Cotizacion vigente a una fecha: la mas reciente <= fecha pedida.
create or replace function public.fx_rate_at(p_date date, p_source text default 'MEP')
returns numeric
language sql
stable
as $fn$
  select ars_per_usd
  from public.fx_rates
  where rate_date <= p_date and source = p_source
  order by rate_date desc
  limit 1;
$fn$;

-- -----------------------------------------------------------------------------
-- projects — cada casa o desarrollo.
-- -----------------------------------------------------------------------------
create table public.projects (
  id                   uuid primary key default gen_random_uuid(),
  code                 text not null unique,
  name                 text not null,
  location             text,
  house_type           text,
  surface_m2           numeric(10,2) check (surface_m2 is null or surface_m2 > 0),
  status               project_status not null default 'idea',
  planned_start        date,
  planned_finish       date,
  actual_start         date,
  actual_finish        date,
  -- Business case. Todo en USD: el peso es moneda transaccional, no unidad
  -- de medida. Criterio heredado del modelo actual y mantenido a proposito.
  budget_usd           numeric(18,2) check (budget_usd is null or budget_usd >= 0),
  capital_required_usd numeric(18,2) check (capital_required_usd is null or capital_required_usd >= 0),
  target_sale_usd      numeric(18,2) check (target_sale_usd is null or target_sale_usd >= 0),
  broker_fee_pct       numeric(6,4) not null default 0.04 check (broker_fee_pct >= 0 and broker_fee_pct <= 1),
  is_demo              boolean not null default false,
  notes                text,
  created_by           uuid references public.profiles(id),
  created_at           timestamptz not null default now(),
  updated_at           timestamptz not null default now(),
  constraint projects_dates_coherent
    check (planned_finish is null or planned_start is null or planned_finish >= planned_start)
);

create trigger projects_set_updated_at
  before update on public.projects
  for each row execute function public.set_updated_at();

create index projects_status_idx on public.projects (status);

-- -----------------------------------------------------------------------------
-- project_members — quien ve que proyecto. Tabla llave de toda la seguridad.
-- -----------------------------------------------------------------------------
create table public.project_members (
  project_id  uuid not null references public.projects(id) on delete cascade,
  user_id     uuid not null references public.profiles(id) on delete cascade,
  role        project_member_role not null default 'viewer',
  created_at  timestamptz not null default now(),
  primary key (project_id, user_id)
);

create index project_members_user_idx on public.project_members (user_id);

-- -----------------------------------------------------------------------------
-- audit_log — trazabilidad. Los registros financieros no se borran.
-- -----------------------------------------------------------------------------
create table public.audit_log (
  id          bigserial primary key,
  table_name  text not null,
  record_id   text not null,
  action      text not null check (action in ('insert', 'update', 'delete')),
  changed_by  uuid references public.profiles(id),
  changed_at  timestamptz not null default now(),
  old_data    jsonb,
  new_data    jsonb
);

create index audit_log_record_idx on public.audit_log (table_name, record_id);

create or replace function public.log_audit()
returns trigger
language plpgsql
security definer
set search_path = public
as $fn$
begin
  insert into public.audit_log (table_name, record_id, action, changed_by, old_data, new_data)
  values (
    tg_table_name,
    coalesce(new.id::text, old.id::text),
    lower(tg_op),
    auth.uid(),
    case when tg_op = 'INSERT' then null else to_jsonb(old) end,
    case when tg_op = 'DELETE' then null else to_jsonb(new) end
  );
  return coalesce(new, old);
end;
$fn$;

create trigger projects_audit
  after insert or update or delete on public.projects
  for each row execute function public.log_audit();
