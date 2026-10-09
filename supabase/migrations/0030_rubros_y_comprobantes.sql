-- =============================================================================
-- 0030_rubros_y_comprobantes.sql
--
-- Clasificacion de gastos en tres niveles: Rubro > Tipo de costo > Item.
-- Y el comprobante como cabecera: un papel, varias lineas, cada una en su rubro.
--
-- DECISION CENTRAL: cada linea de un comprobante ES un gasto (expenses).
-- No hay una tabla de lineas paralela. De expenses salen el P&L, el cashflow,
-- los desvios, el historial de precios y la billetera; una segunda fuente de
-- costo obligaria a reescribir todo eso o, peor, a que los gastos nuevos no
-- aparezcan en los informes. El comprobante solo agrupa.
--
-- El rubro REEMPLAZA a la categoria como clasificacion de gastos y de
-- presupuesto, para que el desvio se lea por rubro. cost_categories sigue
-- existiendo porque el catalogo de items la usa para armar codigos, pero deja
-- de ser lo que se elige al cargar.
--
--   rubro_templates        los 20 rubros de siempre, globales
--   project_rubros         los rubros de cada obra: se copian al crearla y
--                          despues se renombran, reordenan u ocultan
--   cost_type              materiales, mano de obra, subcontrato...
--   receipts               el comprobante: proveedor, numero, total, foto
--   expense_items          desglose opcional de una linea
--   labor_details          modalidad y avance de un pago de mano de obra
--   cost_category_rubros   equivalencia categoria vieja -> rubro + tipo
-- =============================================================================

create type cost_type as enum (
  'materiales',
  'mano_de_obra',
  'subcontrato',
  'equipos_alquileres',
  'fletes_logistica',
  'otros'
);

create type payment_method as enum (
  'efectivo', 'transferencia', 'cheque', 'tarjeta', 'otro'
);

create type labor_modality as enum ('jornal', 'por_tarea', 'certificado');

-- -----------------------------------------------------------------------------
-- rubro_templates — el catalogo global.
-- "Sin clasificar" va ultimo y existe para que ningun gasto quede sin rubro:
-- es donde caen los importados y lo que no tiene equivalencia.
-- -----------------------------------------------------------------------------
create table public.rubro_templates (
  id          uuid primary key default gen_random_uuid(),
  name        text not null unique,
  sort_order  int not null,
  is_active   boolean not null default true,
  created_at  timestamptz not null default now()
);

insert into public.rubro_templates (name, sort_order) values
  ('Trabajos preliminares',            10),
  ('Movimiento de suelos',             20),
  ('Estructura',                       30),
  ('Mampostería',                      40),
  ('Cubiertas y aislaciones',          50),
  ('Revoques contrapisos y carpetas',  60),
  ('Instalación sanitaria',            70),
  ('Instalación de gas',               80),
  ('Instalación eléctrica',            90),
  ('Climatización',                   100),
  ('Construcción en seco',            110),
  ('Pisos y revestimientos',          120),
  ('Carpinterías',                    130),
  ('Herrería',                        140),
  ('Vidrios',                         150),
  ('Pintura',                         160),
  ('Equipamiento',                    170),
  ('Exteriores y parquización',       180),
  ('Limpieza final',                  190),
  ('Gastos generales',                200),
  ('Sin clasificar',                  999);

-- -----------------------------------------------------------------------------
-- project_rubros — los rubros de cada obra.
--
-- template_id recuerda de que rubro base salio, aunque se lo renombre: asi la
-- equivalencia de categorias sigue encontrando "Estructura" aunque en esta
-- obra se llame "Estructura de H°A°". Ocultar es is_active = false; borrar
-- solo se puede si nadie lo usa.
--
-- unique (id, project_id) existe para la FK compuesta de gastos y presupuesto:
-- una linea no puede apuntar al rubro de OTRA obra.
-- -----------------------------------------------------------------------------
create table public.project_rubros (
  id          uuid primary key default gen_random_uuid(),
  project_id  uuid not null references public.projects(id) on delete cascade,
  template_id uuid references public.rubro_templates(id) on delete set null,
  name        text not null,
  sort_order  int not null default 0,
  is_active   boolean not null default true,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now(),
  unique (project_id, name),
  unique (id, project_id)
);

create trigger project_rubros_set_updated_at
  before update on public.project_rubros
  for each row execute function public.set_updated_at();

create index project_rubros_project_idx on public.project_rubros (project_id, sort_order);

-- Al crear una obra se copian los rubros base.
create or replace function public.copiar_rubros_base()
returns trigger
language plpgsql
security definer
set search_path = public
as $fn$
begin
  insert into public.project_rubros (project_id, template_id, name, sort_order)
  select new.id, t.id, t.name, t.sort_order
  from public.rubro_templates t
  where t.is_active
  on conflict (project_id, name) do nothing;
  return new;
end;
$fn$;

create trigger projects_copiar_rubros
  after insert on public.projects
  for each row execute function public.copiar_rubros_base();

