-- =============================================================================
-- 0011_reparto.sql
--
-- Dos correcciones que salen de "REPARTO UTILIDAD CASAS 1.xlsx", el reparto
-- real del negocio:
--
--   1. La comision inmobiliaria es 2,5%, no 4%. El 4% era un default que puse
--      yo sin dato; el archivo dice 0,025 (Hoja1!J5).
--   2. El margen se mide sobre el COSTO, no sobre la venta. El archivo calcula
--      utilidad / costo estimado = 21,08% (Hoja1!L12). El sistema mostraba
--      solo utilidad / venta. Ahora estan los dos, con nombres distintos.
-- =============================================================================

-- 1. Comision -----------------------------------------------------------------
alter table public.projects
  alter column broker_fee_pct set default 0.025;

-- Los proyectos que quedaron con 0.04 lo tienen porque ese era mi default,
-- no porque alguien lo haya elegido. Se corrigen.
update public.projects
set broker_fee_pct = 0.025
where broker_fee_pct = 0.04;

comment on column public.projects.broker_fee_pct is
  'Comision inmobiliaria sobre la venta. Default 2,5% segun el reparto real.';

-- 2. Margen sobre costo -------------------------------------------------------
-- Se agrega al final de project_pnl para no romper las vistas que dependen
-- de ella (project_health).
create or replace view public.project_pnl as
select
  p.id                                          as project_id,
  p.code,
  p.name,
  p.status,
  coalesce(r.revenue_usd, 0)                    as revenue_usd,
  coalesce(p.target_sale_usd, 0)                as revenue_target_usd,
  coalesce(b.budget_original_usd, 0)            as budget_usd,
  coalesce(b.budget_forecast_usd, 0)            as budget_forecast_usd,
  coalesce(c.actual_usd, 0)                     as actual_cost_usd,
  coalesce(c.committed_usd, 0)                  as committed_cost_usd,
  greatest(
    coalesce(b.budget_forecast_usd, 0),
    coalesce(c.actual_usd, 0) + coalesce(c.committed_usd, 0)
  )                                             as forecast_cost_usd,
  round(coalesce(r.venta_usd, coalesce(p.target_sale_usd, 0)) * p.broker_fee_pct, 2)
                                                as broker_fee_usd,
  coalesce(r.revenue_usd, 0) - coalesce(c.actual_usd, 0)
                                                as gross_profit_usd,
  coalesce(nullif(r.venta_usd, 0), coalesce(p.target_sale_usd, 0))
    - greatest(
        coalesce(b.budget_forecast_usd, 0),
        coalesce(c.actual_usd, 0) + coalesce(c.committed_usd, 0)
      )
    - round(coalesce(nullif(r.venta_usd, 0), coalesce(p.target_sale_usd, 0)) * p.broker_fee_pct, 2)
                                                as forecast_profit_usd,
  -- --- Columnas nuevas -------------------------------------------------------
  -- Margen sobre la VENTA. Es el que mide cuanto de cada dolar vendido queda.
  case when coalesce(nullif(r.venta_usd, 0), p.target_sale_usd, 0) > 0
    then round(
      (coalesce(nullif(r.venta_usd, 0), coalesce(p.target_sale_usd, 0))
        - greatest(
            coalesce(b.budget_forecast_usd, 0),
            coalesce(c.actual_usd, 0) + coalesce(c.committed_usd, 0))
        - round(coalesce(nullif(r.venta_usd, 0), coalesce(p.target_sale_usd, 0)) * p.broker_fee_pct, 2))
      / coalesce(nullif(r.venta_usd, 0), p.target_sale_usd), 4)
  end                                           as margin_on_revenue,
  -- Margen sobre el COSTO. Es el criterio del reparto: cuanto rinde la plata
  -- puesta. Con los numeros del archivo da 21,08%.
  case when greatest(
              coalesce(b.budget_forecast_usd, 0),
              coalesce(c.actual_usd, 0) + coalesce(c.committed_usd, 0)) > 0
    then round(
      (coalesce(nullif(r.venta_usd, 0), coalesce(p.target_sale_usd, 0))
        - greatest(
            coalesce(b.budget_forecast_usd, 0),
            coalesce(c.actual_usd, 0) + coalesce(c.committed_usd, 0))
        - round(coalesce(nullif(r.venta_usd, 0), coalesce(p.target_sale_usd, 0)) * p.broker_fee_pct, 2))
      / greatest(
          coalesce(b.budget_forecast_usd, 0),
          coalesce(c.actual_usd, 0) + coalesce(c.committed_usd, 0)), 4)
  end                                           as margin_on_cost
from public.projects p
left join public.project_budget_summary b on b.project_id = p.id
left join public.project_costs          c on c.project_id = p.id
left join public.project_revenues       r on r.project_id = p.id;

alter view public.project_pnl set (security_invoker = on);
grant select on public.project_pnl to authenticated;
