-- =============================================================================
-- 0013_superficies_y_estados.sql   ·   PASO 1 de 2
--
-- Postgres no permite USAR un valor nuevo de un enum en la misma transaccion
-- en que se lo agrega. Por eso esto se corre solo, y las vistas que filtran
-- por los estados nuevos se actualizan en 0014.
-- =============================================================================

-- --- Superficies -------------------------------------------------------------
-- "Superficie" a secas era ambiguo: en una casa no es lo mismo el lote que lo
-- cubierto, y el precio por m2 cambia completamente segun cual se use.
alter table public.projects
  add column lot_m2          numeric(10,2) check (lot_m2 is null or lot_m2 > 0),
  add column covered_m2      numeric(10,2) check (covered_m2 is null or covered_m2 > 0),
  add column semi_covered_m2 numeric(10,2) check (semi_covered_m2 is null or semi_covered_m2 > 0);

comment on column public.projects.lot_m2 is 'Metros del lote';
comment on column public.projects.covered_m2 is 'Metros cubiertos';
comment on column public.projects.semi_covered_m2 is 'Metros semicubiertos';

-- El valor que habia en surface_m2 pasa a cubiertos: en los proyectos cargados
-- es la superficie de la casa, no la del terreno. Si en algun caso era otra
-- cosa, se corrige desde el formulario.
update public.projects
set covered_m2 = surface_m2
where surface_m2 is not null and covered_m2 is null;

alter table public.projects drop column surface_m2;

-- --- Estados nuevos ----------------------------------------------------------
-- Se ubican en el punto del flujo que les corresponde:
--   ... aprobado -> en_tramite_municipal -> en_construccion -> terminado
--       -> en_proceso_venta -> vendido -> cerrado
alter type project_status add value if not exists 'en_tramite_municipal' after 'aprobado';
alter type project_status add value if not exists 'en_proceso_venta'     after 'terminado';
