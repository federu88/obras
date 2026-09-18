-- =============================================================================
-- 0010_reporting.sql  ·  Fase 7 — Reporting
--
-- No introduce calculos nuevos: consolida los que ya existen. Si un numero
-- aparece aca y en otra pantalla, sale de la misma vista. Esa es la regla que
-- evita que el mismo indicador tenga dos formulas.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- business_summary — la posicion consolidada del negocio, en una fila.
-- Es el origen unico de los KPIs del dashboard global.
-- -----------------------------------------------------------------------------
create view public.business_summary as
with capital as (
  select
    coalesce(sum(amount_usd) filter (where type = 'aporte'), 0)             as aportado,
    coalesce(sum(amount_usd) filter (where type = 'retiro'), 0)             as retirado,
    coalesce(sum(amount_usd) filter (where type = 'profit_asignado'), 0)    as profit_asignado,
    coalesce(sum(amount_usd) filter (where type = 'profit_distribuido'), 0) as profit_distribuido,
    coalesce(sum(amount_usd) filter (where type = 'reinversion'), 0)        as reinvertido
  from public.capital_movements
  where status = 'confirmado'
),
caja as (
  -- Plata que ya se movio. Lo proyectado no es caja disponible.
  select coalesce(sum(amount_usd), 0) as realizada
  from public.cash_flows
  where scope = 'realizado'
),
costos as (
  select
    coalesce(sum(amount_usd) filter (where status in ('recibido', 'pagado')), 0) as actual,
    coalesce(sum(amount_usd) filter (where status = 'comprometido'), 0)          as comprometido
  from public.expenses
  where status <> 'anulado'
),
ingresos as (
  select coalesce(sum(amount_usd), 0) as total from public.revenues
),
proyectos as (
  select
    count(*) filter (where status in ('aprobado', 'en_construccion')) as activos,
    count(*) filter (where status in ('terminado', 'vendido', 'cerrado')) as terminados,
    count(*) as total
  from public.projects
),
pnl as (
  select coalesce(sum(forecast_profit_usd), 0) as profit_proyectado
  from public.project_pnl
)
select
  capital.aportado                                    as capital_aportado_usd,
  capital.retirado                                    as capital_retirado_usd,
  capital.aportado - capital.retirado + capital.reinvertido
                                                      as capital_invertido_usd,
  capital.profit_asignado - capital.profit_distribuido - capital.reinvertido
                                                      as profit_pendiente_usd,
  capital.profit_distribuido                          as profit_realizado_usd,
  capital.reinvertido                                 as profit_reinvertido_usd,
  caja.realizada                                      as caja_usd,
  costos.comprometido                                 as comprometido_usd,
  -- Disponible es la caja menos lo ya comprometido: esa plata tiene dueño.
  caja.realizada - costos.comprometido                as capital_disponible_usd,
  costos.actual                                       as costo_actual_usd,
  ingresos.total                                      as ingresos_usd,
  ingresos.total - costos.actual                      as resultado_acumulado_usd,
  pnl.profit_proyectado                               as profit_proyectado_usd,
  proyectos.activos                                   as proyectos_activos,
  proyectos.terminados                                as proyectos_terminados,
  proyectos.total                                     as proyectos_total
from capital, caja, costos, ingresos, proyectos, pnl;

-- -----------------------------------------------------------------------------
-- project_health — que proyectos tienen problemas, de costo o de plazo.
-- Responde los dos ultimos puntos del dashboard de la seccion 2.
-- -----------------------------------------------------------------------------
create view public.project_health as
select
  p.project_id,
  p.code,
  p.name,
  p.status,
  p.budget_usd,
  p.actual_cost_usd,
  p.forecast_cost_usd,
  p.committed_cost_usd,
  p.revenue_usd,
  p.forecast_profit_usd,
  case when p.budget_usd > 0
       then round((p.forecast_cost_usd - p.budget_usd) / p.budget_usd, 4)
  end                                    as desvio_costo_rel,
  pr.avance_planificado,
  pr.avance_real,
  pr.demoradas,
  pr.fin_plan,
  pr.fin_proyectado,
  -- Problema de costo: el forecast supera el budget en mas de 5%.
  (p.budget_usd > 0 and p.forecast_cost_usd > p.budget_usd * 1.05)
                                         as problema_costo,
  -- Problema de plazo: el avance real va mas de 5 puntos por detras del plan,
  -- o hay actividades demoradas.
  (coalesce(pr.avance_real, 0) < coalesce(pr.avance_planificado, 0) - 0.05
   or coalesce(pr.demoradas, 0) > 0)     as problema_plazo
from public.project_pnl p
left join public.project_progress pr on pr.project_id = p.project_id;

-- -----------------------------------------------------------------------------
-- investor_report — todo lo de un inversor, proyecto por proyecto.
-- Es la base del dashboard del inversor y del reporte que se le manda.
-- -----------------------------------------------------------------------------
create view public.investor_report as
select
  i.id                          as investor_id,
  i.name                        as investor_name,
  i.user_id,
  pr.id                         as project_id,
  pr.code,
  pr.name                       as project_name,
  pr.status                     as project_status,
  pos.capital_invertido_usd,
  pos.profit_pendiente_usd,
  pos.profit_cobrado_usd,
  pos.ultimo_movimiento,
  -- Participacion del inversor sobre el capital total de ese proyecto.
  case when pc.capital_aportado_usd > 0
       then round(pos.capital_invertido_usd / pc.capital_aportado_usd, 6)
  end                           as participacion,
  -- Profit que le tocaria segun su participacion, si el proyecto cierra como
  -- se proyecta hoy. Es una PROYECCION, no un derecho adquirido.
  case when pc.capital_aportado_usd > 0
       then round(
              pos.capital_invertido_usd / pc.capital_aportado_usd
              * pnl.forecast_profit_usd, 2)
  end                           as profit_proyectado_usd
from public.investors i
join public.investor_positions pos on pos.investor_id = i.id
join public.projects pr             on pr.id = pos.project_id
left join public.project_capital pc on pc.project_id = pr.id
left join public.project_pnl pnl    on pnl.project_id = pr.id;

-- -----------------------------------------------------------------------------
-- Permisos. Las vistas heredan la RLS de sus tablas via security_invoker,
-- asi que un inversor solo ve sus propias filas en investor_report.
-- -----------------------------------------------------------------------------
alter view public.business_summary set (security_invoker = on);
alter view public.project_health   set (security_invoker = on);
alter view public.investor_report  set (security_invoker = on);

grant select on
  public.business_summary, public.project_health, public.investor_report
  to authenticated;
