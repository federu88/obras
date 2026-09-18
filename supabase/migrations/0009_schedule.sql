-- =============================================================================
-- 0009_schedule.sql  ·  Fase 5 — Cronograma, Gantt y desvios de plazo
--
-- Replica la logica que ya funciona bien en la planilla: WORKDAY y NETWORKDAYS
-- contra un calendario de feriados. El avance se pondera por dias habiles
-- planificados, que es el criterio actual y se mantiene.
-- =============================================================================

create type task_status as enum (
  'no_iniciada', 'en_curso', 'terminada', 'demorada', 'bloqueada'
);

-- -----------------------------------------------------------------------------
-- holidays — calendario. Sin esto, WORKDAY no significa nada.
-- -----------------------------------------------------------------------------
create table public.holidays (
  day         date primary key,
  description text,
  created_at  timestamptz not null default now()
);

-- Los 29 feriados que ya estaban cargados en la hoja Listas (2025-2026).
insert into public.holidays (day) values
  ('2025-01-01'), ('2025-03-03'), ('2025-03-04'), ('2025-03-24'), ('2025-04-02'),
  ('2025-04-18'), ('2025-05-01'), ('2025-05-25'), ('2025-06-16'), ('2025-08-17'),
  ('2025-10-12'), ('2025-11-24'), ('2025-12-08'), ('2025-12-25'),
  ('2026-01-01'), ('2026-02-16'), ('2026-02-17'), ('2026-03-24'), ('2026-04-02'),
  ('2026-04-03'), ('2026-05-01'), ('2026-05-25'), ('2026-06-20'), ('2026-07-09'),
  ('2026-08-17'), ('2026-10-12'), ('2026-11-20'), ('2026-12-08'), ('2026-12-25');

-- -----------------------------------------------------------------------------
-- Aritmetica de dias habiles. Equivalen a WORKDAY() y NETWORKDAYS().
-- -----------------------------------------------------------------------------

-- Fecha resultante de sumar p_days dias habiles a p_start.
-- p_days = 0 devuelve la misma fecha, igual que WORKDAY(inicio, dias-1).
create or replace function public.add_workdays(p_start date, p_days int)
returns date
language plpgsql
stable
as $fn$
declare
  d         date := p_start;
  remaining int  := p_days;
begin
  if p_start is null or p_days is null then
    return null;
  end if;

  while remaining > 0 loop
    d := d + 1;
    if extract(isodow from d) < 6
       and not exists (select 1 from public.holidays h where h.day = d)
    then
      remaining := remaining - 1;
    end if;
  end loop;

  return d;
end;
$fn$;

-- Cantidad de dias habiles entre dos fechas, ambas inclusive.
create or replace function public.count_workdays(p_from date, p_to date)
returns int
language sql
stable
as $fn$
  select case
    when p_from is null or p_to is null or p_to < p_from then null
    else (
      select count(*)::int
      from generate_series(p_from, p_to, interval '1 day') g(d)
      where extract(isodow from g.d) < 6
        and not exists (select 1 from public.holidays h where h.day = g.d::date)
    )
  end;
$fn$;

-- -----------------------------------------------------------------------------
-- tasks — actividades del cronograma.
--
-- planned_finish se calcula, no se carga: es add_workdays(inicio, dias - 1),
-- exactamente WORKDAY(D3, E3-1, feriados) de la planilla.
-- -----------------------------------------------------------------------------
create table public.tasks (
  id              uuid primary key default gen_random_uuid(),
  project_id      uuid not null references public.projects(id) on delete cascade,
  category        text,
  name            text not null,
  sort_order      int not null default 0,

  planned_start   date,
  planned_days    int check (planned_days is null or planned_days > 0),
  planned_finish  date,                      -- derivada por trigger

  actual_start    date,
  actual_finish   date,

  status          task_status not null default 'no_iniciada',
  responsible     text,
  notes           text,

  is_demo         boolean not null default false,
  created_by      uuid references public.profiles(id),
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now(),

  constraint tasks_actual_coherent
    check (actual_finish is null or actual_start is null or actual_finish >= actual_start)
);

