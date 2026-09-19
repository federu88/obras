-- =============================================================================
-- 0020_conciliacion.sql
--
-- Herramienta de chequeo: compara lo que dicen las planillas contra lo que
-- efectivamente está cargado en el sistema, y marca las diferencias.
--
-- El problema real que resuelve: mientras conviven los Excel informales y el
-- sistema, nadie sabe cuál de los dos tiene razón. Guardar el valor de
-- referencia CON SU FUENTE permite ver la brecha en vez de discutirla, y ver
-- cómo se achica a medida que se carga lo que falta.
--
-- Una referencia no se corrige: se carga una nueva con fecha posterior. La
-- conciliación usa la más reciente de cada concepto, y las viejas quedan como
-- historia de cómo fue cambiando el número "oficial".
-- =============================================================================

create type reference_concept as enum (
  'capital_aportado',  -- lo que los socios pusieron
  'costo_total',       -- lo que costó la obra
  'venta',             -- por cuánto se vendió
  'utilidad'           -- el resultado
);

create table public.project_references (
  id             uuid primary key default gen_random_uuid(),
  project_id     uuid not null references public.projects(id) on delete cascade,
  concepto       reference_concept not null,
  valor_usd      numeric(18,2) not null,
  fuente         text not null,
  reference_date date not null default current_date,
  note           text,
  created_by     uuid references public.profiles(id),
  created_at     timestamptz not null default now()
);

create index project_references_idx
  on public.project_references (project_id, concepto, reference_date desc);

comment on table public.project_references is
  'Valores "oficiales" según las planillas, para contrastar contra lo cargado.';

-- -----------------------------------------------------------------------------
-- La referencia vigente de cada concepto: la más reciente.
-- -----------------------------------------------------------------------------
create view public.project_reference_current as
select distinct on (project_id, concepto)
  project_id, concepto, valor_usd, fuente, reference_date, note
from public.project_references
order by project_id, concepto, reference_date desc, created_at desc;

-- -----------------------------------------------------------------------------
-- project_reconciliation — referencia contra cargado, concepto por concepto.
--
-- El estado es una ayuda, no un juicio: "revisar" quiere decir que los dos
-- números no coinciden, no que alguno esté mal. Puede faltar cargar gastos,
-- o la planilla puede estar vieja.
-- -----------------------------------------------------------------------------
create view public.project_reconciliation as
with cargado as (
  select
    p.id as project_id,
    p.code,
    p.name,
    coalesce(pc.capital_aportado_usd, 0) as capital_aportado,
    coalesce(pn.actual_cost_usd, 0)      as costo_total,
    coalesce(pn.revenue_usd, 0)          as venta,
    coalesce(pn.revenue_usd, 0) - coalesce(pn.actual_cost_usd, 0) as utilidad
  from public.projects p
  left join public.project_capital pc on pc.project_id = p.id
  left join public.project_pnl pn     on pn.project_id = p.id
),
largo as (
  select project_id, code, name, 'capital_aportado'::reference_concept as concepto, capital_aportado as valor from cargado
  union all
  select project_id, code, name, 'costo_total', costo_total from cargado
  union all
  select project_id, code, name, 'venta', venta from cargado
  union all
  select project_id, code, name, 'utilidad', utilidad from cargado
)
select
  l.project_id,
  l.code,
  l.name,
  l.concepto,
  r.valor_usd            as referencia_usd,
  l.valor                as cargado_usd,
  r.valor_usd - l.valor  as diferencia_usd,
  case when r.valor_usd is null or r.valor_usd = 0 then null
       else round((r.valor_usd - l.valor) / abs(r.valor_usd), 4)
  end                    as diferencia_rel,
  r.fuente,
  r.reference_date,
  case
    when r.valor_usd is null                              then 'sin_referencia'
    when abs(r.valor_usd - l.valor) < 1                   then 'ok'
    when abs(r.valor_usd - l.valor) <= greatest(abs(r.valor_usd) * 0.01, 50)
                                                          then 'menor'
    else 'revisar'
  end                    as estado
from largo l
left join public.project_reference_current r
       on r.project_id = l.project_id and r.concepto = l.concepto;

-- -----------------------------------------------------------------------------
-- conciliacion_resumen — una fila por obra: cuánto falta cargar en total.
-- -----------------------------------------------------------------------------
create view public.conciliacion_resumen as
select
  project_id,
  code,
  name,
  count(*) filter (where estado = 'revisar')         as conceptos_a_revisar,
  count(*) filter (where estado = 'sin_referencia')  as conceptos_sin_referencia,
  max(abs(diferencia_usd)) filter (where estado = 'revisar') as peor_diferencia_usd,
  sum(diferencia_usd) filter (where concepto = 'costo_total') as falta_cargar_costo_usd
from public.project_reconciliation
group by project_id, code, name;

-- -----------------------------------------------------------------------------
-- RLS
-- -----------------------------------------------------------------------------
alter table public.project_references enable row level security;

create policy project_references_select on public.project_references
  for select to authenticated using (public.has_project_access(project_id));

create policy project_references_write on public.project_references
  for all to authenticated
  using (public.can_manage()) with check (public.can_manage());

alter view public.project_reference_current set (security_invoker = on);
alter view public.project_reconciliation    set (security_invoker = on);
alter view public.conciliacion_resumen      set (security_invoker = on);

grant select on
  public.project_references, public.project_reference_current,
  public.project_reconciliation, public.conciliacion_resumen
  to authenticated;

grant insert, update on public.project_references to authenticated;