-- Las obras que ya existen tambien los reciben.
insert into public.project_rubros (project_id, template_id, name, sort_order)
select p.id, t.id, t.name, t.sort_order
from public.projects p
cross join public.rubro_templates t
on conflict (project_id, name) do nothing;

-- El rubro de una obra que corresponde a un rubro base. Si la obra lo borro,
-- se vuelve a crear oculto: es preferible a dejar el gasto sin rubro.
create or replace function public.rubro_de_obra(p_project uuid, p_template uuid)
returns uuid
language plpgsql
security definer
set search_path = public
as $fn$
declare
  v_id uuid;
begin
  -- Es security definer para poder crear el rubro faltante desde un trigger,
  -- asi que controla el acceso ella misma. Sin usuario (una migracion) no hay
  -- a quien controlar.
  if auth.uid() is not null
     and not (public.can_manage() and public.has_project_access(p_project)) then
    raise exception 'Sin acceso a esa obra';
  end if;

  select id into v_id
  from public.project_rubros
  where project_id = p_project and template_id = p_template
  order by is_active desc, sort_order
  limit 1;

  if v_id is null then
    insert into public.project_rubros (project_id, template_id, name, sort_order, is_active)
    select p_project, t.id, t.name, t.sort_order, false
    from public.rubro_templates t
    where t.id = p_template
    on conflict (project_id, name) do update set template_id = excluded.template_id
    returning id into v_id;
  end if;

  return v_id;
end;
$fn$;

-- -----------------------------------------------------------------------------
-- cost_category_rubros — de la categoria vieja al rubro y tipo nuevos.
-- Clasifica los gastos y lineas de presupuesto existentes, y cualquier gasto
-- que se siga cargando con categoria y sin rubro (compras, imports).
-- Una categoria sin equivalencia cae en "Sin clasificar" / "otros".
-- -----------------------------------------------------------------------------
create table public.cost_category_rubros (
  category_id uuid primary key references public.cost_categories(id) on delete cascade,
  template_id uuid not null references public.rubro_templates(id) on delete cascade,
  cost_type   cost_type not null default 'otros'
);

insert into public.cost_category_rubros (category_id, template_id, cost_type)
select c.id, t.id, m.tipo::cost_type
from (values
  (null,                           'Lote',                               'Gastos generales',                'otros'),
  ('Lote',                         'Trámites',                           'Gastos generales',                'otros'),
  (null,                           'Materiales Corralón/Hormigón',       'Sin clasificar',                  'materiales'),
  ('Materiales Corralón/Hormigón', 'Pilotes',                            'Estructura',                      'materiales'),
  ('Materiales Corralón/Hormigón', 'Columnas',                           'Estructura',                      'materiales'),
  ('Materiales Corralón/Hormigón', 'Vigas + Losa S/PB',                  'Estructura',                      'materiales'),
  ('Materiales Corralón/Hormigón', 'Contrapisos y Carpetas',             'Revoques contrapisos y carpetas', 'materiales'),
  ('Materiales Corralón/Hormigón', 'Mampostería',                        'Mampostería',                     'materiales'),
  ('Materiales Corralón/Hormigón', 'Revoques',                           'Revoques contrapisos y carpetas', 'materiales'),
  ('Materiales Corralón/Hormigón', 'Yesería + Pintura',                  'Pintura',                         'materiales'),
  (null,                           'Sanitario',                          'Instalación sanitaria',           'materiales'),
  ('Sanitario',                    'Losa Radiante',                      'Climatización',                   'materiales'),
  ('Sanitario',                    'Instalación Agua / Sanitaria / Gas', 'Instalación sanitaria',           'materiales'),
  (null,                           'Electricidad',                       'Instalación eléctrica',           'materiales'),
  ('Electricidad',                 'Instalación Eléctrica',              'Instalación eléctrica',           'materiales'),
  ('Electricidad',                 'Cables',                             'Instalación eléctrica',           'materiales'),
  ('Electricidad',                 'Tablero',                            'Instalación eléctrica',           'materiales'),
  (null,                           'Terminaciones',                      'Sin clasificar',                  'materiales'),
  ('Terminaciones',                'Pisos y Revestimientos',             'Pisos y revestimientos',          'materiales'),
  ('Terminaciones',                'Carpintería',                        'Carpinterías',                    'materiales'),
  ('Terminaciones',                'Muebles',                            'Equipamiento',                    'materiales'),
  ('Terminaciones',                'Herrería',                           'Herrería',                        'materiales'),
  (null,                           'Mano de obra',                       'Sin clasificar',                  'mano_de_obra'),
  ('Mano de obra',                 'Jornales',                           'Sin clasificar',                  'mano_de_obra'),
  ('Mano de obra',                 'Contratistas',                       'Sin clasificar',                  'subcontrato'),
  (null,                           'Varios',                             'Sin clasificar',                  'otros'),
  ('Varios',                       'Otros',                              'Sin clasificar',                  'otros'),
  (null,                           'Costos indirectos',                  'Gastos generales',                'otros'),
  ('Costos indirectos',            'Administración',                     'Gastos generales',                'otros'),
  ('Costos indirectos',            'Proyecto y arquitectura',            'Gastos generales',                'otros'),
  ('Costos indirectos',            'Seguros',                            'Gastos generales',                'otros'),
  ('Costos indirectos',            'Gastos legales',                     'Gastos generales',                'otros'),
  ('Costos indirectos',            'Comercialización',                   'Gastos generales',                'otros'),
  ('Costos indirectos',            'Financiación',                       'Gastos generales',                'otros'),
  ('Costos indirectos',            'Expensas',                           'Gastos generales',                'otros'),
  ('Costos indirectos',            'Gestoría',                           'Gastos generales',                'otros')
) as m(parent, name, rubro, tipo)
join public.cost_categories c on c.name = m.name
left join public.cost_categories p on p.id = c.parent_id
join public.rubro_templates t on t.name = m.rubro
where coalesce(p.name, '') = coalesce(m.parent, '')
on conflict (category_id) do nothing;

