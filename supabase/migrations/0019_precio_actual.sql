-- =============================================================================
-- 0019_precio_actual.sql
--
-- El catalogo muestra siempre el precio MAS NUEVO de cada item, venga de donde
-- venga: de un precio de referencia cargado a mano, de una cotizacion o de una
-- compra. Cada item se actualiza cuando se actualiza; no hace falta tocarlos
-- todos juntos.
--
-- Requiere 0016 (columna items.kind) y 0017 (historial de precios).
-- =============================================================================

-- -----------------------------------------------------------------------------
-- item_latest_price — el ultimo precio y el anterior, para ver la variacion.
-- -----------------------------------------------------------------------------
create or replace view public.item_latest_price as
with orden as (
  select
    item_id,
    fecha,
    fuente,
    unit_price,
    currency,
    unit_price_usd,
    proveedor,
    row_number() over (
      partition by item_id
      order by fecha desc, fuente
    ) as rn
  from public.item_price_history
  where unit_price_usd is not null and unit_price_usd > 0
)
select
  a.item_id,
  a.fecha           as fecha_precio,
  a.fuente          as origen_precio,
  a.unit_price      as precio_nominal,
  a.currency        as moneda_precio,
  a.unit_price_usd  as precio_actual_usd,
  a.proveedor       as proveedor_precio,
  b.unit_price_usd  as precio_anterior_usd,
  b.fecha           as fecha_anterior,
  case when b.unit_price_usd > 0
       then round((a.unit_price_usd - b.unit_price_usd) / b.unit_price_usd, 4)
  end               as variacion
from orden a
left join orden b on b.item_id = a.item_id and b.rn = 2
where a.rn = 1;

-- -----------------------------------------------------------------------------
-- item_prices — el catalogo completo con el precio vigente al frente.
-- -----------------------------------------------------------------------------
drop view if exists public.item_prices;

create view public.item_prices as
select
  i.id                     as item_id,
  i.code,
  i.description,
  i.unit,
  i.kind,
  i.category_id,
  i.is_active,
  cp.path                  as categoria,

  -- Lo que importa ver de un vistazo
  lp.precio_actual_usd,
  lp.fecha_precio,
  lp.origen_precio,
  lp.proveedor_precio,
  lp.precio_anterior_usd,
  lp.variacion,

  -- Detalle por origen, para cuando hace falta desagregar
  (select q.unit_price_usd from public.supplier_quotes q
    where q.item_id = i.id order by q.quote_date desc, q.created_at desc limit 1)
                           as ultimo_precio_cotizado_usd,
  (select round(e.unit_price / case when e.currency = 'USD' then 1 else e.fx_usd end, 4)
     from public.expenses e
    where e.item_id = i.id and e.status in ('recibido', 'pagado')
    order by e.expense_date desc, e.created_at desc limit 1)
                           as ultimo_precio_comprado_usd,
  (select round(avg(e.unit_price / case when e.currency = 'USD' then 1 else e.fx_usd end), 4)
     from public.expenses e
    where e.item_id = i.id and e.status in ('recibido', 'pagado'))
                           as precio_promedio_usd,
  (select count(*) from public.item_price_history h where h.item_id = i.id)
                           as precios_registrados
from public.items i
left join public.cost_category_paths cp on cp.id = i.category_id
left join public.item_latest_price lp   on lp.item_id = i.id;

alter view public.item_latest_price set (security_invoker = on);
alter view public.item_prices       set (security_invoker = on);

grant select on public.item_latest_price, public.item_prices to authenticated;
