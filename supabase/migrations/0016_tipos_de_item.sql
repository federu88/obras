-- =============================================================================
-- 0016_tipos_de_item.sql
--
-- Los items del catalogo no son todos de la misma naturaleza: una bolsa de
-- cemento, la factura de luz y los honorarios de la escribania se cargan
-- distinto y se buscan distinto.
--
-- Se resuelve con un TIPO dentro del mismo catalogo, no con tres catalogos
-- separados. Tres tablas serian tres ABM iguales de mantener, y romperian el
-- historial de precios y la comparacion de proveedores, que hoy funcionan
-- para cualquier item.
-- =============================================================================

create type item_kind as enum (
  'insumo',     -- materiales y mano de obra de la construccion
  'servicio',   -- expensas, luz, gas, seguros: se repiten todos los meses
  'honorario'   -- escribania, gestoria, arquitectura, comisiones
);

alter table public.items
  add column kind item_kind not null default 'insumo';

comment on column public.items.kind is
  'Naturaleza del item. Agrupa el catalogo sin partirlo en tablas separadas.';

-- -----------------------------------------------------------------------------
-- Clasificacion inicial a partir de la categoria a la que ya pertenecen.
-- -----------------------------------------------------------------------------
update public.items i
set kind = 'servicio'
from public.cost_categories s
where s.id = i.category_id
  and s.name in ('Expensas', 'Servicios de obra', 'Seguros', 'Financiación');

update public.items i
set kind = 'honorario'
from public.cost_categories s
where s.id = i.category_id
  and s.name in ('Gestoría', 'Gastos legales', 'Proyecto y arquitectura',
                 'Administración', 'Comercialización', 'Trámites');

create index items_kind_idx on public.items (kind);

-- -----------------------------------------------------------------------------
-- item_prices expone el tipo para que la UI pueda filtrar por el.
-- Se recrea entera porque una vista no admite agregar una columna al medio.
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
  cp.path                  as categoria,
  (select q.unit_price_usd from public.supplier_quotes q
    where q.item_id = i.id order by q.quote_date desc, q.created_at desc limit 1)
                           as ultimo_precio_cotizado_usd,
  (select q.quote_date from public.supplier_quotes q
    where q.item_id = i.id order by q.quote_date desc, q.created_at desc limit 1)
                           as fecha_ultima_cotizacion,
  (select round(e.unit_price / case when e.currency = 'USD' then 1 else e.fx_usd end, 4)
     from public.expenses e
    where e.item_id = i.id and e.status in ('recibido', 'pagado')
    order by e.expense_date desc, e.created_at desc limit 1)
                           as ultimo_precio_comprado_usd,
  (select e.expense_date from public.expenses e
    where e.item_id = i.id and e.status in ('recibido', 'pagado')
    order by e.expense_date desc, e.created_at desc limit 1)
                           as fecha_ultima_compra,
  (select round(avg(e.unit_price / case when e.currency = 'USD' then 1 else e.fx_usd end), 4)
     from public.expenses e
    where e.item_id = i.id and e.status in ('recibido', 'pagado'))
                           as precio_promedio_usd,
  (select count(*) from public.supplier_quotes q where q.item_id = i.id)
                           as cotizaciones
from public.items i
left join public.cost_category_paths cp on cp.id = i.category_id;

alter view public.item_prices set (security_invoker = on);
grant select on public.item_prices to authenticated;