-- -----------------------------------------------------------------------------
-- receipts — el comprobante.
--
-- Lleva moneda y cotizacion como todo lo demas: sus lineas las heredan. Un
-- comprobante es un solo papel en una sola moneda.
-- -----------------------------------------------------------------------------
create table public.receipts (
  id              uuid primary key default gen_random_uuid(),
  project_id      uuid not null references public.projects(id) on delete restrict,
  supplier_id     uuid references public.suppliers(id) on delete restrict,
  supplier_name   text,
  receipt_date    date not null,
  number          text,
  total           numeric(18,2) not null check (total > 0),
  currency        currency not null,
  fx_usd          numeric(18,4) check (fx_usd is null or fx_usd > 0),
  total_usd       numeric(18,2) generated always as (
                    case when currency = 'USD' then total
                         else round(total / fx_usd, 2) end
                  ) stored,
  payment_method  payment_method,
  -- La foto en el bucket "comprobantes": <project_id>/<receipt_id>/<archivo>
  storage_path    text unique,
  notes           text,
  created_by      uuid references public.profiles(id) default auth.uid(),
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now(),

  constraint receipts_fx_required check (currency = 'USD' or fx_usd is not null)
);

create trigger receipts_set_updated_at
  before update on public.receipts
  for each row execute function public.set_updated_at();

create trigger receipts_audit
  after insert or update or delete on public.receipts
  for each row execute function public.log_audit();

create index receipts_project_idx on public.receipts (project_id, receipt_date desc);
create index receipts_date_idx    on public.receipts (receipt_date desc);

-- -----------------------------------------------------------------------------
-- Gastos: rubro, tipo de costo y comprobante.
-- -----------------------------------------------------------------------------
alter table public.expenses
  add column receipt_id       uuid references public.receipts(id) on delete restrict,
  add column project_rubro_id uuid,
  add column cost_type        cost_type;

alter table public.budget_lines
  add column project_rubro_id uuid;

-- Clasificacion de lo existente por la equivalencia de su categoria.
update public.expenses e
set project_rubro_id = public.rubro_de_obra(
      e.project_id,
      coalesce(m.template_id,
               (select id from public.rubro_templates where name = 'Sin clasificar'))),
    cost_type = coalesce(m.cost_type, 'otros')
from public.expenses e2
left join public.cost_category_rubros m on m.category_id = e2.category_id
where e2.id = e.id;

update public.budget_lines b
set project_rubro_id = public.rubro_de_obra(
      b.project_id,
      coalesce(m.template_id,
               (select id from public.rubro_templates where name = 'Sin clasificar')))
from public.budget_lines b2
left join public.cost_category_rubros m on m.category_id = b2.category_id
where b2.id = b.id;

-- Lo que se cargue sin rubro (formularios viejos, compras, imports) se
-- clasifica solo, por la categoria si la tiene. Son dos funciones porque el
-- presupuesto no tiene tipo de costo, y plpgsql no deja nombrar un campo que
-- el registro no tiene ni siquiera detras de un if.
create or replace function public.rubro_por_categoria(p_project uuid, p_category uuid)
returns uuid
language sql
as $fn$
  select public.rubro_de_obra(
    p_project,
    coalesce(
      (select template_id from public.cost_category_rubros where category_id = p_category),
      (select id from public.rubro_templates where name = 'Sin clasificar')))
$fn$;

create or replace function public.clasificar_gasto()
returns trigger
language plpgsql
as $fn$
begin
  if new.project_rubro_id is null then
    new.project_rubro_id := public.rubro_por_categoria(new.project_id, new.category_id);
  end if;
  if new.cost_type is null then
    new.cost_type := coalesce(
      (select cost_type from public.cost_category_rubros where category_id = new.category_id),
      'otros');
  end if;
  return new;
end;
$fn$;

create or replace function public.clasificar_presupuesto()
returns trigger
language plpgsql
as $fn$
begin
  if new.project_rubro_id is null then
    new.project_rubro_id := public.rubro_por_categoria(new.project_id, new.category_id);
  end if;
  return new;
end;
$fn$;

create trigger expenses_clasificar
  before insert or update on public.expenses
  for each row execute function public.clasificar_gasto();

create trigger budget_lines_clasificar
  before insert or update on public.budget_lines
  for each row execute function public.clasificar_presupuesto();

