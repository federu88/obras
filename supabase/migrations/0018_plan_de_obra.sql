-- =============================================================================
-- 0018_plan_de_obra.sql
--
-- El presupuesto deja de ser una lista y pasa a ser un plan: cada linea lleva
-- CUANDO se va a usar y, opcionalmente, a que actividad del cronograma
-- pertenece.
--
-- Consecuencia importante: el cashflow proyectado deja de depender de que
-- alguien cargue gastos. El presupuesto pendiente, ubicado en su fecha
-- planificada, ya proyecta la necesidad de caja. Eso es lo que responde
-- "cuanta plata necesita esta casa en los proximos tres meses" antes de que
-- se gaste un peso.
-- =============================================================================

alter table public.budget_lines
  add column planned_date date,
  add column task_id      uuid references public.tasks(id) on delete set null;

comment on column public.budget_lines.planned_date is
  'Cuándo se prevé usar o comprar este item. Alimenta el cashflow proyectado.';
comment on column public.budget_lines.task_id is
  'Actividad del cronograma que consume este item. Opcional.';

create index budget_lines_planned_idx on public.budget_lines (project_id, planned_date);
create index budget_lines_task_idx    on public.budget_lines (task_id);

-- -----------------------------------------------------------------------------
-- budget_pendiente — lo presupuestado que todavia no se ejecuto.
--
-- Se descuenta lo ya gastado contra esa linea para no contar dos veces: una
-- vez como plan y otra como gasto real.
-- -----------------------------------------------------------------------------
create view public.budget_pendiente as
select
  b.id                                   as budget_line_id,
  b.project_id,
  b.task_id,
  b.description,
  coalesce(b.planned_date, current_date) as fecha,
  b.total_forecast_usd                   as forecast_usd,
  coalesce(ej.ejecutado, 0)              as ejecutado_usd,
  greatest(b.total_forecast_usd - coalesce(ej.ejecutado, 0), 0) as pendiente_usd
from public.budget_lines b
left join lateral (
  select sum(e.amount_usd) as ejecutado
  from public.expenses e
  where e.budget_line_id = b.id and e.status <> 'anulado'
) ej on true;

-- -----------------------------------------------------------------------------
-- cash_flows suma el presupuesto pendiente como salida proyectada.
-- Mismas columnas que antes, asi que las vistas que dependen de ella siguen
-- funcionando sin tocarlas.
-- -----------------------------------------------------------------------------
create or replace view public.cash_flows as

select
  m.project_id,
  m.movement_date          as flow_date,
  'capital'::text          as source,
  m.type::text             as detail,
  'realizado'::text        as scope,
  case m.type
    when 'aporte'             then  m.amount_usd
    when 'retiro'             then -m.amount_usd
    when 'profit_distribuido' then -m.amount_usd
  end                      as amount_usd
from public.capital_movements m
where m.status = 'confirmado'
  and m.type in ('aporte', 'retiro', 'profit_distribuido')

union all

select
  m.from_project_id, m.movement_date, 'transferencia', m.type::text, 'realizado',
  -m.amount_usd
from public.capital_movements m
where m.status = 'confirmado' and m.type in ('reinversion', 'transferencia')

union all

select
  m.project_id, m.movement_date, 'transferencia', m.type::text, 'realizado',
  m.amount_usd
from public.capital_movements m
where m.status = 'confirmado' and m.type in ('reinversion', 'transferencia')

union all

select
  r.project_id, r.revenue_date, 'ingreso', r.kind::text, 'realizado', r.amount_usd
from public.revenues r

union all

select
  e.project_id, coalesce(e.paid_date, e.expense_date), 'gasto', e.status::text,
  'realizado', -e.amount_usd
from public.expenses e
where e.status = 'pagado'

union all

select
  e.project_id, coalesce(e.due_date, e.expense_date), 'gasto', e.status::text,
  'proyectado', -e.amount_usd
from public.expenses e
where e.status in ('recibido', 'comprometido', 'estimado')

union all

-- Presupuesto todavia no ejecutado, en su fecha planificada.
select
  p.project_id, p.fecha, 'presupuesto', 'pendiente', 'proyectado',
  -p.pendiente_usd
from public.budget_pendiente p
where p.pendiente_usd > 0;

-- -----------------------------------------------------------------------------
-- plan_de_obra — el presupuesto visto como plan: que item, cuando y con que
-- actividad del cronograma se corresponde.
-- -----------------------------------------------------------------------------
create view public.plan_de_obra as
select
  b.id                    as budget_line_id,
  b.project_id,
  b.description,
  b.unit,
  b.qty_original,
  b.price_original_usd,
  b.total_original_usd,
  b.total_forecast_usd,
  b.planned_date,
  i.code                  as item_code,
  cp.path                 as categoria,
  t.name                  as actividad,
  t.planned_start         as actividad_inicio,
  t.planned_finish        as actividad_fin,
  bp.ejecutado_usd,
  bp.pendiente_usd
from public.budget_lines b
left join public.items i                on i.id = b.item_id
left join public.cost_category_paths cp on cp.id = b.category_id
left join public.tasks t                on t.id = b.task_id
left join public.budget_pendiente bp    on bp.budget_line_id = b.id;

-- -----------------------------------------------------------------------------
-- Permisos
-- -----------------------------------------------------------------------------
alter view public.budget_pendiente set (security_invoker = on);
alter view public.plan_de_obra     set (security_invoker = on);
alter view public.cash_flows       set (security_invoker = on);

grant select on public.budget_pendiente, public.plan_de_obra to authenticated;

-- -----------------------------------------------------------------------------
-- budget_variance suma la fecha prevista, la actividad y lo pendiente.
-- Se extiende la vista que el presupuesto ya usa, en vez de crear una segunda
-- fuente para la misma tabla.
-- -----------------------------------------------------------------------------
create or replace view public.budget_variance as
select
  b.id                          as budget_line_id,
  b.project_id,
  b.description,
  cp.path                       as categoria,
  b.unit,
  b.qty_original,
  b.price_original_usd,
  b.total_original_usd,
  b.total_forecast_usd,
  coalesce(sum(e.amount_usd) filter (where e.status in ('recibido', 'pagado')), 0)
                                as actual_usd,
  coalesce(sum(e.amount_usd) filter (where e.status = 'comprometido'), 0)
                                as committed_usd,
  b.planned_date,
  t.name                        as actividad,
  greatest(
    b.total_forecast_usd - coalesce(sum(e.amount_usd), 0), 0
  )                             as pendiente_usd
from public.budget_lines b
left join public.cost_category_paths cp on cp.id = b.category_id
left join public.tasks t on t.id = b.task_id
left join public.expenses e on e.budget_line_id = b.id and e.status <> 'anulado'
group by b.id, b.project_id, b.description, cp.path, b.unit,
         b.qty_original, b.price_original_usd,
         b.total_original_usd, b.total_forecast_usd,
         b.planned_date, t.name;

alter view public.budget_variance set (security_invoker = on);
grant select on public.budget_variance to authenticated;
