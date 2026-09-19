-- =============================================================================
-- 0027_marcas_y_tipos_del_catalogo.sql
--
-- Llenar marca y tipo en los items que ya estan cargados.
--
-- POR QUE ESTO Y NO LO DE ANTES
-- El intento anterior (0026) sacaba la marca del prefijo antes de " - ". Medido
-- contra los datos reales, eso acerto 11 items de 171: el 89% de las
-- descripciones no tiene ese separador. Se deja lo que acerto y se cambia de
-- metodo, en vez de estirar una heuristica que ya demostro no servir.
--
-- LO QUE DICEN LOS DATOS
-- La primera palabra de la descripcion suele ser el tipo del articulo: codo 24,
-- caño 8, tubo 7, tapa 5, tapon 5, manguito 4, tee 3, ramal 3, niple 2. Es un
-- catalogo de plomeria y esos son tipos de verdad.
--
-- Pero mezcladas aparecen marcas en la misma posicion (sigas 12, peirano 7,
-- ferrum 4) y palabras que no son articulos (gastos, materiales, certificacion).
-- Por eso hacen falta las dos listas: la de marcas conocidas, para sacarlas de
-- la ecuacion, y la de palabras que no son tipos, para no crear basura.
--
-- CAÑO Y CANO
-- En los datos conviven las dos grafias. No hay que elegir una: normalizar()
-- las manda a la misma forma comparable y el indice unico hace que sean un solo
-- tipo. Era exactamente el problema que motivo todo esto.
--
-- PARA DESHACERLO ENTERO
--   update public.items set brand_id = null, item_type_id = null;
--   delete from public.item_types;
--   delete from public.brands;
-- Nada de esto toca la descripcion del item: lo que se agrega son punteros, y
-- borrarlos deja el catalogo como estaba.
-- =============================================================================

do $catalogo$
declare
  n_marcas   int;
  n_conmarca int;
  n_tipos    int;
  n_contipo  int;
  -- Confirmadas con quien conoce el catalogo. No las invento: una marca de mas
  -- se come una palabra que era el tipo del articulo.
  marcas text[] := array[
    'Ferrum', 'Peirano', 'Sigas', 'Gulliart', 'Zedra', 'Johnson', 'Ariston'
  ];
  -- Primeras palabras que no nombran un articulo.
  basura text[] := array[
    'gastos', 'materiales', 'certificacion', 'varios', 'otros', 'otro',
    'adicional', 'adicionales', 'item', 'items'
  ];
begin

  -- ---------------------------------------------------------------------------
  -- 1. Las marcas
  -- ---------------------------------------------------------------------------
  insert into public.brands (name)
  select m.nombre
  from unnest(marcas) as m(nombre)
  where not exists (
    select 1 from public.brands b where b.normalized = public.normalizar(m.nombre)
  );
  get diagnostics n_marcas = row_count;

  -- Se busca la marca como palabra entera en cualquier parte de la descripcion,
  -- no solo al principio: "Bacha Johnson - Luxor" y "Caldera Ariston Dual" la
  -- tienen en el medio, y el metodo anterior los perdia.
  --
  -- Ante dos marcas que matchean gana la de nombre mas largo, para que el
  -- resultado no dependa del orden en que Postgres devuelva las filas.
  --
  -- El filtro de solo letras y numeros sobre b.normalized es porque ese texto
  -- entra en una expresion regular: un nombre con parentesis o asterisco la
  -- romperia.
  update public.items i
  set brand_id = elegida.brand_id
  from (
    select
      x.id,
      (select b.id
         from public.brands b
        where b.normalized ~ '^[a-z0-9 ]+$'
          and public.normalizar(x.description) ~
              ('(^|[^a-z0-9])' || b.normalized || '([^a-z0-9]|$)')
        order by length(b.normalized) desc
        limit 1) as brand_id
    from public.items x
    where x.brand_id is null
  ) elegida
  where i.id = elegida.id and elegida.brand_id is not null;
  get diagnostics n_conmarca = row_count;

  -- ---------------------------------------------------------------------------
  -- 2. Los tipos
  --
  -- Se le saca la marca del principio y se toma la primera palabra de lo que
  -- queda. "Peirano - Porta Rollo" da "Porta"; "Bacha Johnson - Luxor" da
  -- "Bacha", porque ahi la marca no esta adelante y la primera palabra ya es el
  -- tipo. "Caldera Ariston Dual" da "Caldera".
  -- ---------------------------------------------------------------------------
  drop table if exists _cand;
  create temp table _cand on commit drop as
  with limpio as (
    select
      i.id,
      btrim(regexp_replace(
        btrim(i.description),
        '^(' || array_to_string(marcas, '|') || ')\s*-?\s*',
        '', 'i'
      )) as resto
    from public.items i
    where i.item_type_id is null
  )
  select
    l.id,
    case
      -- Dos palabras, pero es un tipo de verdad y aparece 6 veces.
      when public.normalizar(l.resto) like 'mano de obra%' then 'Mano de obra'
      else initcap(regexp_replace(split_part(l.resto, ' ', 1), '[^[:alpha:]]+$', ''))
    end as tipo
  from limpio l;

  -- Menos de 3 letras suele ser una medida o un resto de puntuacion, no un tipo.
  delete from _cand
  where tipo is null
     or length(tipo) < 3
     or public.normalizar(tipo) = any (basura);

  insert into public.item_types (name)
  select distinct on (public.normalizar(c.tipo)) c.tipo
  from _cand c
  where not exists (
    select 1 from public.item_types t where t.normalized = public.normalizar(c.tipo)
  )
  order by public.normalizar(c.tipo), c.tipo;
  get diagnostics n_tipos = row_count;

  update public.items i
  set item_type_id = t.id
  from _cand c
  join public.item_types t on t.normalized = public.normalizar(c.tipo)
  where i.id = c.id;
  get diagnostics n_contipo = row_count;

  -- ---------------------------------------------------------------------------
  raise notice 'Marcas nuevas: %. Items con marca: %.', n_marcas, n_conmarca;
  raise notice 'Tipos creados: %. Items con tipo: %.', n_tipos, n_contipo;
end
$catalogo$;

-- Lo que quedo, para revisar de un vistazo: cada tipo, cuantos items tiene y
-- entre que precios se mueve. Si dos tipos son lo mismo, se ven aca.
select
  tipo,
  items,
  marcas,
  precio_min_usd,
  precio_max_usd
from public.item_type_usage
order by items desc, tipo;