alter table public.expenses
  alter column project_rubro_id set not null,
  alter column cost_type set not null,
  add constraint expenses_rubro_misma_obra
    foreign key (project_rubro_id, project_id)
    references public.project_rubros (id, project_id) on delete restrict;

alter table public.budget_lines
  alter column project_rubro_id set not null,
  add constraint budget_lines_rubro_misma_obra
    foreign key (project_rubro_id, project_id)
    references public.project_rubros (id, project_id) on delete restrict;

create index expenses_rubro_idx     on public.expenses (project_rubro_id);
create index expenses_cost_type_idx on public.expenses (cost_type);
create index expenses_receipt_idx   on public.expenses (receipt_id);
create index budget_lines_rubro_idx on public.budget_lines (project_rubro_id);

-- -----------------------------------------------------------------------------
-- Los gastos ya cargados que son un papel real (recibidos o pagados) pasan a
-- tener su comprobante, uno por gasto. Los estimados y comprometidos no son un
-- comprobante todavia: quedan sin cabecera, como una orden de compra.
-- -----------------------------------------------------------------------------
with nuevos as (
  insert into public.receipts
    (id, project_id, supplier_id, supplier_name, receipt_date, total,
     currency, fx_usd, notes, created_by, created_at)
  select
    e.id,  -- mismo id que el gasto, solo para poder enlazarlos en el paso siguiente
    e.project_id, e.supplier_id, e.supplier_name,
    coalesce(e.paid_date, e.expense_date),
    round(e.qty * e.unit_price, 2),
    e.currency, e.fx_usd,
    'Migrado desde el gasto cargado antes de los comprobantes',
    e.created_by, e.created_at
  from public.expenses e
  where e.status in ('recibido', 'pagado')
    and round(e.qty * e.unit_price, 2) > 0
  returning id
)
update public.expenses e
set receipt_id = n.id
from nuevos n
where n.id = e.id;

-- -----------------------------------------------------------------------------
-- La linea hereda del comprobante la obra, la moneda y la cotizacion, y entre
-- todas no pueden pasarse del total.
-- -----------------------------------------------------------------------------
create or replace function public.linea_de_comprobante()
returns trigger
language plpgsql
as $fn$
declare
  r public.receipts;
begin
  if new.receipt_id is null then
    return new;
  end if;

  select * into r from public.receipts where id = new.receipt_id;
  if r.project_id <> new.project_id then
    raise exception 'La línea es de otra obra que su comprobante';
  end if;

  new.currency := r.currency;
  new.fx_usd   := r.fx_usd;
  return new;
end;
$fn$;

create trigger expenses_linea_de_comprobante
  before insert or update on public.expenses
  for each row execute function public.linea_de_comprobante();

-- Cuanto suman las lineas vigentes de un comprobante, en su moneda.
create or replace function public.lineas_de_comprobante(p_receipt uuid)
returns numeric
language sql
stable
as $fn$
  select coalesce(sum(round(qty * unit_price, 2)), 0)
  from public.expenses
  where receipt_id = p_receipt and status <> 'anulado'
$fn$;

-- El control es uno solo; los disparadores son dos porque plpgsql no deja
-- nombrar new.receipt_id en un disparador de receipts, ni siquiera en una rama
-- que no se ejecuta.
create or replace function public.chequear_total(p_receipt uuid)
returns void
language plpgsql
as $fn$
declare
  v_total  numeric;
  v_lineas numeric;
begin
  if p_receipt is null then
    return;
  end if;

  select total into v_total from public.receipts where id = p_receipt;
  v_lineas := public.lineas_de_comprobante(p_receipt);

  if v_lineas > v_total + 0.009 then
    raise exception
      'Las líneas suman % y el comprobante es por %. No pueden pasarse del total.',
      v_lineas, v_total;
  end if;
end;
$fn$;

create or replace function public.chequear_total_desde_linea()
returns trigger
language plpgsql
as $fn$
begin
  perform public.chequear_total(new.receipt_id);
  return null;
end;
$fn$;

create or replace function public.chequear_total_desde_comprobante()
returns trigger
language plpgsql
as $fn$
begin
  perform public.chequear_total(new.id);
  return null;
end;
$fn$;

create trigger expenses_chequear_total
  after insert or update on public.expenses
  for each row execute function public.chequear_total_desde_linea();

create trigger receipts_chequear_total
  after update of total on public.receipts
  for each row execute function public.chequear_total_desde_comprobante();

-- Si cambia la moneda o la cotizacion del comprobante, cambian sus lineas.
create or replace function public.propagar_moneda_comprobante()
returns trigger
language plpgsql
as $fn$
begin
  update public.expenses
  set currency = new.currency, fx_usd = new.fx_usd
  where receipt_id = new.id
    and (currency is distinct from new.currency or fx_usd is distinct from new.fx_usd);
  return null;
end;
$fn$;

create trigger receipts_propagar_moneda
  after update of currency, fx_usd on public.receipts
  for each row execute function public.propagar_moneda_comprobante();

