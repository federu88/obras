-- =============================================================================
-- 0032_catalogo_unico.sql
--
-- El catalogo deja de estar partido en Tecnicas / Gastos del proyecto /
-- Honorarios: es uno solo, "Gastos y compras", ordenado por categorias planas.
--
--   catalog_categories   las categorias del catalogo, con un prefijo de codigo
--   items                el codigo se arma solo: CATEGORIA-QUE ES-numero
--                        la descripcion es "Que es · Marca"; la nota es libre
--   titulo()             todo lo que se escribe queda "Lava Manos": primera
--                        letra de cada palabra en mayuscula, el resto minuscula
--
-- cost_categories NO se toca: la siguen usando el presupuesto y los gastos
-- viejos. El catalogo deja de apuntarla.
--
-- BORRA EL CATALOGO: items, historial de precios, cotizaciones, marcas y
-- "que es". Los gastos y lineas de presupuesto que apuntaban a un item se
-- conservan, solo pierden el vinculo.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. titulo() — "lava  MANOS " -> "Lava Manos".
-- initcap ya pone en minuscula el resto de cada palabra.
-- -----------------------------------------------------------------------------
create or replace function public.titulo(p_texto text)
returns text
language sql
immutable
as $fn$
  select nullif(initcap(regexp_replace(btrim(coalesce(p_texto, '')), '\s+', ' ', 'g')), '')
$fn$;

grant execute on function public.titulo(text) to authenticated;

-- initcap depende del locale de la base: con uno que no entienda acentos daria
-- "InstalacióN". Mejor frenar aca que llenar el catalogo de nombres rotos.
do $chequeo$
begin
  if public.titulo('  instalación  ELÉCTRICA ') is distinct from 'Instalación Eléctrica' then
    raise exception 'titulo() no maneja acentos en este locale: dio %',
      public.titulo('  instalación  ELÉCTRICA ');
  end if;
end
$chequeo$;

create or replace function public.nombre_en_titulo()
returns trigger
language plpgsql
as $fn$
begin
  new.name := public.titulo(new.name);
  return new;
end;
$fn$;

create trigger brands_titulo
  before insert or update of name on public.brands
  for each row execute function public.nombre_en_titulo();

create trigger item_types_titulo
  before insert or update of name on public.item_types
  for each row execute function public.nombre_en_titulo();

-- -----------------------------------------------------------------------------
-- 2. catalog_categories
--
-- code es el prefijo de los codigos de sus items. Se genera del nombre: una
-- palabra -> sus 3 primeras letras (Corralon -> COR); varias -> inicial de la
-- primera + 2 letras de la segunda (Artefactos Sanitarios -> ASA). Las
-- palabras chicas (y, de, del...) no cuentan. Si choca, se le agrega un numero.
-- -----------------------------------------------------------------------------
create table public.catalog_categories (
  id         uuid primary key default gen_random_uuid(),
  name       text not null,
  normalized text generated always as (public.normalizar(name)) stored,
  code       text not null unique,
  examples   text,
  sort_order int not null default 0,
  created_at timestamptz not null default now(),
  constraint catalog_categories_name_unica unique (normalized)
);

create or replace function public.prefijo_categoria(p_name text)
returns text
language sql
immutable
as $fn$
  with palabras as (
    select array_remove(
             array(
               select w from unnest(
                 regexp_split_to_array(regexp_replace(public.normalizar(p_name), '[^a-z ]', '', 'g'), ' ')
               ) as w
               where length(w) > 0 and w not in ('y', 'e', 'de', 'del', 'la', 'el', 'los', 'las', 'en', 'a', 'o')
             ), null) as p
  )
  select upper(
    case
      when coalesce(array_length(p, 1), 0) = 0 then 'CAT'
      when array_length(p, 1) = 1 then left(p[1], 3)
      else left(p[1], 1) || left(p[2], 2)
    end)
  from palabras
$fn$;

create or replace function public.completar_categoria()
returns trigger
language plpgsql
as $fn$
declare
  base text;
  n    int := 1;
begin
  new.name := public.titulo(new.name);
  new.examples := public.titulo(new.examples);

  if new.code is null or btrim(new.code) = '' then
    base := public.prefijo_categoria(new.name);
    new.code := base;
    while exists (select 1 from public.catalog_categories c
                   where c.code = new.code and c.id <> new.id) loop
      n := n + 1;
      new.code := base || n;
    end loop;
  end if;

  if tg_op = 'INSERT' and new.sort_order = 0 then
    new.sort_order := coalesce((select max(sort_order) from public.catalog_categories), 0) + 10;
  end if;
  return new;
end;
$fn$;

create trigger catalog_categories_completar
  before insert or update on public.catalog_categories
  for each row execute function public.completar_categoria();

insert into public.catalog_categories (name, examples, sort_order) values
  ('Procedimientos y cumplimientos', 'Gestoría, cartel de obra, luz',           10),
  ('Movimiento de tierra',           null,                                      20),
  ('Corralón',                       'Hierros, ladrillos, mallas',              30),
  ('Terminaciones',                  'Pintura, yeso, pisos, zócalos',           40),
  ('Instalación sanitaria',          null,                                      50),
  ('Losa radiante',                  null,                                      60),
  ('Instalación eléctrica',          null,                                      70),
  ('Carpintería',                    'Aberturas, mueble de cocina, puerta de entrada', 80),
  ('Artefactos sanitarios',          null,                                      90),
  ('Artefactos eléctricos',          null,                                     100),
  ('Honorarios',                     null,                                     110),
  ('Varios',                         'Baño químico, volquetes',                120);

