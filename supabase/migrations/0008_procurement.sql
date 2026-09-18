-- =============================================================================
-- 0008_procurement.sql  ·  Fase 4 — Catálogo, proveedores, cotizaciones y compras
--
-- Decision de diseno: NO hay tabla `purchases` separada de `expenses`.
-- Una compra es un costo. Con dos tablas, el dia que una se cargue sin la otra
-- el P&L y el modulo de compras dicen cosas distintas. `expenses` sigue siendo
-- el registro unico y recibe los campos de compra.
-- =============================================================================

-- Flujo operativo de la compra. Distinto de expenses.status, que es la verdad
-- financiera. El segundo se deriva del primero, asi no pueden contradecirse.
create type purchase_stage as enum (
  'solicitada', 'cotizada', 'aprobada', 'comprada', 'recibida', 'pagada'
);

-- -----------------------------------------------------------------------------
-- suppliers — proveedores normalizados.
--
-- En el catalogo actual hay 15 valores distintos, de los cuales "TBD" son 90
-- (40% de los items), con telefonos dentro del nombre
-- ("Juan -+54 9 230 450-4450") y genericos como "Corralon" o "estimado".
-- Aca el telefono tiene su columna.
-- -----------------------------------------------------------------------------
create table public.suppliers (
  id           uuid primary key default gen_random_uuid(),
  name         text not null unique,
  contact_name text,
  phone        text,
  email        text,
  address      text,
  notes        text,
  is_active    boolean not null default true,
  created_by   uuid references public.profiles(id),
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now()
);

create trigger suppliers_set_updated_at
  before update on public.suppliers
  for each row execute function public.set_updated_at();

-- -----------------------------------------------------------------------------
-- items — catalogo central, reutilizable entre proyectos.
--
-- category_id apunta a cost_categories: no se duplica la jerarquia. La unidad
-- es obligatoria y NO puede ser "un" generico para todo, como pasa hoy con los
-- 225 items del catalogo: sin unidad real no se puede comparar un precio entre
-- proveedores ni calcular consumo.
-- -----------------------------------------------------------------------------
create table public.items (
  id            uuid primary key default gen_random_uuid(),
  code          text not null unique,
  description   text not null,
  category_id   uuid references public.cost_categories(id) on delete restrict,
  unit          text not null,
  spec          text,
  is_active     boolean not null default true,
  created_by    uuid references public.profiles(id),
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now()
);

create trigger items_set_updated_at
  before update on public.items
  for each row execute function public.set_updated_at();

create index items_category_idx on public.items (category_id);

-- Codigo sugerido con la misma logica del catalogo actual:
-- las 4 primeras letras de la subcategoria + un contador.
create or replace function public.suggest_item_code(p_category uuid)
returns text
language sql
stable
as $fn$
  select upper(left(coalesce(c.name, 'ITEM'), 4)) || '-' ||
         (coalesce(count(i.id), 0) + 1)::text
  from public.cost_categories c
  left join public.items i on i.category_id = c.id
  where c.id = p_category
  group by c.name;
$fn$;

-- -----------------------------------------------------------------------------
-- supplier_quotes — cotizaciones. Historico: nunca se borran.
-- -----------------------------------------------------------------------------
create table public.supplier_quotes (
  id             uuid primary key default gen_random_uuid(),
  item_id        uuid not null references public.items(id) on delete restrict,
  supplier_id    uuid not null references public.suppliers(id) on delete restrict,
  project_id     uuid references public.projects(id) on delete set null,
  quote_date     date not null,
  qty            numeric(18,4) not null default 1 check (qty > 0),
  unit_price     numeric(18,4) not null check (unit_price >= 0),
  currency       currency not null,
  fx_usd         numeric(18,4) check (fx_usd is null or fx_usd > 0),
  unit_price_usd numeric(18,4) generated always as (
                   case when currency = 'USD' then unit_price
                        else round(unit_price / fx_usd, 4) end
                 ) stored,
  payment_terms  text,
  valid_until    date,
  notes          text,
  created_by     uuid references public.profiles(id),
  created_at     timestamptz not null default now(),

  constraint quotes_fx_required check (currency = 'USD' or fx_usd is not null)
);

create index quotes_item_idx     on public.supplier_quotes (item_id);
create index quotes_supplier_idx on public.supplier_quotes (supplier_id);
create index quotes_date_idx     on public.supplier_quotes (quote_date desc);

create or replace function public.forbid_quote_delete()
returns trigger language plpgsql as $fn$
begin
  raise exception 'Las cotizaciones no se eliminan: son el historico de precios.';
end;
$fn$;

create trigger supplier_quotes_no_delete
  before delete on public.supplier_quotes
  for each row execute function public.forbid_quote_delete();

-- -----------------------------------------------------------------------------
-- expenses recibe los campos de compra.
-- -----------------------------------------------------------------------------
-- El presupuesto tambien apunta al catalogo: sin eso no se puede saber que
-- item cotizar para una linea, ni comparar el precio presupuestado contra el
-- cotizado.
alter table public.budget_lines
  add column item_id uuid references public.items(id) on delete restrict;

create index budget_lines_item_idx on public.budget_lines (item_id);

alter table public.expenses
  add column item_id        uuid references public.items(id) on delete restrict,
  add column supplier_id    uuid references public.suppliers(id) on delete restrict,
  add column quote_id       uuid references public.supplier_quotes(id) on delete set null,
  add column purchase_stage purchase_stage,
  add column payment_terms  text;