-- Los gastos se pueden borrar (0029). Un comprobante que se queda sin lineas
-- no explica nada: se borra con la ultima. Su foto queda en el bucket.
create or replace function public.borrar_comprobante_vacio()
returns trigger
language plpgsql
as $fn$
begin
  if old.receipt_id is not null
     and not exists (select 1 from public.expenses where receipt_id = old.receipt_id) then
    delete from public.receipts where id = old.receipt_id;
  end if;
  return null;
end;
$fn$;

create trigger expenses_borrar_comprobante_vacio
  after delete on public.expenses
  for each row execute function public.borrar_comprobante_vacio();

-- -----------------------------------------------------------------------------
-- expense_items — desglose opcional de una linea.
-- item_id enlaza al catalogo (y a su historial de precios) cuando corresponde;
-- si no, queda la descripcion libre. Es la linea la que manda el costo: el
-- desglose explica, no suma.
-- -----------------------------------------------------------------------------
create table public.expense_items (
  id          uuid primary key default gen_random_uuid(),
  expense_id  uuid not null references public.expenses(id) on delete cascade,
  item_id     uuid references public.items(id) on delete set null,
  description text not null,
  qty         numeric(18,4) not null default 1 check (qty > 0),
  unit        text not null default 'un',
  unit_price  numeric(18,4) not null default 0 check (unit_price >= 0),
  total       numeric(18,2) generated always as (round(qty * unit_price, 2)) stored,
  created_by  uuid references public.profiles(id) default auth.uid(),
  created_at  timestamptz not null default now()
);

create index expense_items_expense_idx on public.expense_items (expense_id);
create index expense_items_item_idx    on public.expense_items (item_id);

-- -----------------------------------------------------------------------------
-- labor_details — de que es un pago de mano de obra.
-- Uno por linea. Solo tiene sentido en mano de obra o subcontrato.
-- -----------------------------------------------------------------------------
create table public.labor_details (
  expense_id   uuid primary key references public.expenses(id) on delete cascade,
  modality     labor_modality not null,
  progress_pct numeric(5,4) check (progress_pct is null or (progress_pct >= 0 and progress_pct <= 1)),
  worker       text not null,
  is_advance   boolean not null default false,
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now()
);

create trigger labor_details_set_updated_at
  before update on public.labor_details
  for each row execute function public.set_updated_at();

create index labor_details_worker_idx on public.labor_details (lower(worker));

create or replace function public.chequear_detalle_mano_de_obra()
returns trigger
language plpgsql
as $fn$
begin
  if not exists (
    select 1 from public.expenses
    where id = new.expense_id and cost_type in ('mano_de_obra', 'subcontrato')
  ) then
    raise exception 'El detalle de mano de obra va solo en líneas de mano de obra o subcontrato';
  end if;
  return new;
end;
$fn$;

create trigger labor_details_chequear
  before insert or update on public.labor_details
  for each row execute function public.chequear_detalle_mano_de_obra();

-- =============================================================================
-- VISTAS
-- =============================================================================

-- Comprobantes con lo asignado y lo que falta asignar.
create view public.receipt_balance as
select
  r.id                                       as receipt_id,
  r.project_id,
  r.receipt_date,
  coalesce(s.name, r.supplier_name)          as proveedor,
  r.number,
  r.currency,
  r.total,
  r.total_usd,
  r.payment_method,
  r.storage_path,
  public.lineas_de_comprobante(r.id)         as asignado,
  r.total - public.lineas_de_comprobante(r.id) as sin_asignar,
  (select count(*) from public.expenses e
    where e.receipt_id = r.id and e.status <> 'anulado') as lineas
from public.receipts r
left join public.suppliers s on s.id = r.supplier_id;

-- Para autocompletar el desglose: el catalogo, mas todo lo que ya se escribio
-- a mano. Se alimenta solo, porque sale de lo cargado.
create view public.expense_item_suggestions as
select
  'catalogo'::text  as origen,
  i.id              as item_id,
  i.description,
  i.unit,
  null::numeric     as ultimo_precio,
  null::currency    as moneda,
  0::bigint         as usos
from public.items i
where i.is_active

union all

select
  'historial',
  null,
  h.description,
  h.unit,
  h.ultimo_precio,
  h.moneda,
  h.usos
from (
  select distinct on (lower(ei.description), ei.unit)
    ei.description,
    ei.unit,
    ei.unit_price as ultimo_precio,
    e.currency    as moneda,
    count(*) over (partition by lower(ei.description), ei.unit) as usos
  from public.expense_items ei
  join public.expenses e on e.id = ei.expense_id
  where ei.item_id is null
  order by lower(ei.description), ei.unit, ei.created_at desc
) h;

