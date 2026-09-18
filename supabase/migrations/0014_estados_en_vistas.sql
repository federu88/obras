-- =============================================================================
-- 0014_estados_en_vistas.sql   ·   PASO 2 de 2
--
-- Correr DESPUES de 0013, en una ejecucion aparte. Aca ya se pueden usar los
-- valores nuevos del enum.
--
-- Criterio: "activo" es la obra que todavia se esta construyendo, incluido el
-- tramite municipal. Una casa terminada que se esta vendiendo ya no consume
-- obra, asi que cuenta como terminada aunque el negocio siga abierto.
-- =============================================================================

create or replace view public.business_summary as
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
    count(*) filter (
      where status in ('aprobado', 'en_tramite_municipal', 'en_construccion')
    ) as activos,
    count(*) filter (
      where status in ('terminado', 'en_proceso_venta', 'vendido', 'cerrado')
    ) as terminados,
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
  caja.realizada - costos.comprometido                as capital_disponible_usd,
  costos.actual                                       as costo_actual_usd,
  ingresos.total                                      as ingresos_usd,
  ingresos.total - costos.actual                      as resultado_acumulado_usd,
  pnl.profit_proyectado                               as profit_proyectado_usd,
  proyectos.activos                                   as proyectos_activos,
  proyectos.terminados                                as proyectos_terminados,
  proyectos.total                                     as proyectos_total
from capital, caja, costos, ingresos, proyectos, pnl;

alter view public.business_summary set (security_invoker = on);
grant select on public.business_summary to authenticated;