alter table public.catalog_categories enable row level security;

create policy catalog_categories_select on public.catalog_categories
  for select to authenticated using (public.can_read_all());
create policy catalog_categories_write on public.catalog_categories
  for all to authenticated
  using (public.can_manage()) with check (public.can_manage());

grant select, insert, update, delete on public.catalog_categories to authenticated;

-- -----------------------------------------------------------------------------
-- 3. Borrar el catalogo. Lo que apunta a un item con "restrict" se desengancha
-- primero; el historial de precios cae en cascada.
-- -----------------------------------------------------------------------------
-- Cotizaciones y precios tienen un trigger que prohibe borrarlos (son
-- historial). Se apaga solo para este borrado y se vuelve a prender.
alter table public.supplier_quotes   disable trigger supplier_quotes_no_delete;
alter table public.item_price_points disable trigger item_price_points_no_delete;

update public.expenses     set item_id = null where item_id is not null;
update public.budget_lines set item_id = null where item_id is not null;
delete from public.supplier_quotes;
delete from public.item_price_points;
delete from public.items;
delete from public.brands;
delete from public.item_types;

alter table public.supplier_quotes   enable trigger supplier_quotes_no_delete;
alter table public.item_price_points enable trigger item_price_points_no_delete;

-- -----------------------------------------------------------------------------
-- 4. items: categoria nueva, nota, y codigo y descripcion automaticos.
-- -----------------------------------------------------------------------------
alter table public.items
  add column catalog_category_id uuid references public.catalog_categories(id) on delete restrict,
  add column note text;

create index items_catalog_category_idx on public.items (catalog_category_id);

comment on column public.items.note is 'Nota libre. Reemplaza a la descripcion escrita a mano.';
comment on column public.items.description is
  'Se arma sola: Que es · Marca. Es lo que muestran gastos, presupuesto y cotizaciones.';

create or replace function public.completar_item()
returns trigger
language plpgsql
as $fn$
declare
  v_tipo  text;
  v_marca text;
  v_cat   text;
  base    text;
  n       int;
begin
  select name into v_tipo  from public.item_types         where id = new.item_type_id;
  select name into v_marca from public.brands             where id = new.brand_id;
  select code into v_cat   from public.catalog_categories where id = new.catalog_category_id;

  new.description := coalesce(v_tipo, 'Item') || coalesce(' · ' || v_marca, '');

  -- El codigo se rehace solo si cambia lo que lo compone.
  if tg_op = 'INSERT'
     or new.catalog_category_id is distinct from old.catalog_category_id
     or new.item_type_id        is distinct from old.item_type_id then
    base := coalesce(v_cat, 'GEN') || '-' ||
            coalesce(nullif(upper(left(regexp_replace(public.normalizar(v_tipo), '[^a-z]', '', 'g'), 3)), ''), 'ITM') ||
            '-';
    select coalesce(max(substring(i.code from length(base) + 1)::int), 0) + 1
      into n
      from public.items i
     where i.code like base || '%'
       and substring(i.code from length(base) + 1) ~ '^\d+$'
       and i.id <> new.id;
    new.code := base || lpad(n::text, 2, '0');
  end if;

  return new;
end;
$fn$;

create trigger items_completar
  before insert or update on public.items
  for each row execute function public.completar_item();

-- Si se renombra un "que es" o una marca, la descripcion de sus items acompaña.
create or replace function public.refrescar_descripciones()
returns trigger
language plpgsql
as $fn$
begin
  if tg_table_name = 'item_types' then
    update public.items set description = description where item_type_id = new.id;
  else
    update public.items set description = description where brand_id = new.id;
  end if;
  return null;
end;
$fn$;

create trigger item_types_refrescar
  after update of name on public.item_types
  for each row execute function public.refrescar_descripciones();

create trigger brands_refrescar
  after update of name on public.brands
  for each row execute function public.refrescar_descripciones();

-- -----------------------------------------------------------------------------
-- 5. item_prices muestra la categoria nueva. Mismas columnas y en el mismo
-- orden; las nuevas van al final.
-- -----------------------------------------------------------------------------
create or replace view public.item_prices as
select
  i.id                     as item_id,
  i.code,
  i.description,
  i.unit,
  i.kind,
  i.category_id,
  i.is_active,
  cc.name                  as categoria,

  lp.precio_actual_usd,
  lp.fecha_precio,
  lp.origen_precio,
  lp.proveedor_precio,
  lp.precio_anterior_usd,
  lp.variacion,

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
                           as precios_registrados,

  i.brand_id,
  b.name                   as marca,
  i.item_type_id,
  t.name                   as tipo,
  i.model_code,

  i.catalog_category_id,
  cc.sort_order            as categoria_orden,
  i.note                   as nota
from public.items i
left join public.catalog_categories cc  on cc.id = i.catalog_category_id
left join public.item_latest_price lp   on lp.item_id = i.id
left join public.brands b               on b.id = i.brand_id
left join public.item_types t           on t.id = i.item_type_id;

alter view public.item_prices set (security_invoker = on);
grant select on public.item_prices to authenticated;