-- Totales por rubro de cada obra: presupuesto contra real.
create view public.rubro_totals as
with gasto as (
  select
    project_rubro_id,
    coalesce(sum(amount_usd) filter (where status in ('recibido', 'pagado')), 0) as actual_usd,
    coalesce(sum(amount_usd) filter (where status = 'comprometido'), 0)          as committed_usd
  from public.expenses
  where status <> 'anulado'
  group by project_rubro_id
),
budget as (
  select
    project_rubro_id,
    sum(total_original_usd) as budget_usd,
    sum(total_forecast_usd) as forecast_usd
  from public.budget_lines
  group by project_rubro_id
)
select
  r.project_id,
  p.code,
  p.name                             as project_name,
  r.id                               as project_rubro_id,
  r.name                             as rubro,
  r.sort_order,
  r.is_active,
  coalesce(b.budget_usd, 0)          as budget_usd,
  coalesce(b.forecast_usd, 0)        as forecast_usd,
  coalesce(g.actual_usd, 0)          as actual_usd,
  coalesce(g.committed_usd, 0)       as committed_usd,
  coalesce(g.actual_usd, 0) - coalesce(b.forecast_usd, 0) as desvio_usd
from public.project_rubros r
join public.projects p on p.id = r.project_id
left join gasto  g on g.project_rubro_id = r.id
left join budget b on b.project_rubro_id = r.id;

-- Totales por tipo de costo de cada obra.
create view public.cost_type_totals as
select
  e.project_id,
  e.cost_type,
  coalesce(sum(e.amount_usd) filter (where e.status in ('recibido', 'pagado')), 0) as actual_usd,
  coalesce(sum(e.amount_usd) filter (where e.status = 'comprometido'), 0)          as committed_usd
from public.expenses e
where e.status <> 'anulado'
group by e.project_id, e.cost_type;

-- El cruce: rubro por tipo de costo, por obra. Solo las combinaciones usadas.
create view public.rubro_cost_type_totals as
select
  e.project_id,
  p.code,
  r.id         as project_rubro_id,
  r.name       as rubro,
  r.sort_order,
  e.cost_type,
  coalesce(sum(e.amount_usd) filter (where e.status in ('recibido', 'pagado')), 0) as actual_usd,
  coalesce(sum(e.amount_usd) filter (where e.status = 'comprometido'), 0)          as committed_usd
from public.expenses e
join public.project_rubros r on r.id = e.project_rubro_id
join public.projects p       on p.id = e.project_id
where e.status <> 'anulado'
group by e.project_id, p.code, r.id, r.name, r.sort_order, e.cost_type;

-- Pagos de mano de obra por trabajador o cuadrilla: cuanto se le pago, cuanto
-- fue adelanto y hasta que avance llego.
create view public.labor_payments as
select
  e.project_id,
  min(l.worker)                                   as worker,
  string_agg(distinct l.modality::text, ', ')     as modalidades,
  count(*)                                        as pagos,
  sum(e.amount_usd)                               as pagado_usd,
  coalesce(sum(e.amount_usd) filter (where l.is_advance), 0) as adelantos_usd,
  (array_agg(l.progress_pct order by coalesce(e.paid_date, e.expense_date) desc, e.created_at desc)
     filter (where l.progress_pct is not null))[1] as ultimo_avance,
  max(coalesce(e.paid_date, e.expense_date))      as ultimo_pago
from public.labor_details l
join public.expenses e on e.id = l.expense_id
where e.status in ('recibido', 'pagado')
group by e.project_id, lower(l.worker);

-- budget_variance suma el rubro al final (create or replace solo deja agregar).
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
  )                             as pendiente_usd,
  b.price_client_usd,
  b.total_client_usd,
  case when b.total_client_usd is null then null
       else b.total_client_usd - b.total_forecast_usd
  end                           as margen_presupuestado_usd,
  b.project_rubro_id,
  pr.name                       as rubro,
  pr.sort_order                 as rubro_orden
from public.budget_lines b
left join public.cost_category_paths cp on cp.id = b.category_id
left join public.project_rubros pr on pr.id = b.project_rubro_id
left join public.tasks t on t.id = b.task_id
left join public.expenses e on e.budget_line_id = b.id and e.status <> 'anulado'
group by b.id, b.project_id, b.description, cp.path, b.unit,
         b.qty_original, b.price_original_usd,
         b.total_original_usd, b.total_forecast_usd,
         b.planned_date, t.name, b.price_client_usd, b.total_client_usd,
         b.project_rubro_id, pr.name, pr.sort_order;

-- =============================================================================
-- RPC
-- =============================================================================

-- -----------------------------------------------------------------------------
-- guardar_comprobante — comprobante, lineas, desglose y mano de obra, todo o
-- nada. Si cualquier parte falla no queda un comprobante a medias.
--
-- p_receipt: { project_id, receipt_date, total, currency, fx_usd, supplier_id,
--              supplier_name, number, payment_method, notes, status, paid_by }
-- p_lines:   [ { project_rubro_id, cost_type, amount, note,
--                items: [ { item_id, description, qty, unit, unit_price } ],
--                labor: { modality, progress_pct, worker, is_advance } } ]
--
-- La foto se sube despues, con el id que devuelve: la ruta lleva ese id.
-- -----------------------------------------------------------------------------
create or replace function public.guardar_comprobante(p_receipt jsonb, p_lines jsonb)
returns uuid
language plpgsql
security invoker
as $fn$
declare
  v_receipt  uuid;
  v_project  uuid := (p_receipt->>'project_id')::uuid;
  v_fecha    date := coalesce((p_receipt->>'receipt_date')::date, current_date);
  v_status   expense_status := coalesce(p_receipt->>'status', 'pagado')::expense_status;
  v_total    numeric := (p_receipt->>'total')::numeric;
  v_suma     numeric := 0;
  v_line     jsonb;
  v_item     jsonb;
  v_expense  uuid;
  v_rubro    text;
  v_tipo     cost_type;
  v_monto    numeric;
