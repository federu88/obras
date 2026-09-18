-- =============================================================================
-- 0006_seed_categories.sql  ·  Fase 3 — Categorias de costo
--
-- Tomadas del catalogo real (225 items, 6 categorias, 21 subcategorias) del
-- archivo "Construccion Casa_V0.xlsx", no de una plantilla generica.
--
-- Dos cambios respecto del original:
--   - Se omiten las subcategorias "TBD" (eran 21 items sin clasificar). Un
--     placeholder no es una categoria; esos items se reclasifican al migrarlos.
--   - Se agregan los costos indirectos, que el catalogo no tenia y que el P&L
--     si necesita: administracion, arquitectura, seguros, legales, comercial
--     y financiacion.
-- =============================================================================

-- Categorias directas, con su jerarquia.
with padres as (
  insert into public.cost_categories (name, kind, sort_order) values
    ('Lote',                          'directo', 10),
    ('Materiales Corralón/Hormigón',  'directo', 20),
    ('Sanitario',                     'directo', 30),
    ('Electricidad',                  'directo', 40),
    ('Terminaciones',                 'directo', 50),
    ('Mano de obra',                  'directo', 60),
    ('Varios',                        'directo', 70)
  returning id, name
)
insert into public.cost_categories (parent_id, name, kind, sort_order)
select p.id, s.name, 'directo', s.sort_order
from padres p
join (values
  ('Lote',                         'Trámites',                       10),
  ('Materiales Corralón/Hormigón', 'Pilotes',                        10),
  ('Materiales Corralón/Hormigón', 'Columnas',                       20),
  ('Materiales Corralón/Hormigón', 'Vigas + Losa S/PB',              30),
  ('Materiales Corralón/Hormigón', 'Contrapisos y Carpetas',         40),
  ('Materiales Corralón/Hormigón', 'Mampostería',                    50),
  ('Materiales Corralón/Hormigón', 'Revoques',                       60),
  ('Materiales Corralón/Hormigón', 'Yesería + Pintura',              70),
  ('Sanitario',                    'Losa Radiante',                  10),
  ('Sanitario',                    'Instalación Agua / Sanitaria / Gas', 20),
  ('Electricidad',                 'Instalación Eléctrica',          10),
  ('Electricidad',                 'Cables',                         20),
  ('Electricidad',                 'Tablero',                        30),
  ('Terminaciones',                'Pisos y Revestimientos',         10),
  ('Terminaciones',                'Carpintería',                    20),
  ('Terminaciones',                'Muebles',                        30),
  ('Terminaciones',                'Herrería',                       40),
  ('Mano de obra',                 'Jornales',                       10),
  ('Mano de obra',                 'Contratistas',                   20),
  ('Varios',                       'Otros',                          10)
) as s(parent, name, sort_order) on s.parent = p.name;

-- Costos indirectos. No estaban en el catalogo; el P&L los necesita.
with padre as (
  insert into public.cost_categories (name, kind, sort_order)
  values ('Costos indirectos', 'indirecto', 90)
  returning id
)
insert into public.cost_categories (parent_id, name, kind, sort_order)
select padre.id, s.name, 'indirecto', s.sort_order
from padre
join (values
  ('Administración',            10),
  ('Proyecto y arquitectura',   20),
  ('Seguros',                   30),
  ('Gastos legales',            40),
  ('Comercialización',          50),
  ('Financiación',              60),
  ('Expensas',                  70),
  ('Gestoría',                  80)
) as s(name, sort_order) on true;
