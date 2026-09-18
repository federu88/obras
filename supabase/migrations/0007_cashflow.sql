-- =============================================================================
-- 0007_cashflow.sql  ·  Fase 3 (cierre) — Cashflow por proyecto
--
-- Resuelve ademas la brecha registrada en docs/02-decisiones-abiertas.md:
-- capital_effects daba cash_delta = 0 a reinversion y transferencia, asi que
-- el dinero que pasa de una casa a otra no aparecia en el cashflow de ninguna
-- de las dos. Aca cada movimiento entre proyectos se expande en DOS filas de
-- signo opuesto, una por proyecto.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- cash_flows — todo movimiento de dinero de un proyecto, venga de donde venga.
--
-- scope distingue lo ya ocurrido de lo previsto:
--   realizado  = plata que ya se movio
--   proyectado = compromisos y estimaciones con fecha futura
-- -----------------------------------------------------------------------------
create view public.cash_flows as

-- Capital que entra o sale del negocio
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

-- Movimientos entre proyectos: la pata que SALE del origen
select
  m.from_project_id, m.movement_date, 'transferencia', m.type::text, 'realizado',
  -m.amount_usd
from public.capital_movements m
where m.status = 'confirmado'
  and m.type in ('reinversion', 'transferencia')

union all

-- Movimientos entre proyectos: la pata que ENTRA al destino
select
  m.project_id, m.movement_date, 'transferencia', m.type::text, 'realizado',
  m.amount_usd
from public.capital_movements m
where m.status = 'confirmado'
  and m.type in ('reinversion', 'transferencia')

union all

-- Ingresos cobrados
select
  r.project_id, r.revenue_date, 'ingreso', r.kind::text, 'realizado', r.amount_usd
from public.revenues r

union all

-- Gastos ya pagados
select
  e.project_id, coalesce(e.paid_date, e.expense_date), 'gasto', e.status::text,
  'realizado', -e.amount_usd
from public.expenses e
where e.status = 'pagado'

union all

-- Gastos previstos: recibido impago, comprometido y estimado.
-- Se ubican en su fecha de vencimiento cuando la tienen; si no, en la del gasto.
select
  e.project_id, coalesce(e.due_date, e.expense_date), 'gasto', e.status::text,
  'proyectado', -e.amount_usd
from public.expenses e
where e.status in ('recibido', 'comprometido', 'estimado');

-- -----------------------------------------------------------------------------
-- project_cashflow — cashflow mensual con saldo acumulado.
--
-- El saldo corre sobre realizado y proyectado juntos: es lo que responde
-- "cuanta plata necesita esta casa en los proximos meses".
-- -----------------------------------------------------------------------------
create view public.project_cashflow as
select
  f.project_id,
  date_trunc('month', f.flow_date)::date                       as month,
  coalesce(sum(f.amount_usd) filter (where f.amount_usd > 0), 0) as inflows,
  coalesce(sum(f.amount_usd) filter (where f.amount_usd < 0), 0) as outflows,
  coalesce(sum(f.amount_usd), 0)                                as net,
  coalesce(sum(f.amount_usd) filter (where f.scope = 'realizado'), 0)  as net_realizado,
  coalesce(sum(f.amount_usd) filter (where f.scope = 'proyectado'), 0) as net_proyectado,
  sum(coalesce(sum(f.amount_usd), 0)) over (
    partition by f.project_id
    order by date_trunc('month', f.flow_date)
    rows between unbounded preceding and current row
  )                                                             as closing_balance
from public.cash_flows f
where f.amount_usd is not null
group by f.project_id, date_trunc('month', f.flow_date);

-- -----------------------------------------------------------------------------
-- cashflow_consolidado — el negocio completo, sin abrir por proyecto.
-- -----------------------------------------------------------------------------
create view public.cashflow_consolidado as
select
  date_trunc('month', f.flow_date)::date                        as month,
  coalesce(sum(f.amount_usd) filter (where f.amount_usd > 0), 0) as inflows,
  coalesce(sum(f.amount_usd) filter (where f.amount_usd < 0), 0) as outflows,
  coalesce(sum(f.amount_usd), 0)                                as net,
  coalesce(sum(f.amount_usd) filter (where f.scope = 'realizado'), 0)  as net_realizado,
  coalesce(sum(f.amount_usd) filter (where f.scope = 'proyectado'), 0) as net_proyectado,
  sum(coalesce(sum(f.amount_usd), 0)) over (
    order by date_trunc('month', f.flow_date)
    rows between unbounded preceding and current row
  )                                                             as closing_balance
from public.cash_flows f
where f.amount_usd is not null
group by date_trunc('month', f.flow_date);

-- -----------------------------------------------------------------------------
-- Necesidad de caja: los meses proximos que cierran en negativo.
-- Responde "cuanta plata hace falta y cuando".
-- -----------------------------------------------------------------------------
create view public.cash_requirements as
select
  c.project_id,
  p.code,
  p.name,
  c.month,
  c.closing_balance,
  -c.closing_balance as necesidad_usd
from public.project_cashflow c
join public.projects p on p.id = c.project_id
where c.closing_balance < 0
  and c.month >= date_trunc('month', current_date)::date;

-- -----------------------------------------------------------------------------
-- Permisos. Vistas con la RLS del que consulta.
-- -----------------------------------------------------------------------------
alter view public.cash_flows           set (security_invoker = on);
alter view public.project_cashflow     set (security_invoker = on);
alter view public.cashflow_consolidado set (security_invoker = on);
alter view public.cash_requirements    set (security_invoker = on);

grant select on
  public.cash_flows, public.project_cashflow,
  public.cashflow_consolidado, public.cash_requirements
  to authenticated;