begin
  if v_project is null then
    raise exception 'El comprobante tiene que ser de una obra';
  end if;
  if p_lines is null or jsonb_typeof(p_lines) <> 'array' or jsonb_array_length(p_lines) = 0 then
    raise exception 'El comprobante tiene que tener al menos una línea';
  end if;
  if v_status = 'anulado' then
    raise exception 'Un comprobante nuevo no puede nacer anulado';
  end if;

  select coalesce(sum((l->>'amount')::numeric), 0) into v_suma
  from jsonb_array_elements(p_lines) l;

  -- Sin total explicito, el total es la suma de las lineas.
  v_total := coalesce(v_total, v_suma);
  if v_suma > v_total + 0.009 then
    raise exception 'Las líneas suman % y el comprobante es por %.', v_suma, v_total;
  end if;

  insert into public.receipts
    (project_id, supplier_id, supplier_name, receipt_date, number, total,
     currency, fx_usd, payment_method, notes)
  values (
    v_project,
    nullif(p_receipt->>'supplier_id', '')::uuid,
    nullif(p_receipt->>'supplier_name', ''),
    v_fecha,
    nullif(p_receipt->>'number', ''),
    v_total,
    coalesce(p_receipt->>'currency', 'ARS')::currency,
    nullif(p_receipt->>'fx_usd', '')::numeric,
    nullif(p_receipt->>'payment_method', '')::payment_method,
    nullif(p_receipt->>'notes', '')
  )
  returning id into v_receipt;

  for v_line in select * from jsonb_array_elements(p_lines) loop
    v_monto := (v_line->>'amount')::numeric;
    if v_monto is null or v_monto <= 0 then
      raise exception 'Cada línea tiene que tener un monto mayor a cero';
    end if;
    v_tipo := coalesce(v_line->>'cost_type', 'otros')::cost_type;

    select name into v_rubro
    from public.project_rubros
    where id = (v_line->>'project_rubro_id')::uuid and project_id = v_project;
    if v_rubro is null then
      raise exception 'El rubro de una línea no es de esta obra';
    end if;

    insert into public.expenses
      (project_id, receipt_id, project_rubro_id, cost_type, description,
       supplier_id, supplier_name, status, expense_date, paid_date,
       qty, unit_price, currency, fx_usd, paid_by)
    values (
      v_project, v_receipt, (v_line->>'project_rubro_id')::uuid, v_tipo,
      coalesce(nullif(v_line->>'note', ''), v_rubro || ' · ' || replace(v_tipo::text, '_', ' ')),
      nullif(p_receipt->>'supplier_id', '')::uuid,
      nullif(p_receipt->>'supplier_name', ''),
      v_status, v_fecha,
      case when v_status = 'pagado' then v_fecha end,
      1, v_monto,
      coalesce(p_receipt->>'currency', 'ARS')::currency,
      nullif(p_receipt->>'fx_usd', '')::numeric,
      coalesce(nullif(p_receipt->>'paid_by', ''), 'estudio')::expense_payer
    )
    returning id into v_expense;

    if jsonb_typeof(v_line->'items') = 'array' then
      for v_item in select * from jsonb_array_elements(v_line->'items') loop
        insert into public.expense_items (expense_id, item_id, description, qty, unit, unit_price)
        values (
          v_expense,
          nullif(v_item->>'item_id', '')::uuid,
          v_item->>'description',
          coalesce((v_item->>'qty')::numeric, 1),
          coalesce(nullif(v_item->>'unit', ''), 'un'),
          coalesce((v_item->>'unit_price')::numeric, 0)
        );
      end loop;
    end if;

    if jsonb_typeof(v_line->'labor') = 'object' then
      insert into public.labor_details (expense_id, modality, progress_pct, worker, is_advance)
      values (
        v_expense,
        (v_line->'labor'->>'modality')::labor_modality,
        nullif(v_line->'labor'->>'progress_pct', '')::numeric,
        v_line->'labor'->>'worker',
        coalesce((v_line->'labor'->>'is_advance')::boolean, false)
      );
    end if;
  end loop;

  return v_receipt;
end;
$fn$;

-- -----------------------------------------------------------------------------
-- guardar_items_linea — reemplaza el desglose de una linea de una vez.
-- El desglose se edita despues de cargar el gasto, y se guarda entero: es mas
-- simple y no deja estados intermedios.
-- -----------------------------------------------------------------------------
create or replace function public.guardar_items_linea(p_expense uuid, p_items jsonb)
returns integer
language plpgsql
security invoker
as $fn$
declare
  v_item jsonb;
  v_n    integer := 0;
