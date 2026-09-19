-- =============================================================================
-- 0026_tipo_obra_y_marcas.sql
--
-- Tres cosas:
--   1. Si la obra es construccion desde cero o remodelacion.
--   2. La marca del item, como campo propio y no metida en el nombre.
--   3. El "catalogo del catalogo": que "Bidet" y "bidet" sean lo mismo.
--
-- EL PROBLEMA DE LOS NOMBRES
-- Un catalogo que se carga a mano siempre termina con el mismo articulo
-- escrito de tres formas. No se arregla pidiendo cuidado: se arregla haciendo
-- que la base no pueda guardar dos veces lo mismo.
--
-- La solucion tiene dos mitades y hacen falta las dos:
--
--   normalizar()  reduce un texto a su forma comparable: sin mayusculas, sin
--                 acentos, sin espacios de mas. "Bidet", "bidet" y " BIDET "
--                 dan todos "bidet".
--
--   unique        el indice unico esta sobre la forma normalizada, no sobre el
--                 nombre. Asi el segundo intento choca y no entra, en vez de
--                 crear un gemelo silencioso.
--
-- El nombre lindo se guarda como lo escribio la persona: se compara por la
-- forma normalizada, se muestra la original.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. Construccion o remodelacion
--
-- No es cosmetico: una remodelacion no tiene pilotes ni encadenado, asi que la
-- plantilla de etapas que le sirve es otra, y los metros cubiertos significan
-- otra cosa. Por ahora solo se registra; despues se puede filtrar la plantilla.
-- -----------------------------------------------------------------------------
create type project_kind as enum ('construccion', 'remodelacion');

alter table public.projects
  add column kind project_kind not null default 'construccion';

comment on column public.projects.kind is
  'construccion: obra nueva. remodelacion: se interviene algo que ya existe.';

-- -----------------------------------------------------------------------------
-- 2. normalizar — la forma comparable de un texto.
--
-- Tiene que ser IMMUTABLE porque se usa en columnas generadas y en indices:
-- Postgres necesita saber que el mismo texto va a dar siempre el mismo
-- resultado, o el indice quedaria mintiendo.
--
-- Se hace con translate() y no con la extension unaccent a proposito: unaccent
-- es STABLE, no IMMUTABLE, asi que no sirve para un indice. Y una dependencia
-- menos.
-- -----------------------------------------------------------------------------
create or replace function public.normalizar(p_texto text)
returns text
language sql
immutable
as $fn$
  select translate(
           lower(regexp_replace(btrim(coalesce(p_texto, '')), '\s+', ' ', 'g')),
           'áàäâãéèëêíìïîóòöôõúùüûñçÁÀÄÂÃÉÈËÊÍÌÏÎÓÒÖÔÕÚÙÜÛÑÇ',
           'aaaaaeeeeiiiiooooouuuuncaaaaaeeeeiiiiooooouuuunc'
         )
$fn$;

grant execute on function public.normalizar(text) to authenticated;