create trigger tasks_set_updated_at
  before update on public.tasks
  for each row execute function public.set_updated_at();

create index tasks_project_idx on public.tasks (project_id, sort_order);

-- Deriva la fecha de fin planificada y el estado FACTUAL segun las fechas
-- cargadas. El atraso NO se guarda aca: un trigger solo corre cuando la fila
-- se escribe, asi que una tarea que se atrasa mañana seguiria diciendo
-- "en curso" hasta que alguien la toque. El atraso se calcula al consultar.
-- 'bloqueada' es manual: lo pone una persona, no una regla.
create or replace function public.sync_task()
returns trigger
language plpgsql
as $fn$
begin
  if new.planned_start is not null and new.planned_days is not null then
    new.planned_finish := public.add_workdays(new.planned_start, new.planned_days - 1);
  else
    new.planned_finish := null;
  end if;

  if new.status <> 'bloqueada' then
    new.status := case
      when new.actual_finish is not null then 'terminada'
      when new.actual_start  is not null then 'en_curso'
      else 'no_iniciada'
    end;
  end if;

  return new;
end;
$fn$;

create trigger tasks_sync
  before insert or update on public.tasks
  for each row execute function public.sync_task();

-- -----------------------------------------------------------------------------
-- task_dependencies — una tarea no puede empezar antes de que termine otra.
-- -----------------------------------------------------------------------------
create table public.task_dependencies (
  task_id       uuid not null references public.tasks(id) on delete cascade,
  depends_on_id uuid not null references public.tasks(id) on delete cascade,
  lag_days      int not null default 0,
  created_at    timestamptz not null default now(),
  primary key (task_id, depends_on_id),
  constraint no_self_dependency check (task_id <> depends_on_id)
);

-- =============================================================================
-- VISTAS
-- =============================================================================

-- Plan vs real por actividad, con el peso y el desvio ya calculados.
--
-- El peso es dias habiles planificados sobre el total del proyecto: es el
-- criterio de la planilla actual y se mantiene. Ojo: mide avance FISICO, no
-- economico. Una tarea larga y barata pesa mas que una corta y cara.
create view public.task_schedule as
select
  t.id                       as task_id,
  t.project_id,
  t.category,
  t.name,
  t.sort_order,
  t.status,
  t.responsible,
  t.planned_start,
  t.planned_finish,
  t.planned_days,
  t.actual_start,
  t.actual_finish,
  public.count_workdays(t.actual_start, t.actual_finish) as actual_days,
  -- Atraso en dias corridos sobre la fecha de fin
  case
    when t.actual_finish is not null and t.planned_finish is not null
      then t.actual_finish - t.planned_finish
    when t.actual_finish is null and t.planned_finish is not null
         and current_date > t.planned_finish
      then current_date - t.planned_finish
  end                        as delay_days,
  -- Peso de la actividad dentro del proyecto
  case
    when sum(t.planned_days) over (partition by t.project_id) > 0
      then round(
             t.planned_days::numeric
             / sum(t.planned_days) over (partition by t.project_id), 6)
  end                        as weight,
  -- Atraso calculado al consultar, no guardado.
  (t.status <> 'terminada'
   and t.status <> 'bloqueada'
   and (
     (t.actual_start is null and t.planned_start  < current_date) or
     (t.actual_finish is null and t.planned_finish < current_date)
   ))                        as is_late,
  -- Estado efectivo: lo guardado, salvo que este atrasada.
  case
    when t.status in ('terminada', 'bloqueada') then t.status
    when (t.actual_start is null and t.planned_start < current_date)
      or (t.actual_finish is null and t.planned_finish < current_date)
      then 'demorada'::task_status
    else t.status
  end                        as effective_status
from public.tasks t;