begin
  if not exists (select 1 from public.expenses where id = p_expense) then
    raise exception 'No existe esa línea de gasto';
  end if;

  delete from public.expense_items where expense_id = p_expense;

  if jsonb_typeof(p_items) = 'array' then
    for v_item in select * from jsonb_array_elements(p_items) loop
      continue when coalesce(trim(v_item->>'description'), '') = '';
      insert into public.expense_items (expense_id, item_id, description, qty, unit, unit_price)
      values (
        p_expense,
        nullif(v_item->>'item_id', '')::uuid,
        trim(v_item->>'description'),
        coalesce(nullif(v_item->>'qty', '')::numeric, 1),
        coalesce(nullif(v_item->>'unit', ''), 'un'),
        coalesce(nullif(v_item->>'unit_price', '')::numeric, 0)
      );
      v_n := v_n + 1;
    end loop;
  end if;

  return v_n;
end;
$fn$;

-- =============================================================================
-- RLS — el mismo criterio que las obras: se ve lo de las obras a las que se
-- tiene acceso, y escribe quien gestiona, solo en esas obras.
-- =============================================================================
alter table public.rubro_templates      enable row level security;
alter table public.project_rubros       enable row level security;
alter table public.cost_category_rubros enable row level security;
alter table public.receipts             enable row level security;
alter table public.expense_items        enable row level security;
alter table public.labor_details        enable row level security;

-- Los catalogos los lee cualquiera que haya iniciado sesion.
create policy rubro_templates_select on public.rubro_templates
  for select to authenticated using (auth.uid() is not null);
create policy rubro_templates_write on public.rubro_templates
  for all to authenticated using (public.can_manage()) with check (public.can_manage());

create policy cost_category_rubros_select on public.cost_category_rubros
  for select to authenticated using (auth.uid() is not null);
create policy cost_category_rubros_write on public.cost_category_rubros
  for all to authenticated using (public.can_manage()) with check (public.can_manage());

create policy project_rubros_select on public.project_rubros
  for select to authenticated using (public.has_project_access(project_id));
create policy project_rubros_write on public.project_rubros
  for all to authenticated
  using (public.can_manage() and public.has_project_access(project_id))
  with check (public.can_manage() and public.has_project_access(project_id));

create policy receipts_select on public.receipts
  for select to authenticated using (public.has_project_access(project_id));
create policy receipts_write on public.receipts
  for all to authenticated
  using (public.can_manage() and public.has_project_access(project_id))
  with check (public.can_manage() and public.has_project_access(project_id));

create policy expense_items_select on public.expense_items
  for select to authenticated
  using (exists (select 1 from public.expenses e
                 where e.id = expense_id and public.has_project_access(e.project_id)));
create policy expense_items_write on public.expense_items
  for all to authenticated
  using (public.can_manage() and exists (
           select 1 from public.expenses e
           where e.id = expense_id and public.has_project_access(e.project_id)))
  with check (public.can_manage() and exists (
           select 1 from public.expenses e
           where e.id = expense_id and public.has_project_access(e.project_id)));

create policy labor_details_select on public.labor_details
  for select to authenticated
  using (exists (select 1 from public.expenses e
                 where e.id = expense_id and public.has_project_access(e.project_id)));
create policy labor_details_write on public.labor_details
  for all to authenticated
  using (public.can_manage() and exists (
           select 1 from public.expenses e
           where e.id = expense_id and public.has_project_access(e.project_id)))
  with check (public.can_manage() and exists (
           select 1 from public.expenses e
           where e.id = expense_id and public.has_project_access(e.project_id)));

alter view public.receipt_balance          set (security_invoker = on);
alter view public.expense_item_suggestions set (security_invoker = on);
alter view public.rubro_totals             set (security_invoker = on);
alter view public.cost_type_totals         set (security_invoker = on);
alter view public.rubro_cost_type_totals   set (security_invoker = on);
alter view public.labor_payments           set (security_invoker = on);
alter view public.budget_variance          set (security_invoker = on);

-- -----------------------------------------------------------------------------
-- Privilegios explicitos.
-- -----------------------------------------------------------------------------
grant select on
  public.rubro_templates, public.project_rubros, public.cost_category_rubros,
  public.receipts, public.expense_items, public.labor_details,
  public.receipt_balance, public.expense_item_suggestions, public.rubro_totals,
  public.cost_type_totals, public.rubro_cost_type_totals, public.labor_payments,
  public.budget_variance
  to authenticated;

grant insert, update on public.rubro_templates to authenticated;
-- delete en receipts: solo lo usa el borrado del comprobante que queda vacio.
grant insert, update, delete on public.receipts to authenticated;
grant insert, update, delete on
  public.project_rubros, public.cost_category_rubros,
  public.expense_items, public.labor_details
  to authenticated;

grant execute on function public.guardar_comprobante(jsonb, jsonb)   to authenticated;
grant execute on function public.guardar_items_linea(uuid, jsonb)    to authenticated;
grant execute on function public.lineas_de_comprobante(uuid)         to authenticated;
grant execute on function public.rubro_de_obra(uuid, uuid)           to authenticated;
grant execute on function public.rubro_por_categoria(uuid, uuid)     to authenticated;