-- -----------------------------------------------------------------------------
-- 3. brands — la marca del fabricante.
--
-- No es lo mismo que el proveedor: Ferrum fabrica el bidet, Sanitarios
-- Panamericana te lo vende. Separarlos permite preguntar las dos cosas: a quien
-- le compro mas, y que marca uso mas.
-- -----------------------------------------------------------------------------
create table public.brands (
  id         uuid primary key default gen_random_uuid(),
  name       text not null,
  normalized text generated always as (public.normalizar(name)) stored,
  notes      text,
  created_by uuid references public.profiles(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint brands_name_unica unique (normalized)
);

create trigger brands_set_updated_at
  before update on public.brands
  for each row execute function public.set_updated_at();

-- -----------------------------------------------------------------------------
-- 4. item_types — el catalogo del catalogo.
--
-- Un item del catalogo es un articulo concreto: "Ferrum Bidet Bari Blanca
-- BKM1B". El tipo es QUE ES: "Bidet". Diez articulos distintos comparten tipo.
--
-- Sirve para tres cosas que hoy no se pueden hacer:
--   - comparar precios entre articulos que cumplen la misma funcion
--   - saber cuantos bidets se compraron en una obra, sin importar la marca
--   - que el que carga elija de una lista en vez de escribir de memoria
--
-- Es una lista abierta: se puede agregar lo que falte. Lo que no se puede es
-- agregar dos veces lo mismo escrito distinto.
-- -----------------------------------------------------------------------------
create table public.item_types (
  id         uuid primary key default gen_random_uuid(),
  name       text not null,
  normalized text generated always as (public.normalizar(name)) stored,
  unit       text,                     -- unidad habitual: un, m2, bolsa
  notes      text,
  created_by uuid references public.profiles(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint item_types_name_unica unique (normalized)
);

create trigger item_types_set_updated_at
  before update on public.item_types
  for each row execute function public.set_updated_at();

-- -----------------------------------------------------------------------------
-- 5. El item apunta a su marca y a su tipo
-- -----------------------------------------------------------------------------
alter table public.items
  add column brand_id     uuid references public.brands(id) on delete set null,
  add column item_type_id uuid references public.item_types(id) on delete set null,
  add column model_code   text;        -- el codigo del fabricante: BKM1B

create index items_brand_idx on public.items (brand_id);
create index items_type_idx  on public.items (item_type_id);

-- -----------------------------------------------------------------------------
-- 6. Resolver un nombre a su id, sin crear gemelos.
--
-- Devuelve el id del que ya existe si el nombre normalizado coincide, y recien
-- si no existe lo crea. El manejo de unique_violation cubre el caso de dos
-- personas cargando lo mismo al mismo tiempo.
-- -----------------------------------------------------------------------------
create or replace function public.resolver_marca(p_name text)
returns uuid
language plpgsql
security invoker
as $fn$
declare v uuid;
begin
  if coalesce(btrim(p_name), '') = '' then return null; end if;

  select id into v from public.brands where normalized = public.normalizar(p_name);
  if v is not null then return v; end if;

  begin
    insert into public.brands (name) values (btrim(p_name)) returning id into v;
  exception when unique_violation then
    select id into v from public.brands where normalized = public.normalizar(p_name);
  end;
  return v;
end;
$fn$;

create or replace function public.resolver_tipo_item(p_name text)
returns uuid
language plpgsql
security invoker
as $fn$
declare v uuid;
begin
  if coalesce(btrim(p_name), '') = '' then return null; end if;

  select id into v from public.item_types where normalized = public.normalizar(p_name);
  if v is not null then return v; end if;

  begin
    insert into public.item_types (name) values (btrim(p_name)) returning id into v;
  exception when unique_violation then
    select id into v from public.item_types where normalized = public.normalizar(p_name);
  end;
  return v;
end;
$fn$;

grant execute on function public.resolver_marca(text)     to authenticated;
grant execute on function public.resolver_tipo_item(text) to authenticated;

-- -----------------------------------------------------------------------------
-- 7. Marcas desde los nombres que ya estan cargados.
--
-- Los items importados tienen la marca pegada adelante: "Ferrum - Bidet Bari".
-- Se crean como marca solo los prefijos que aparecen en 3 items o mas y tienen
-- a lo sumo 2 palabras. El umbral es a proposito: "Bacha Johnson - Luxor mini"
-- tiene un prefijo que parece marca y no lo es, y aparece una sola vez.
--
-- El nombre del item NO se toca. Cambiarlo seria destructivo y no hay como
-- volver atras; queda con la marca repetida adelante hasta que alguien decida
-- limpiarlo a mano. Un nombre feo se arregla despues; un nombre perdido no.
-- -----------------------------------------------------------------------------
do $backfill$
declare
  n_marcas int;
  n_items  int;
begin
  with prefijos as (
    select btrim(split_part(description, ' - ', 1)) as marca, count(*) as usos
    from public.items
    where description like '% - %'
    group by 1
  )
  insert into public.brands (name)
  select marca from prefijos
  where usos >= 3
    and array_length(regexp_split_to_array(marca, '\s+'), 1) <= 2
    and marca <> ''
    and not exists (
      select 1 from public.brands b where b.normalized = public.normalizar(prefijos.marca)
    );
  get diagnostics n_marcas = row_count;

  update public.items i
  set brand_id = b.id
  from public.brands b
  where i.brand_id is null
    and i.description like '% - %'
    and b.normalized = public.normalizar(split_part(i.description, ' - ', 1));
  get diagnostics n_items = row_count;

  raise notice 'Marcas creadas: %. Items con marca asignada: %.', n_marcas, n_items;
  raise notice 'Los nombres quedaron intactos: todavia repiten la marca adelante.';
end
$backfill$;

-- -----------------------------------------------------------------------------
-- 8. Vistas
-- -----------------------------------------------------------------------------

-- Cuanto se usa cada tipo y que precio tiene. Es lo que permite comparar dos
-- articulos que hacen lo mismo.
create view public.item_type_usage as
select
  t.id              as item_type_id,
  t.name            as tipo,
  t.unit,
  count(i.id)       as items,
  count(distinct i.brand_id) as marcas,
  min(p.unit_price_usd)          as precio_min_usd,
  max(p.unit_price_usd)          as precio_max_usd,
  round(avg(p.unit_price_usd), 2) as precio_prom_usd
from public.item_types t
left join public.items i on i.item_type_id = t.id
left join public.item_latest_price p on p.item_id = i.id
group by t.id, t.name, t.unit;

-- -----------------------------------------------------------------------------
-- 9. RLS — el catalogo lo lee cualquiera del equipo y lo edita manager o admin.
-- -----------------------------------------------------------------------------
alter table public.brands     enable row level security;
alter table public.item_types enable row level security;

create policy brands_select on public.brands
  for select to authenticated using (public.can_read_all());
create policy brands_write on public.brands
  for all to authenticated
  using (public.can_manage()) with check (public.can_manage());

create policy item_types_select on public.item_types
  for select to authenticated using (public.can_read_all());
create policy item_types_write on public.item_types
  for all to authenticated
  using (public.can_manage()) with check (public.can_manage());

alter view public.item_type_usage set (security_invoker = on);

grant select on public.brands, public.item_types, public.item_type_usage
  to authenticated;
grant insert, update, delete on public.brands, public.item_types to authenticated;

-- -----------------------------------------------------------------------------
-- 10. El catalogo muestra marca y tipo.
--
-- Columnas al final: create or replace view solo deja append. Las anteriores
-- quedan como estaban.
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
  cp.path                  as categoria,

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
  i.model_code
from public.items i
left join public.cost_category_paths cp on cp.id = i.category_id
left join public.item_latest_price lp   on lp.item_id = i.id
left join public.brands b               on b.id = i.brand_id
left join public.item_types t           on t.id = i.item_type_id;

alter view public.item_prices set (security_invoker = on);
grant select on public.item_prices to authenticated;
