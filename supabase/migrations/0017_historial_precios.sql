-- =============================================================================
-- 0017_historial_precios.sql
--
-- Registro de precios de referencia + historial unificado.
--
-- Ya habia dos fuentes de precio historico: las cotizaciones de proveedor y
-- las compras reales. Agregar una tercera suelta partiria la tendencia en
-- pedazos. Por eso la tabla nueva guarda solo el precio de referencia, y una
-- vista une las tres para que la tendencia se vea completa y se sepa de donde
-- salio cada punto.
--
-- Nada se borra: un precio nuevo es una fila nueva.
-- =============================================================================

create type price_source as enum ('referencia', 'cotizacion', 'compra');

create table public.item_price_points (
  id          uuid primary key default gen_random_uuid(),
  item_id     uuid not null references public.items(id) on delete cascade,
  price_date  date not null,
  unit_price  numeric(18,4) not null check (unit_price >= 0),
  currency    currency not null,
  fx_usd      numeric(18,4) check (fx_usd is null or fx_usd > 0),
  unit_price_usd numeric(18,4) generated always as (
                  case when currency = 'USD' then unit_price
                       else round(unit_price / fx_usd, 4) end
                ) stored,
  supplier_id uuid references public.suppliers(id) on delete set null,
  note        text,
  created_by  uuid references public.profiles(id),
  created_at  timestamptz not null default now(),

  constraint price_points_fx_required check (currency = 'USD' or fx_usd is not null)
);

create index price_points_item_idx on public.item_price_points (item_id, price_date desc);

-- Un precio registrado es un hecho fechado: se corrige, no se borra.
create or replace function public.forbid_price_point_delete()
returns trigger language plpgsql as $fn$
begin
  raise exception 'Los precios registrados no se eliminan: son el historial que permite ver la tendencia.';
end;
$fn$;

create trigger item_price_points_no_delete
  before delete on public.item_price_points
  for each row execute function public.forbid_price_point_delete();

-- -----------------------------------------------------------------------------
-- item_price_history — las tres fuentes en una sola linea de tiempo.
-- -----------------------------------------------------------------------------
create view public.item_price_history as
select
  p.item_id,
  p.price_date                  as fecha,
  'referencia'::price_source    as fuente,
  p.unit_price,
  p.currency,
  p.unit_price_usd,
  s.name                        as proveedor,
  p.note                        as detalle
from public.item_price_points p
left join public.suppliers s on s.id = p.supplier_id

union all

select
  q.item_id,
  q.quote_date,
  'cotizacion'::price_source,
  q.unit_price,
  q.currency,
  q.unit_price_usd,
  s.name,
  q.notes
from public.supplier_quotes q
join public.suppliers s on s.id = q.supplier_id

union all

select
  e.item_id,
  e.expense_date,
  'compra'::price_source,
  e.unit_price,
  e.currency,
  round(e.unit_price / case when e.currency = 'USD' then 1 else e.fx_usd end, 4),
  s.name,
  e.description
from public.expenses e
left join public.suppliers s on s.id = e.supplier_id
where e.item_id is not null
  and e.status in ('recibido', 'pagado');

-- -----------------------------------------------------------------------------
-- item_price_trend — variacion entre el primer y el ultimo precio conocido.
-- Responde "cuanto se movio este item" sin tener que mirar la lista.
-- -----------------------------------------------------------------------------
create view public.item_price_trend as
with ordenado as (
  select
    item_id,
    fecha,
    unit_price_usd,
    first_value(unit_price_usd) over (partition by item_id order by fecha) as primero,
    first_value(unit_price_usd) over (
      partition by item_id order by fecha desc
    )                                                                     as ultimo,
    min(fecha) over (partition by item_id)                                as desde,
    max(fecha) over (partition by item_id)                                as hasta,
    count(*) over (partition by item_id)                                  as puntos
  from public.item_price_history
  where unit_price_usd is not null and unit_price_usd > 0
)
select distinct
  item_id,
  primero          as primer_precio_usd,
  ultimo           as ultimo_precio_usd,
  desde,
  hasta,
  puntos,
  case when primero > 0
       then round((ultimo - primero) / primero, 4)
  end              as variacion
from ordenado;

-- -----------------------------------------------------------------------------
-- RLS y permisos
-- -----------------------------------------------------------------------------
alter table public.item_price_points enable row level security;

create policy price_points_select on public.item_price_points
  for select to authenticated using (public.can_read_all());

create policy price_points_write on public.item_price_points
  for all to authenticated
  using (public.can_manage()) with check (public.can_manage());

alter view public.item_price_history set (security_invoker = on);
alter view public.item_price_trend   set (security_invoker = on);

grant select on
  public.item_price_points, public.item_price_history, public.item_price_trend
  to authenticated;

grant insert, update on public.item_price_points to authenticated;