-- Avance del proyecto: planificado a hoy vs real.
create view public.project_progress as
select
  p.id                                   as project_id,
  p.code,
  p.name,
  count(t.task_id)                       as actividades,
  count(t.task_id) filter (where t.effective_status = 'terminada') as terminadas,
  count(t.task_id) filter (where t.effective_status = 'demorada') as demoradas,
  count(t.task_id) filter (where t.effective_status = 'bloqueada') as bloqueadas,
  -- Cuanto deberia estar hecho hoy segun el plan
  coalesce(sum(t.weight) filter (where t.planned_finish <= current_date), 0)
                                         as avance_planificado,
  -- Cuanto esta hecho de verdad
  coalesce(sum(t.weight) filter (where t.effective_status = 'terminada'), 0)
                                         as avance_real,
  min(t.planned_start)                   as inicio_plan,
  max(t.planned_finish)                  as fin_plan,
  max(coalesce(t.actual_finish, t.planned_finish)) as fin_proyectado
from public.projects p
left join public.task_schedule t on t.project_id = p.id
group by p.id, p.code, p.name;

-- Alertas de cronograma: que esta mal y por que.
create view public.schedule_alerts as
select
  t.project_id,
  p.code,
  t.task_id,
  t.name,
  t.effective_status as status,
  t.planned_start,
  t.planned_finish,
  t.actual_finish,
  t.delay_days,
  case
    when t.effective_status = 'bloqueada'                    then 'bloqueada'
    when t.actual_finish is not null and t.delay_days > 0    then 'terminada_fuera_de_plazo'
    when t.actual_start is null and t.planned_start < current_date
                                                             then 'deberia_haber_empezado'
    when t.actual_finish is null and t.planned_finish < current_date
                                                             then 'atrasada'
  end as alerta
from public.task_schedule t
join public.projects p on p.id = t.project_id
where t.effective_status = 'bloqueada'
   or (t.actual_finish is not null and t.delay_days > 0)
   or (t.actual_start is null and t.planned_start < current_date)
   or (t.actual_finish is null and t.planned_finish < current_date);

-- Impacto de un atraso sobre las tareas que dependen de el.
create view public.dependency_impact as
select
  d.depends_on_id          as tarea_atrasada,
  ta.name                  as nombre_atrasada,
  ta.delay_days,
  d.task_id                as tarea_afectada,
  tb.name                  as nombre_afectada,
  tb.planned_start         as inicio_previsto_afectada,
  tb.project_id
from public.task_dependencies d
join public.task_schedule ta on ta.task_id = d.depends_on_id
join public.task_schedule tb on tb.task_id = d.task_id
where ta.delay_days > 0
  and tb.actual_finish is null;

-- =============================================================================
-- RLS
-- =============================================================================
alter table public.holidays           enable row level security;
alter table public.tasks              enable row level security;
alter table public.task_dependencies  enable row level security;

-- El calendario es publico para cualquier autenticado: lo necesita el front
-- para mostrar el Gantt.
create policy holidays_select on public.holidays
  for select to authenticated using (true);
create policy holidays_write on public.holidays
  for all to authenticated using (public.can_manage()) with check (public.can_manage());

create policy tasks_select on public.tasks
  for select to authenticated using (public.has_project_access(project_id));
create policy tasks_write on public.tasks
  for all to authenticated using (public.can_manage()) with check (public.can_manage());

create policy task_dependencies_select on public.task_dependencies
  for select to authenticated
  using (exists (
    select 1 from public.tasks t
    where t.id = task_id and public.has_project_access(t.project_id)
  ));
create policy task_dependencies_write on public.task_dependencies
  for all to authenticated using (public.can_manage()) with check (public.can_manage());

alter view public.task_schedule      set (security_invoker = on);
alter view public.project_progress   set (security_invoker = on);
alter view public.schedule_alerts    set (security_invoker = on);
alter view public.dependency_impact  set (security_invoker = on);

grant select on
  public.holidays, public.tasks, public.task_dependencies,
  public.task_schedule, public.project_progress,
  public.schedule_alerts, public.dependency_impact
  to authenticated;

grant insert, update, delete on
  public.holidays, public.tasks, public.task_dependencies
  to authenticated;