create index expenses_item_idx     on public.expenses (item_id);
create index expenses_supplier_idx on public.expenses (supplier_id);

-- El status financiero se deriva del stage operativo. Una sola verdad.
--   solicitada, cotizada  -> estimado     (ni comprometido ni costo)
--   aprobada, comprada    -> comprometido (Committed)
--   recibida              -> recibido     (Actual)
--   pagada                -> pagado       (Actual)
create or replace function public.sync_expense_status()
returns trigger
language plpgsql
as $fn$
begin
  if new.purchase_stage is null then
    return new;                      -- gasto sin flujo de compra: status manual
  end if;
  if new.status = 'anulado' then
    return new;                      -- una anulacion manda sobre el stage
  end if;

  new.status := case new.purchase_stage
    when 'solicitada' then 'estimado'
    when 'cotizada'   then 'estimado'
    when 'aprobada'   then 'comprometido'
    when 'comprada'   then 'comprometido'
    when 'recibida'   then 'recibido'
    when 'pagada'     then 'pagado'
  end::expense_status;

  return new;
end;
$fn$;

create trigger expenses_sync_status
  before insert or update on public.expenses
  for each row execute function public.sync_expense_status();

-- =============================================================================
-- VISTAS
-- =============================================================================

-- Historial de precios por item: cotizado, comprado y promedio.
-- Es lo que el catalogo actual pide en su encabezado y nunca tuvo cargado.
create view public.item_prices as
select
  i.id                     as item_id,
  i.code,
  i.description,
  i.unit,
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

-- Comparativa de proveedores por item: quien da mejor precio.
create view public.supplier_item_prices as
select
  q.item_id,
  q.supplier_id,
  s.name                       as supplier_name,
  count(*)                     as cotizaciones,
  min(q.unit_price_usd)        as mejor_precio_usd,
  max(q.quote_date)            as ultima_cotizacion,
  (array_agg(q.unit_price_usd order by q.quote_date desc))[1] as precio_vigente_usd
from public.supplier_quotes q
join public.suppliers s on s.id = q.supplier_id
group by q.item_id, q.supplier_id, s.name;

-- Analisis de brechas de tu seccion 11: Budget -> Quote -> Purchase -> Actual.
-- Todo por linea de presupuesto, en USD y con la variacion ya calculada.
create view public.procurement_variance as
select
  b.id                          as budget_line_id,
  b.project_id,
  b.description,
  cp.path                       as categoria,
  b.total_original_usd          as budget_usd,
  -- Mejor cotizacion disponible para el item de esta linea, por la cantidad
  -- presupuestada. Es el "Quote" del analisis Budget -> Quote -> Purchase.
  (select round(min(q.unit_price_usd) * b.qty_original, 2)
     from public.supplier_quotes q
    where q.item_id = b.item_id)  as quoted_usd,
  coalesce(sum(e.amount_usd) filter (
    where e.purchase_stage in ('comprada', 'recibida', 'pagada')), 0)
                                as purchased_usd,
  coalesce(sum(e.amount_usd) filter (
    where e.status in ('recibido', 'pagado')), 0)
                                as actual_usd
from public.budget_lines b
left join public.cost_category_paths cp on cp.id = b.category_id
left join public.expenses e on e.budget_line_id = b.id and e.status <> 'anulado'
group by b.id, b.project_id, b.description, cp.path,
         b.total_original_usd, b.qty_original, b.item_id;

-- Desvio por categoria: donde se esta yendo el presupuesto.
create view public.variance_by_category as
select
  b.project_id,
  coalesce(cp.parent_name, cp.name, 'Sin categoría') as categoria,
  sum(b.total_original_usd)                          as budget_usd,
  sum(b.total_forecast_usd)                          as forecast_usd,
  coalesce(sum(v.actual_usd), 0)                     as actual_usd
from public.budget_lines b
left join public.cost_category_paths cp on cp.id = b.category_id
left join public.procurement_variance v on v.budget_line_id = b.id
group by b.project_id, coalesce(cp.parent_name, cp.name, 'Sin categoría');

-- =============================================================================
-- RLS
-- =============================================================================
alter table public.suppliers       enable row level security;
alter table public.items           enable row level security;
alter table public.supplier_quotes enable row level security;

-- Catalogo y proveedores: los lee cualquier autenticado, los escribe manager.
create policy suppliers_select on public.suppliers
  for select to authenticated using (true);
create policy suppliers_write on public.suppliers
  for all to authenticated using (public.can_manage()) with check (public.can_manage());

create policy items_select on public.items
  for select to authenticated using (true);
create policy items_write on public.items
  for all to authenticated using (public.can_manage()) with check (public.can_manage());

-- Las cotizaciones son informacion comercial: no las ve un inversor.
create policy quotes_select on public.supplier_quotes
  for select to authenticated using (public.can_read_all());
create policy quotes_write on public.supplier_quotes
  for all to authenticated using (public.can_manage()) with check (public.can_manage());

alter view public.item_prices           set (security_invoker = on);
alter view public.supplier_item_prices  set (security_invoker = on);
alter view public.procurement_variance  set (security_invoker = on);
alter view public.variance_by_category  set (security_invoker = on);

grant select on
  public.suppliers, public.items, public.supplier_quotes,
  public.item_prices, public.supplier_item_prices,
  public.procurement_variance, public.variance_by_category
  to authenticated;

grant insert, update, delete on public.suppliers, public.items to authenticated;
grant insert, update on public.supplier_quotes to authenticated;
