-- ===========================================================================
-- Carga del presupuesto de SR583 desde 'Presupuesto 583_05.xlsx' (hoja Categoria)
-- Generado automaticamente el 2026-09-18. Correr UNA SOLA VEZ.
--
-- Los precios en pesos se convierten con public.fx_rate_at() sobre la fecha de
-- cada fila, que arrastra la ultima cotizacion anterior o igual. Es lo que
-- evita los 113 #N/A que tiene la planilla por 4 fechas faltantes.
-- ===========================================================================

begin;

-- 1. Cotizaciones propias (columna Compra, el criterio de la planilla) -------
insert into public.fx_rates (rate_date, source, ars_per_usd, note) values
  ('2025-01-02', 'MEP', 1195, 'Histórico planilla 583'),
  ('2025-01-06', 'MEP', 1185, 'Histórico planilla 583'),
  ('2025-01-07', 'MEP', 1185, 'Histórico planilla 583'),
  ('2025-01-08', 'MEP', 1195, 'Histórico planilla 583'),
  ('2025-01-09', 'MEP', 1200, 'Histórico planilla 583'),
  ('2025-01-10', 'MEP', 1200, 'Histórico planilla 583'),
  ('2025-01-13', 'MEP', 1230, 'Histórico planilla 583'),
  ('2025-01-15', 'MEP', 1230, 'Histórico planilla 583'),
  ('2025-01-16', 'MEP', 1205, 'Histórico planilla 583'),
  ('2025-01-17', 'MEP', 1210, 'Histórico planilla 583'),
  ('2025-01-20', 'MEP', 1215, 'Histórico planilla 583'),
  ('2025-01-21', 'MEP', 1220, 'Histórico planilla 583'),
  ('2025-01-22', 'MEP', 1215, 'Histórico planilla 583'),
  ('2025-01-23', 'MEP', 1220, 'Histórico planilla 583'),
  ('2025-01-24', 'MEP', 1205, 'Histórico planilla 583'),
  ('2025-01-27', 'MEP', 1210, 'Histórico planilla 583'),
  ('2025-01-28', 'MEP', 1210, 'Histórico planilla 583'),
  ('2025-01-30', 'MEP', 1200, 'Histórico planilla 583'),
  ('2025-01-31', 'MEP', 1200, 'Histórico planilla 583'),
  ('2025-02-03', 'MEP', 1205, 'Histórico planilla 583'),
  ('2025-02-04', 'MEP', 1195, 'Histórico planilla 583'),
  ('2025-02-05', 'MEP', 1195, 'Histórico planilla 583'),
  ('2025-02-06', 'MEP', 1195, 'Histórico planilla 583'),
  ('2025-02-07', 'MEP', 1185, 'Histórico planilla 583'),
  ('2025-02-10', 'MEP', 1185, 'Histórico planilla 583'),
  ('2025-02-11', 'MEP', 1180, 'Histórico planilla 583'),
  ('2025-02-12', 'MEP', 1195, 'Histórico planilla 583'),
  ('2025-02-13', 'MEP', 1205, 'Histórico planilla 583'),
  ('2025-02-14', 'MEP', 1200, 'Histórico planilla 583'),
  ('2025-02-17', 'MEP', 1200, 'Histórico planilla 583'),
  ('2025-02-18', 'MEP', 1215, 'Histórico planilla 583'),
  ('2025-02-19', 'MEP', 1215, 'Histórico planilla 583'),
  ('2025-02-20', 'MEP', 1205, 'Histórico planilla 583'),
  ('2025-02-21', 'MEP', 1205, 'Histórico planilla 583'),
  ('2025-02-24', 'MEP', 1210, 'Histórico planilla 583'),
  ('2025-02-25', 'MEP', 1220, 'Histórico planilla 583'),
  ('2025-02-26', 'MEP', 1220, 'Histórico planilla 583'),
  ('2025-02-27', 'MEP', 1210, 'Histórico planilla 583'),
  ('2025-02-28', 'MEP', 1205, 'Histórico planilla 583'),
  ('2025-03-05', 'MEP', 1210, 'Histórico planilla 583'),
  ('2025-03-06', 'MEP', 1205, 'Histórico planilla 583'),
  ('2025-03-07', 'MEP', 1195, 'Histórico planilla 583'),
  ('2025-03-10', 'MEP', 1205, 'Histórico planilla 583'),
  ('2025-03-12', 'MEP', 1200, 'Histórico planilla 583'),
  ('2025-03-13', 'MEP', 1210, 'Histórico planilla 583'),
  ('2025-03-14', 'MEP', 1220, 'Histórico planilla 583'),
  ('2025-03-17', 'MEP', 1235, 'Histórico planilla 583'),
  ('2025-03-18', 'MEP', 1235, 'Histórico planilla 583'),
  ('2025-03-19', 'MEP', 1260, 'Histórico planilla 583'),
  ('2025-03-20', 'MEP', 1245, 'Histórico planilla 583'),
  ('2025-03-21', 'MEP', 1260, 'Histórico planilla 583'),
  ('2025-03-25', 'MEP', 1275, 'Histórico planilla 583'),
  ('2025-03-26', 'MEP', 1290, 'Histórico planilla 583'),
  ('2025-03-27', 'MEP', 1280, 'Histórico planilla 583'),
  ('2025-03-28', 'MEP', 1280, 'Histórico planilla 583'),
  ('2025-03-31', 'MEP', 1305, 'Histórico planilla 583'),
  ('2025-04-01', 'MEP', 1285, 'Histórico planilla 583'),
  ('2025-04-03', 'MEP', 1290, 'Histórico planilla 583'),
  ('2025-04-04', 'MEP', 1290, 'Histórico planilla 583'),
  ('2025-04-07', 'MEP', 1325, 'Histórico planilla 583'),
  ('2025-04-08', 'MEP', 1340, 'Histórico planilla 583'),
  ('2025-04-09', 'MEP', 1335, 'Histórico planilla 583'),
  ('2025-04-10', 'MEP', 1345, 'Histórico planilla 583'),
  ('2025-04-11', 'MEP', 1355, 'Histórico planilla 583'),
  ('2025-04-14', 'MEP', 1265, 'Histórico planilla 583'),
  ('2025-04-15', 'MEP', 1255, 'Histórico planilla 583'),
  ('2025-04-16', 'MEP', 1230, 'Histórico planilla 583'),
  ('2025-04-21', 'MEP', 1130, 'Histórico planilla 583'),
  ('2025-04-22', 'MEP', 1165, 'Histórico planilla 583'),
  ('2025-04-23', 'MEP', 1190, 'Histórico planilla 583'),
  ('2025-04-24', 'MEP', 1205, 'Histórico planilla 583'),
  ('2025-04-28', 'MEP', 1190, 'Histórico planilla 583'),
  ('2025-04-29', 'MEP', 1185, 'Histórico planilla 583'),
  ('2025-04-30', 'MEP', 1180, 'Histórico planilla 583'),
  ('2025-05-05', 'MEP', 1165, 'Histórico planilla 583'),
  ('2025-05-06', 'MEP', 1185, 'Histórico planilla 583'),
  ('2025-05-07', 'MEP', 1170, 'Histórico planilla 583'),
  ('2025-05-08', 'MEP', 1150, 'Histórico planilla 583'),
  ('2025-05-09', 'MEP', 1145, 'Histórico planilla 583'),
  ('2025-05-12', 'MEP', 1150, 'Histórico planilla 583'),
  ('2025-05-14', 'MEP', 1140, 'Histórico planilla 583'),
  ('2025-05-15', 'MEP', 1145, 'Histórico planilla 583'),
  ('2025-05-16', 'MEP', 1145, 'Histórico planilla 583'),
  ('2025-05-19', 'MEP', 1145, 'Histórico planilla 583'),
  ('2025-05-20', 'MEP', 1155, 'Histórico planilla 583'),
  ('2025-05-21', 'MEP', 1155, 'Histórico planilla 583'),
  ('2025-05-22', 'MEP', 1155, 'Histórico planilla 583'),
  ('2025-05-23', 'MEP', 1145, 'Histórico planilla 583'),
  ('2025-05-26', 'MEP', 1150, 'Histórico planilla 583'),
  ('2025-05-27', 'MEP', 1150, 'Histórico planilla 583'),
  ('2025-05-29', 'MEP', 1150, 'Histórico planilla 583'),
  ('2025-05-30', 'MEP', 1150, 'Histórico planilla 583'),
  ('2025-06-02', 'MEP', 1145, 'Histórico planilla 583'),
  ('2025-06-03', 'MEP', 1140, 'Histórico planilla 583'),
  ('2025-06-04', 'MEP', 1160, 'Histórico planilla 583'),
  ('2025-06-05', 'MEP', 1155, 'Histórico planilla 583'),
  ('2025-06-06', 'MEP', 1145, 'Histórico planilla 583'),
  ('2025-06-09', 'MEP', 1175, 'Histórico planilla 583'),
  ('2025-06-10', 'MEP', 1170, 'Histórico planilla 583'),
  ('2025-06-11', 'MEP', 1160, 'Histórico planilla 583'),
  ('2025-06-12', 'MEP', 1165, 'Histórico planilla 583'),
  ('2025-06-13', 'MEP', 1170, 'Histórico planilla 583'),
  ('2025-06-17', 'MEP', 1180, 'Histórico planilla 583'),
  ('2025-06-18', 'MEP', 1170, 'Histórico planilla 583'),
  ('2025-06-19', 'MEP', 1180, 'Histórico planilla 583'),
  ('2025-06-23', 'MEP', 1190, 'Histórico planilla 583'),
  ('2025-06-24', 'MEP', 1195, 'Histórico planilla 583'),
  ('2025-06-25', 'MEP', 1190, 'Histórico planilla 583'),
  ('2025-06-26', 'MEP', 1190, 'Histórico planilla 583'),
  ('2025-06-27', 'MEP', 1190, 'Histórico planilla 583'),
  ('2025-06-30', 'MEP', 1195, 'Histórico planilla 583'),
  ('2025-07-01', 'MEP', 1205, 'Histórico planilla 583'),
  ('2025-07-02', 'MEP', 1220, 'Histórico planilla 583'),
  ('2025-07-03', 'MEP', 1205, 'Histórico planilla 583'),
  ('2025-07-04', 'MEP', 1210, 'Histórico planilla 583'),
  ('2025-07-07', 'MEP', 1250, 'Histórico planilla 583'),
  ('2025-07-08', 'MEP', 1260, 'Histórico planilla 583'),
  ('2025-07-10', 'MEP', 1275, 'Histórico planilla 583'),
  ('2025-07-11', 'MEP', 1280, 'Histórico planilla 583'),
  ('2025-07-14', 'MEP', 1220, 'Histórico planilla 583'),
  ('2025-07-15', 'MEP', 1310, 'Histórico planilla 583'),
  ('2025-07-16', 'MEP', 1285, 'Histórico planilla 583'),
  ('2025-07-17', 'MEP', 1275, 'Histórico planilla 583'),
  ('2025-07-18', 'MEP', 1285, 'Histórico planilla 583'),
  ('2025-07-21', 'MEP', 1305, 'Histórico planilla 583'),
  ('2025-07-22', 'MEP', 1290, 'Histórico planilla 583'),
  ('2025-07-23', 'MEP', 1290, 'Histórico planilla 583'),
  ('2025-07-25', 'MEP', 1300, 'Histórico planilla 583'),
  ('2025-07-28', 'MEP', 1295, 'Histórico planilla 583'),
  ('2025-07-29', 'MEP', 1300, 'Histórico planilla 583'),
  ('2025-07-30', 'MEP', 1300, 'Histórico planilla 583'),
  ('2025-07-31', 'MEP', 1300, 'Histórico planilla 583'),
  ('2025-08-01', 'MEP', 1315, 'Histórico planilla 583'),
  ('2025-08-04', 'MEP', 1315, 'Histórico planilla 583'),
  ('2025-08-05', 'MEP', 1310, 'Histórico planilla 583'),
  ('2025-08-06', 'MEP', 1305, 'Histórico planilla 583'),
  ('2025-08-07', 'MEP', 1300, 'Histórico planilla 583'),
  ('2025-08-08', 'MEP', 1305, 'Histórico planilla 583'),
  ('2025-08-11', 'MEP', 1305, 'Histórico planilla 583'),
  ('2025-08-12', 'MEP', 1315, 'Histórico planilla 583'),
  ('2025-08-13', 'MEP', 1310, 'Histórico planilla 583'),
  ('2025-08-14', 'MEP', 1320, 'Histórico planilla 583'),
  ('2025-08-18', 'MEP', 1320, 'Histórico planilla 583'),
  ('2025-08-19', 'MEP', 1320, 'Histórico planilla 583'),
  ('2025-08-21', 'MEP', 1320, 'Histórico planilla 583'),
  ('2025-08-22', 'MEP', 1320, 'Histórico planilla 583'),
  ('2025-08-25', 'MEP', 1345, 'Histórico planilla 583'),
  ('2025-08-26', 'MEP', 1345, 'Histórico planilla 583'),
  ('2025-08-27', 'MEP', 1345, 'Histórico planilla 583'),
  ('2025-08-29', 'MEP', 1330, 'Histórico planilla 583'),
  ('2025-08-30', 'MEP', 1300, 'Histórico planilla 583'),
  ('2025-09-01', 'MEP', 1335, 'Histórico planilla 583'),
  ('2025-09-03', 'MEP', 1330, 'Histórico planilla 583'),
  ('2025-09-05', 'MEP', 1345, 'Histórico planilla 583'),
  ('2025-09-08', 'MEP', 1350, 'Histórico planilla 583'),
  ('2025-09-09', 'MEP', 1355, 'Histórico planilla 583'),
  ('2025-09-10', 'MEP', 1365, 'Histórico planilla 583'),
  ('2025-09-11', 'MEP', 1375, 'Histórico planilla 583'),
  ('2025-09-12', 'MEP', 1390, 'Histórico planilla 583'),
  ('2025-09-15', 'MEP', 1405, 'Histórico planilla 583'),
  ('2025-09-16', 'MEP', 1435, 'Histórico planilla 583'),
  ('2025-09-17', 'MEP', 1445, 'Histórico planilla 583'),
  ('2025-09-18', 'MEP', 1470, 'Histórico planilla 583'),
  ('2025-09-19', 'MEP', 1490, 'Histórico planilla 583'),
  ('2025-09-22', 'MEP', 1500, 'Histórico planilla 583'),
  ('2025-09-23', 'MEP', 1415, 'Histórico planilla 583'),
  ('2025-09-24', 'MEP', 1390, 'Histórico planilla 583'),
  ('2025-09-25', 'MEP', 1385, 'Histórico planilla 583'),
  ('2025-09-26', 'MEP', 1390, 'Histórico planilla 583'),
  ('2025-09-29', 'MEP', 1410, 'Histórico planilla 583'),
  ('2025-09-30', 'MEP', 1425, 'Histórico planilla 583'),
  ('2025-10-02', 'MEP', 1455, 'Histórico planilla 583'),
  ('2025-10-03', 'MEP', 1420, 'Histórico planilla 583'),
  ('2025-10-06', 'MEP', 1430, 'Histórico planilla 583'),
  ('2025-10-08', 'MEP', 1455, 'Histórico planilla 583'),
  ('2025-10-13', 'MEP', 1455, 'Histórico planilla 583'),
  ('2025-10-14', 'MEP', 1385, 'Histórico planilla 583'),
  ('2025-10-15', 'MEP', 1400, 'Histórico planilla 583'),
  ('2025-10-16', 'MEP', 1445, 'Histórico planilla 583'),
  ('2025-10-20', 'MEP', 1465, 'Histórico planilla 583'),
  ('2025-10-21', 'MEP', 1485, 'Histórico planilla 583'),
  ('2025-10-22', 'MEP', 1525, 'Histórico planilla 583'),
  ('2025-10-23', 'MEP', 1530, 'Histórico planilla 583'),
  ('2025-10-24', 'MEP', 1505, 'Histórico planilla 583'),
  ('2025-10-27', 'MEP', 1490, 'Histórico planilla 583'),
  ('2025-10-28', 'MEP', 1445, 'Histórico planilla 583'),
  ('2025-10-29', 'MEP', 1450, 'Histórico planilla 583'),
  ('2025-10-30', 'MEP', 1440, 'Histórico planilla 583'),
  ('2025-10-31', 'MEP', 1425, 'Histórico planilla 583'),
  ('2025-11-03', 'MEP', 1425, 'Histórico planilla 583'),
  ('2025-11-04', 'MEP', 1425, 'Histórico planilla 583'),
  ('2025-11-05', 'MEP', 1440, 'Histórico planilla 583'),
  ('2025-11-06', 'MEP', 1420, 'Histórico planilla 583'),
  ('2025-11-07', 'MEP', 1415, 'Histórico planilla 583'),
  ('2025-11-10', 'MEP', 1395, 'Histórico planilla 583'),
  ('2025-11-11', 'MEP', 1410, 'Histórico planilla 583'),
  ('2025-11-12', 'MEP', 1420, 'Histórico planilla 583'),
  ('2025-11-13', 'MEP', 1415, 'Histórico planilla 583'),
  ('2025-11-14', 'MEP', 1410, 'Histórico planilla 583'),
  ('2025-11-17', 'MEP', 1415, 'Histórico planilla 583'),
  ('2025-11-18', 'MEP', 1410, 'Histórico planilla 583'),
  ('2025-11-19', 'MEP', 1410, 'Histórico planilla 583'),
  ('2025-11-24', 'MEP', 1405, 'Histórico planilla 583'),
  ('2025-11-25', 'MEP', 1440, 'Histórico planilla 583'),
  ('2025-11-27', 'MEP', 1430, 'Histórico planilla 583'),
  ('2025-11-28', 'MEP', 1420, 'Histórico planilla 583'),
  ('2025-12-01', 'MEP', 1415, 'Histórico planilla 583'),
  ('2025-12-02', 'MEP', 1425, 'Histórico planilla 583'),
  ('2025-12-03', 'MEP', 1420, 'Histórico planilla 583'),
  ('2025-12-04', 'MEP', 1410, 'Histórico planilla 583'),
  ('2025-12-08', 'MEP', 1415, 'Histórico planilla 583'),
  ('2025-12-09', 'MEP', 1425, 'Histórico planilla 583'),
  ('2025-12-10', 'MEP', 1430, 'Histórico planilla 583'),
  ('2025-12-12', 'MEP', 1430, 'Histórico planilla 583'),
  ('2025-12-15', 'MEP', 1425, 'Histórico planilla 583'),
  ('2025-12-16', 'MEP', 1480, 'Histórico planilla 583'),
  ('2025-12-17', 'MEP', 1480, 'Histórico planilla 583'),
  ('2025-12-18', 'MEP', 1470, 'Histórico planilla 583'),
  ('2025-12-19', 'MEP', 1465, 'Histórico planilla 583'),
  ('2025-12-22', 'MEP', 1495, 'Histórico planilla 583'),
  ('2025-12-26', 'MEP', 1500, 'Histórico planilla 583'),
  ('2025-12-29', 'MEP', 1510, 'Histórico planilla 583'),
  ('2025-12-30', 'MEP', 1520, 'Histórico planilla 583'),
  ('2025-12-31', 'MEP', 1510, 'Histórico planilla 583'),
  ('2026-01-01', 'MEP', 1510, 'Histórico planilla 583'),
  ('2026-01-02', 'MEP', 1510, 'Histórico planilla 583'),
  ('2026-01-06', 'MEP', 1500, 'Histórico planilla 583'),
  ('2026-01-07', 'MEP', 1495, 'Histórico planilla 583'),
  ('2026-01-09', 'MEP', 1485, 'Histórico planilla 583'),
  ('2026-01-12', 'MEP', 1485, 'Histórico planilla 583'),
  ('2026-01-13', 'MEP', 1485, 'Histórico planilla 583'),
  ('2026-01-15', 'MEP', 1485, 'Histórico planilla 583'),
  ('2026-01-19', 'MEP', 1485, 'Histórico planilla 583'),
  ('2026-01-20', 'MEP', 1485, 'Histórico planilla 583'),
  ('2026-01-22', 'MEP', 1480, 'Histórico planilla 583'),
  ('2026-01-23', 'MEP', 1475, 'Histórico planilla 583'),
  ('2026-01-26', 'MEP', 1470, 'Histórico planilla 583'),
  ('2026-01-28', 'MEP', 1470, 'Histórico planilla 583'),
  ('2026-02-05', 'MEP', 1435, 'Histórico planilla 583')
on conflict (rate_date, source) do nothing;

-- 2. Categorias que falten ---------------------------------------------------
insert into public.cost_categories (name, kind)
  select 'Accesorios Sanitarios', 'directo'
  where not exists (select 1 from public.cost_categories where parent_id is null and name = 'Accesorios Sanitarios');
insert into public.cost_categories (name, kind)
  select 'Electricidad', 'directo'
  where not exists (select 1 from public.cost_categories where parent_id is null and name = 'Electricidad');
insert into public.cost_categories (name, kind)
  select 'Gas', 'directo'
  where not exists (select 1 from public.cost_categories where parent_id is null and name = 'Gas');
insert into public.cost_categories (name, kind)
  select 'Lote', 'directo'
  where not exists (select 1 from public.cost_categories where parent_id is null and name = 'Lote');
insert into public.cost_categories (name, kind)
  select 'Materiales Corralón/Hormigón', 'directo'
  where not exists (select 1 from public.cost_categories where parent_id is null and name = 'Materiales Corralón/Hormigón');
insert into public.cost_categories (name, kind)
  select 'Sanitario', 'directo'
  where not exists (select 1 from public.cost_categories where parent_id is null and name = 'Sanitario');
insert into public.cost_categories (name, kind)
  select 'Terminaciones', 'directo'
  where not exists (select 1 from public.cost_categories where parent_id is null and name = 'Terminaciones');
insert into public.cost_categories (name, kind)
  select 'Varios', 'directo'
  where not exists (select 1 from public.cost_categories where parent_id is null and name = 'Varios');
insert into public.cost_categories (parent_id, name, kind)
  select c.id, 'Accesorios - artefactos sanitarios', 'directo' from public.cost_categories c
  where c.parent_id is null and c.name = 'Accesorios Sanitarios'
    and not exists (select 1 from public.cost_categories x where x.parent_id = c.id and x.name = 'Accesorios - artefactos sanitarios');
insert into public.cost_categories (parent_id, name, kind)
  select c.id, 'Instalación Eléctrica', 'directo' from public.cost_categories c
  where c.parent_id is null and c.name = 'Electricidad'
    and not exists (select 1 from public.cost_categories x where x.parent_id = c.id and x.name = 'Instalación Eléctrica');
insert into public.cost_categories (parent_id, name, kind)
  select c.id, 'Materiales Electricos', 'directo' from public.cost_categories c
  where c.parent_id is null and c.name = 'Electricidad'
    and not exists (select 1 from public.cost_categories x where x.parent_id = c.id and x.name = 'Materiales Electricos');
insert into public.cost_categories (parent_id, name, kind)
  select c.id, 'Tramite Luz Final de obra (edenor)', 'directo' from public.cost_categories c
  where c.parent_id is null and c.name = 'Electricidad'
    and not exists (select 1 from public.cost_categories x where x.parent_id = c.id and x.name = 'Tramite Luz Final de obra (edenor)');
insert into public.cost_categories (parent_id, name, kind)
  select c.id, 'Tramite Luz de obra (edenor)', 'directo' from public.cost_categories c
  where c.parent_id is null and c.name = 'Electricidad'
    and not exists (select 1 from public.cost_categories x where x.parent_id = c.id and x.name = 'Tramite Luz de obra (edenor)');
insert into public.cost_categories (parent_id, name, kind)
  select c.id, 'Tramite Gas (parcial y final)', 'directo' from public.cost_categories c
  where c.parent_id is null and c.name = 'Gas'
    and not exists (select 1 from public.cost_categories x where x.parent_id = c.id and x.name = 'Tramite Gas (parcial y final)');
insert into public.cost_categories (parent_id, name, kind)
  select c.id, 'Trámites', 'directo' from public.cost_categories c
  where c.parent_id is null and c.name = 'Lote'
    and not exists (select 1 from public.cost_categories x where x.parent_id = c.id and x.name = 'Trámites');
insert into public.cost_categories (parent_id, name, kind)
  select c.id, 'Corralon general', 'directo' from public.cost_categories c
  where c.parent_id is null and c.name = 'Materiales Corralón/Hormigón'
    and not exists (select 1 from public.cost_categories x where x.parent_id = c.id and x.name = 'Corralon general');
insert into public.cost_categories (parent_id, name, kind)
  select c.id, 'Pilotes', 'directo' from public.cost_categories c
  where c.parent_id is null and c.name = 'Materiales Corralón/Hormigón'
    and not exists (select 1 from public.cost_categories x where x.parent_id = c.id and x.name = 'Pilotes');
insert into public.cost_categories (parent_id, name, kind)
  select c.id, 'Yesería + Pintura', 'directo' from public.cost_categories c
  where c.parent_id is null and c.name = 'Materiales Corralón/Hormigón'
    and not exists (select 1 from public.cost_categories x where x.parent_id = c.id and x.name = 'Yesería + Pintura');
insert into public.cost_categories (parent_id, name, kind)
  select c.id, 'Accesorios - artefactos sanitarios', 'directo' from public.cost_categories c
  where c.parent_id is null and c.name = 'Sanitario'
    and not exists (select 1 from public.cost_categories x where x.parent_id = c.id and x.name = 'Accesorios - artefactos sanitarios');
insert into public.cost_categories (parent_id, name, kind)
  select c.id, 'Instalación Agua / Sanitaria / Gas', 'directo' from public.cost_categories c
  where c.parent_id is null and c.name = 'Sanitario'
    and not exists (select 1 from public.cost_categories x where x.parent_id = c.id and x.name = 'Instalación Agua / Sanitaria / Gas');
insert into public.cost_categories (parent_id, name, kind)
  select c.id, 'Mano de obra instalación sanitaria', 'directo' from public.cost_categories c
  where c.parent_id is null and c.name = 'Sanitario'
    and not exists (select 1 from public.cost_categories x where x.parent_id = c.id and x.name = 'Mano de obra instalación sanitaria');
insert into public.cost_categories (parent_id, name, kind)
  select c.id, 'Carpintería', 'directo' from public.cost_categories c
  where c.parent_id is null and c.name = 'Terminaciones'
    and not exists (select 1 from public.cost_categories x where x.parent_id = c.id and x.name = 'Carpintería');
insert into public.cost_categories (parent_id, name, kind)
  select c.id, 'Herrería', 'directo' from public.cost_categories c
  where c.parent_id is null and c.name = 'Terminaciones'
    and not exists (select 1 from public.cost_categories x where x.parent_id = c.id and x.name = 'Herrería');
insert into public.cost_categories (parent_id, name, kind)
  select c.id, 'Muebles', 'directo' from public.cost_categories c
  where c.parent_id is null and c.name = 'Terminaciones'
    and not exists (select 1 from public.cost_categories x where x.parent_id = c.id and x.name = 'Muebles');
insert into public.cost_categories (parent_id, name, kind)
  select c.id, 'Pisos y Revestimientos', 'directo' from public.cost_categories c
  where c.parent_id is null and c.name = 'Terminaciones'
    and not exists (select 1 from public.cost_categories x where x.parent_id = c.id and x.name = 'Pisos y Revestimientos');
insert into public.cost_categories (parent_id, name, kind)
  select c.id, 'Mano de obra', 'directo' from public.cost_categories c
  where c.parent_id is null and c.name = 'Varios'
    and not exists (select 1 from public.cost_categories x where x.parent_id = c.id and x.name = 'Mano de obra');
insert into public.cost_categories (parent_id, name, kind)
  select c.id, 'Varios', 'directo' from public.cost_categories c
  where c.parent_id is null and c.name = 'Varios'
    and not exists (select 1 from public.cost_categories x where x.parent_id = c.id and x.name = 'Varios');

-- 3. Proveedores -------------------------------------------------------------
insert into public.suppliers (name) values
  ('Alejandro - FPD'),
  ('Antolin'),
  ('Ariel'),
  ('Carli'),
  ('Clientes'),
  ('Cordani'),
  ('Cosas viejas'),
  ('Eidico'),
  ('Electronort'),
  ('Estudio Figueras'),
  ('Estudio Lenga'),
  ('Grupo Gemme'),
  ('Herrero Joaco'),
  ('Inmobiliaria'),
  ('Juan -+54 9 230 450-4450'),
  ('Nueva Casa'),
  ('Pentacons'),
  ('Quimtex'),
  ('Raul'),
  ('Sanitarios Panamericana'),
  ('barrio'),
  ('electricista miguel +5491159298666'),
  ('escribania'),
  ('galicia - diego'),
  ('ivan matriculado'),
  ('maderera'),
  ('mano de obra'),
  ('mercado libre'),
  ('yesero joaco')
on conflict (name) do nothing;

-- 4. Items del catalogo ------------------------------------------------------
insert into public.items (code, description, unit, category_id)
  select 'TRAM-1', 'Compre Lote', 'gl', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Lote' and s.name = 'Trámites'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'TRAM-2', 'Honorarios inmobiliaria', 'gl', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Lote' and s.name = 'Trámites'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'TRAM-3', 'Gastos cesion', 'gl', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Lote' and s.name = 'Trámites'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'TRAM-4', 'Gastos Eidico', 'gl', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Lote' and s.name = 'Trámites'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'TRAM-5', 'Gastos varios (renders - impresiones etc)', 'gl', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Lote' and s.name = 'Trámites'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'TRAM-6', 'Gestoria', 'gl', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Lote' and s.name = 'Trámites'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'PILO-1', 'Mano de obra de perforaciones de pilotes', 'gl', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Materiales Corralón/Hormigón' and s.name = 'Pilotes'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'PILO-2', 'Hormigon', 'gl', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Materiales Corralón/Hormigón' and s.name = 'Pilotes'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'CORR-1', 'Corralon', 'gl', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Materiales Corralón/Hormigón' and s.name = 'Corralon general'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'YESE-1', 'Materiales Yesería', 'gl', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Materiales Corralón/Hormigón' and s.name = 'Yesería + Pintura'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'YESE-2', 'Mano de obra', 'gl', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Materiales Corralón/Hormigón' and s.name = 'Yesería + Pintura'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'YESE-3', 'Pintura interior/ exterior', 'gl', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Materiales Corralón/Hormigón' and s.name = 'Yesería + Pintura'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'YESE-4', 'Mano de obra Pintura', 'gl', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Materiales Corralón/Hormigón' and s.name = 'Yesería + Pintura'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'INST-1', 'Pileta de Patio 4 entradas 40x63 awaduct', 'ml', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Sanitario' and s.name = 'Instalación Agua / Sanitaria / Gas'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'INST-2', 'Boca acceso Cocina 3 entradas 63x50 awaduct', 'rollo', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Sanitario' and s.name = 'Instalación Agua / Sanitaria / Gas'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'INST-3', 'Codo de 110 a 90 awaduct', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Sanitario' and s.name = 'Instalación Agua / Sanitaria / Gas'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'INST-4', 'codo 110 a 90 HHC awaduct', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Sanitario' and s.name = 'Instalación Agua / Sanitaria / Gas'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'INST-5', 'Codo de 110 a 45 awaduct', 'bolsa', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Sanitario' and s.name = 'Instalación Agua / Sanitaria / Gas'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'INST-6', 'Codo 110 a 45HHC awaduct', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Sanitario' and s.name = 'Instalación Agua / Sanitaria / Gas'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'INST-7', 'Ramal a 45 de 110x63 awaduct', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Sanitario' and s.name = 'Instalación Agua / Sanitaria / Gas'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'INST-8', 'Ramal a 45 de 110x110 awaduct', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Sanitario' and s.name = 'Instalación Agua / Sanitaria / Gas'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'INST-9', 'Codo de 63 a 45 awaduct', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Sanitario' and s.name = 'Instalación Agua / Sanitaria / Gas'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'INST-10', 'Codo 63 a 45 HH awaduct', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Sanitario' and s.name = 'Instalación Agua / Sanitaria / Gas'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'INST-11', 'codo de 63 a 90 awaduct', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Sanitario' and s.name = 'Instalación Agua / Sanitaria / Gas'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'INST-12', 'codo 63 a 90 HH awaduct', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Sanitario' and s.name = 'Instalación Agua / Sanitaria / Gas'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'INST-13', 'Codo 50 a 45 HH awaduct', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Sanitario' and s.name = 'Instalación Agua / Sanitaria / Gas'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'INST-14', 'Codo de 50 a 45 awaduct', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Sanitario' and s.name = 'Instalación Agua / Sanitaria / Gas'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'INST-15', 'Codo de 50 a 90 awaduct', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Sanitario' and s.name = 'Instalación Agua / Sanitaria / Gas'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'INST-16', 'Codo 50 a 90 HH awaduct', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Sanitario' and s.name = 'Instalación Agua / Sanitaria / Gas'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'INST-17', 'Codo de 40 a 45 awaduct', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Sanitario' and s.name = 'Instalación Agua / Sanitaria / Gas'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'INST-18', 'Codo 40 a 45 HH awaduct', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Sanitario' and s.name = 'Instalación Agua / Sanitaria / Gas'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'INST-19', 'Codo TE 40 a 90 awaduct', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Sanitario' and s.name = 'Instalación Agua / Sanitaria / Gas'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'INST-20', 'Codo 40 a 90 HH awaduct', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Sanitario' and s.name = 'Instalación Agua / Sanitaria / Gas'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'INST-21', 'Ramal a 45 de 40x40 HHH awaduct', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Sanitario' and s.name = 'Instalación Agua / Sanitaria / Gas'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'INST-22', 'Solucion lubricante x 400', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Sanitario' and s.name = 'Instalación Agua / Sanitaria / Gas'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'INST-23', 'Cano awaduct 110x4mts', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Sanitario' and s.name = 'Instalación Agua / Sanitaria / Gas'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'INST-24', 'Cano awaduct 63x4mts', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Sanitario' and s.name = 'Instalación Agua / Sanitaria / Gas'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'INST-25', 'Cano awaduct 50x2mts', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Sanitario' and s.name = 'Instalación Agua / Sanitaria / Gas'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'INST-26', 'Cano awaduct 40x4mts', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Sanitario' and s.name = 'Instalación Agua / Sanitaria / Gas'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'INST-27', 'Adaptador pileta descarga aire acondicionado .40x3/4', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Sanitario' and s.name = 'Instalación Agua / Sanitaria / Gas'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'INST-28', 'Manguito reparacion 110 awaduct', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Sanitario' and s.name = 'Instalación Agua / Sanitaria / Gas'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'INST-29', 'Manguito reparacion 63 awaduct', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Sanitario' and s.name = 'Instalación Agua / Sanitaria / Gas'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'INST-30', 'Manguito reparacion 50 awaduct', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Sanitario' and s.name = 'Instalación Agua / Sanitaria / Gas'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'INST-31', 'Codo 110 c/3 acom.A 63 Boca acceso Horizontal awaduct', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Sanitario' and s.name = 'Instalación Agua / Sanitaria / Gas'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'INST-32', 'manguito reparacion 40 awaduct', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Sanitario' and s.name = 'Instalación Agua / Sanitaria / Gas'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'INST-33', 'Buje Red. 110x63 awaduct', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Sanitario' and s.name = 'Instalación Agua / Sanitaria / Gas'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'INST-34', 'Cano polietileno 3/4 K-4 (R.100mts) valor x mt', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Sanitario' and s.name = 'Instalación Agua / Sanitaria / Gas'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'INST-35', 'Enchufe doble codo 3/4 p/cano de polietileno', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Sanitario' and s.name = 'Instalación Agua / Sanitaria / Gas'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'INST-36', 'Enchufe doble 3/4 p/cano de polietileno', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Sanitario' and s.name = 'Instalación Agua / Sanitaria / Gas'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'INST-37', 'enchufe triple tee 3/4 p/cano de polietileno', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Sanitario' and s.name = 'Instalación Agua / Sanitaria / Gas'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'INST-38', 'latyn fleje perforado 17x0.7mmx10m', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Sanitario' and s.name = 'Instalación Agua / Sanitaria / Gas'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'INST-39', 'fischer tarugo sab+TMF 22x45 bolsa x100', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Sanitario' and s.name = 'Instalación Agua / Sanitaria / Gas'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'INST-40', 'embudo horiz. 110mm reja plast. 20x20 duratop xrs', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Sanitario' and s.name = 'Instalación Agua / Sanitaria / Gas'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'INST-41', 'tapa PVC 110 tigre ramat', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Sanitario' and s.name = 'Instalación Agua / Sanitaria / Gas'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'INST-42', 'Tapa pvc 40 tigre ramat', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Sanitario' and s.name = 'Instalación Agua / Sanitaria / Gas'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'INST-43', 'llave de paso de 20 tigre fusion', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Sanitario' and s.name = 'Instalación Agua / Sanitaria / Gas'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'INST-44', 'llave de paso de 25 tigre fusion', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Sanitario' and s.name = 'Instalación Agua / Sanitaria / Gas'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'INST-45', 'esferica 32mm p/exterior paso total acqua system', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Sanitario' and s.name = 'Instalación Agua / Sanitaria / Gas'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'INST-46', 'esperica 25mm p/exterior paso total acqua system', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Sanitario' and s.name = 'Instalación Agua / Sanitaria / Gas'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'INST-47', 'codo rca.met.hembra 20x1/2 tigre fusion', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Sanitario' and s.name = 'Instalación Agua / Sanitaria / Gas'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'INST-48', 'codo rosca met. Hembra 25xx3/4 tigre fusion', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Sanitario' and s.name = 'Instalación Agua / Sanitaria / Gas'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'INST-49', 'codo rosca met. Hembra 32x1 tigre fusion', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Sanitario' and s.name = 'Instalación Agua / Sanitaria / Gas'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'INST-50', 'tubo macho 20x1/2 tigre fusion', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Sanitario' and s.name = 'Instalación Agua / Sanitaria / Gas'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'INST-51', 'tubo macho 25x3/4 tigre fusion', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Sanitario' and s.name = 'Instalación Agua / Sanitaria / Gas'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'INST-52', 'tubo macho 32x1"tigre fusion', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Sanitario' and s.name = 'Instalación Agua / Sanitaria / Gas'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'INST-53', 'tubo hembra 20x1/2 tigre fusion', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Sanitario' and s.name = 'Instalación Agua / Sanitaria / Gas'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'INST-54', 'Tubo hembra 25x3/4 tigre fusion', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Sanitario' and s.name = 'Instalación Agua / Sanitaria / Gas'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'INST-55', 'Tubo hembra 32x1" tigre fusion', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Sanitario' and s.name = 'Instalación Agua / Sanitaria / Gas'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'INST-56', 'Codo de 20 a 90 tigre fusion', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Sanitario' and s.name = 'Instalación Agua / Sanitaria / Gas'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'INST-57', 'Codo de 25 x 90 tigre fusion', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Sanitario' and s.name = 'Instalación Agua / Sanitaria / Gas'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'INST-58', 'Codo de 32 a 90 tigre fusion', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Sanitario' and s.name = 'Instalación Agua / Sanitaria / Gas'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'INST-59', 'TEE de 20 tigre fusion', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Sanitario' and s.name = 'Instalación Agua / Sanitaria / Gas'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'INST-60', 'TEE de 25 tigre fusion', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Sanitario' and s.name = 'Instalación Agua / Sanitaria / Gas'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'INST-61', 'TEE de 32 tigre fusion', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Sanitario' and s.name = 'Instalación Agua / Sanitaria / Gas'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'INST-62', 'Union normal de 20 tigre fusion', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Sanitario' and s.name = 'Instalación Agua / Sanitaria / Gas'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'INST-63', 'Union normal de 25 tigre fusion', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Sanitario' and s.name = 'Instalación Agua / Sanitaria / Gas'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'INST-64', 'Union normal de 32 tigre fusion', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Sanitario' and s.name = 'Instalación Agua / Sanitaria / Gas'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'INST-65', 'Buje 25x20 tigre fusion', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Sanitario' and s.name = 'Instalación Agua / Sanitaria / Gas'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'INST-66', 'Buje 32x25 tigre fusion', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Sanitario' and s.name = 'Instalación Agua / Sanitaria / Gas'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'INST-67', 'Curva sobrepasaje 20 iny tigre fusion', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Sanitario' and s.name = 'Instalación Agua / Sanitaria / Gas'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'INST-68', 'Curva sobrepasaje de 32 acqua system', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Sanitario' and s.name = 'Instalación Agua / Sanitaria / Gas'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'INST-69', 'Curva sobrepasaje 25 INY tigre fusion', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Sanitario' and s.name = 'Instalación Agua / Sanitaria / Gas'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'INST-70', 'Rotoplas cisterna 110mts modular c/flot-fil-aut', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Sanitario' and s.name = 'Instalación Agua / Sanitaria / Gas'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'INST-71', 'adaptador p/tanque  1 c/bridas', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Sanitario' and s.name = 'Instalación Agua / Sanitaria / Gas'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'INST-72', 'Adaptador p/tanque PPN 3/4 c/bridas', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Sanitario' and s.name = 'Instalación Agua / Sanitaria / Gas'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'INST-73', 'Valvula retencion Vert. 1 BDE.', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Sanitario' and s.name = 'Instalación Agua / Sanitaria / Gas'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'INST-74', 'Boya de telgopor 3/4', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Sanitario' and s.name = 'Instalación Agua / Sanitaria / Gas'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'INST-75', 'Flotante a presion 3/4 sin boya', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Sanitario' and s.name = 'Instalación Agua / Sanitaria / Gas'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'INST-76', 'tapon PPN 1/2', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Sanitario' and s.name = 'Instalación Agua / Sanitaria / Gas'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'INST-77', 'Tapon PPN 3/4', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Sanitario' and s.name = 'Instalación Agua / Sanitaria / Gas'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'INST-78', 'tapon PPN 1/2', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Sanitario' and s.name = 'Instalación Agua / Sanitaria / Gas'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'INST-79', 'Tapa de 20 tigre fusion', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Sanitario' and s.name = 'Instalación Agua / Sanitaria / Gas'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'INST-80', 'Tapa de 25 tigre fusion', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Sanitario' and s.name = 'Instalación Agua / Sanitaria / Gas'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'INST-81', 'Tapa de 32 tigre fusion', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Sanitario' and s.name = 'Instalación Agua / Sanitaria / Gas'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'INST-82', 'Rollo cinta teflon de 3/4 x 40mts alta densidad', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Sanitario' and s.name = 'Instalación Agua / Sanitaria / Gas'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'INST-83', 'Sellador hidro 3x125 C,C', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Sanitario' and s.name = 'Instalación Agua / Sanitaria / Gas'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'INST-84', 'Cano Tigre fusion PN-20 20', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Sanitario' and s.name = 'Instalación Agua / Sanitaria / Gas'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'INST-85', 'Cano tigre fusion PN-20 25', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Sanitario' and s.name = 'Instalación Agua / Sanitaria / Gas'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'INST-86', 'Cano tigre fusion PN-20 32', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Sanitario' and s.name = 'Instalación Agua / Sanitaria / Gas'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'INST-87', 'Sigas valvula esferica 32mm', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Sanitario' and s.name = 'Instalación Agua / Sanitaria / Gas'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'INST-88', 'Sigas valvula esferica 25mm', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Sanitario' and s.name = 'Instalación Agua / Sanitaria / Gas'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'INST-89', 'sigas codo 32x3/4 rosca hembra', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Sanitario' and s.name = 'Instalación Agua / Sanitaria / Gas'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'INST-90', 'sigas codo a 90 de 32mm', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Sanitario' and s.name = 'Instalación Agua / Sanitaria / Gas'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'INST-91', 'sigas codo 25 x 1/2 rosca hembra', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Sanitario' and s.name = 'Instalación Agua / Sanitaria / Gas'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'INST-92', 'sigas codo a 90 de 25mm', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Sanitario' and s.name = 'Instalación Agua / Sanitaria / Gas'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'INST-93', 'sigas union normal 32mm', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Sanitario' and s.name = 'Instalación Agua / Sanitaria / Gas'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'INST-94', 'sigas union normal 25mm', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Sanitario' and s.name = 'Instalación Agua / Sanitaria / Gas'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'INST-95', 'sigas codo 32x1 rosca hembra', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Sanitario' and s.name = 'Instalación Agua / Sanitaria / Gas'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'INST-96', 'sigas TEE reduccion 32x25mm', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Sanitario' and s.name = 'Instalación Agua / Sanitaria / Gas'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'INST-97', 'Tapon epoxi 3/4', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Sanitario' and s.name = 'Instalación Agua / Sanitaria / Gas'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'INST-98', 'tapon epoxi 1/2', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Sanitario' and s.name = 'Instalación Agua / Sanitaria / Gas'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'INST-99', 'codo red. Epoxi 1x3/4', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Sanitario' and s.name = 'Instalación Agua / Sanitaria / Gas'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'INST-100', 'niple epoxi 1x10cm', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Sanitario' and s.name = 'Instalación Agua / Sanitaria / Gas'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'INST-101', 'niple epoxi 1x15cm', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Sanitario' and s.name = 'Instalación Agua / Sanitaria / Gas'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'INST-102', 'esmalte epoxi 250cm3 (conjunto AyB 2x125)', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Sanitario' and s.name = 'Instalación Agua / Sanitaria / Gas'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'INST-103', 'pincel calisco 1" PCS-10', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Sanitario' and s.name = 'Instalación Agua / Sanitaria / Gas'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'INST-104', 'sigas tubo 32x4mts. Acero-polietileno', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Sanitario' and s.name = 'Instalación Agua / Sanitaria / Gas'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'INST-105', 'sigas tubo 25x4mts. Acero-polietileno', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Sanitario' and s.name = 'Instalación Agua / Sanitaria / Gas'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'INST-106', 'kit coelctor 6 circuitos 20mm plascio ent.der.', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Sanitario' and s.name = 'Instalación Agua / Sanitaria / Gas'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'INST-107', 'Tubo pecc tubotherm 3/4 (20x2.0)(rollo x 100mts)', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Sanitario' and s.name = 'Instalación Agua / Sanitaria / Gas'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'INST-108', 'Manta aislante termica dema 10mm 1x20', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Sanitario' and s.name = 'Instalación Agua / Sanitaria / Gas'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'INST-109', 'prescintos 200mm x100 unid.', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Sanitario' and s.name = 'Instalación Agua / Sanitaria / Gas'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'INST-110', 'Bomba presurizadora', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Sanitario' and s.name = 'Instalación Agua / Sanitaria / Gas'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'INST-111', 'Flexibles, sifones, canillas, terminaciones', 'gl', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Sanitario' and s.name = 'Instalación Agua / Sanitaria / Gas'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'TRAM-7', 'Matriculado de gas', 'gl', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Gas' and s.name = 'Tramite Gas (parcial y final)'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'MANO-1', 'Mano de obra (agua fria y caliente, instalacion cloacal y pluvial completa, instalacion de gas completa, Losa radiante y caldera, colocacion de artefactos)', 'gl', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Sanitario' and s.name = 'Mano de obra instalación sanitaria'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'ACCE-1', 'Ferrum - Bidet Bari Blanca 1A BKM1B', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Accesorios Sanitarios' and s.name = 'Accesorios - artefactos sanitarios'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'ACCE-2', 'Ferrum - Inodoro Bari Largo Blanco IKLMB', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Accesorios Sanitarios' and s.name = 'Accesorios - artefactos sanitarios'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'ACCE-3', 'Ferrum - Deposito Bari Apoyar Blanco dual DKW6F', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Accesorios Sanitarios' and s.name = 'Accesorios - artefactos sanitarios'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'ACCE-4', 'Ferrum - Asiento inod. Bari TKWP B', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Accesorios Sanitarios' and s.name = 'Accesorios - artefactos sanitarios'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'ACCE-5', 'Peirano - Lavatorio Bicom. C.Ceram adra cr', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Accesorios Sanitarios' and s.name = 'Accesorios - artefactos sanitarios'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'ACCE-6', 'Peirano - Ducha Emb Bicomando C.Cerm C/transf. Adra pl', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Accesorios Sanitarios' and s.name = 'Accesorios - artefactos sanitarios'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'ACCE-7', 'Peirano - Bide Bicom. C. Ceram adra cr', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Accesorios Sanitarios' and s.name = 'Accesorios - artefactos sanitarios'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'ACCE-8', 'Peirano - Lavatorio Monoc. Bajo Adra Cr', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Accesorios Sanitarios' and s.name = 'Accesorios - artefactos sanitarios'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'ACCE-9', 'Zedra - Bacha Kahlo 36x12,5cm', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Accesorios Sanitarios' and s.name = 'Accesorios - artefactos sanitarios'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'ACCE-10', 'Gulliart - Bacha de apoyo due 1A BL 1 Orif 420x245x1', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Accesorios Sanitarios' and s.name = 'Accesorios - artefactos sanitarios'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'ACCE-11', 'Peirano - Porta Rollo linea 13000', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Accesorios Sanitarios' and s.name = 'Accesorios - artefactos sanitarios'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'ACCE-12', 'Peirano - Toallero barral linea 13000 CR', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Accesorios Sanitarios' and s.name = 'Accesorios - artefactos sanitarios'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'ACCE-13', 'Peirano - Cocina monoc. ADRA CR', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Accesorios Sanitarios' and s.name = 'Accesorios - artefactos sanitarios'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'ACCE-14', 'Bacha Johnson - Luxor mini SI55A 55x41,5x20', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Accesorios Sanitarios' and s.name = 'Accesorios - artefactos sanitarios'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'ACCE-15', 'Caldera Ariston Dual HS x 24 FF R/FF', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Accesorios Sanitarios' and s.name = 'Accesorios - artefactos sanitarios'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'ACCE-16', 'Monoc. Cocina MSDA Giratoria Cromo Dique', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Accesorios Sanitarios' and s.name = 'Accesorios - artefactos sanitarios'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'ACCE-17', 'Bacha Parrilla - Bacha De Cocina Simple Johnson Acero Zz52/18', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Sanitario' and s.name = 'Accesorios - artefactos sanitarios'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'ACCE-18', 'Bacha Lavadero - Bacha Simple Mi Pileta 782E Sobremesada Acero Inoxidable 34x37x17 cm', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Sanitario' and s.name = 'Accesorios - artefactos sanitarios'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'INST-112', 'Mano de obra', 'gl', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Electricidad' and s.name = 'Instalación Eléctrica'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'TRAM-8', 'Certificación eléctrica + matriculado tramite edenor DCI Luz de obra', 'gl', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Electricidad' and s.name = 'Tramite Luz de obra (edenor)'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'TRAM-9', 'Certificación eléctrica + matriculado tramite edenor DCI Luz Final de obra', 'gl', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Electricidad' and s.name = 'Tramite Luz Final de obra (edenor)'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'MATE-1', 'Materiales Electricos (cables, tablero, teclas, modulos)', 'gl', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Electricidad' and s.name = 'Materiales Electricos'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'PISO-1', 'Porcellanato en PB + banos', 'm2', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Terminaciones' and s.name = 'Pisos y Revestimientos'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'PISO-2', 'Microcemento en Galería', 'm2', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Terminaciones' and s.name = 'Pisos y Revestimientos'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'CARP-1', 'Carpinterías de Aluminio (línea modena, color aluminio negro, vidrios 6mm y laminado 3+3 en paños grandes, con mosquiteros y sin premarcos)', 'gl', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Terminaciones' and s.name = 'Carpintería'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'CARP-2', 'Puerta de acceso (estimada - falta especificar)', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Terminaciones' and s.name = 'Carpintería'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'CARP-3', 'Puertas  (pta lisa 70 pino/80 pino 15cm mdf 5,5 p/p pintar)', 'gl', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Terminaciones' and s.name = 'Carpintería'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'CARP-4', 'Picaportes puertas', 'gl', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Terminaciones' and s.name = 'Carpintería'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'CARP-5', 'Zocalos/ contramarcos', 'gl', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Terminaciones' and s.name = 'Carpintería'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'MUEB-1', 'Mesada cocina ( m2 + ml)', 'gl', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Terminaciones' and s.name = 'Muebles'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'MUEB-2', 'Colocacioh mesadas', 'gl', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Terminaciones' and s.name = 'Muebles'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'MUEB-3', 'Mesada Lavadero (m2 + ml)', 'gl', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Terminaciones' and s.name = 'Muebles'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'MUEB-4', 'Mueble de Cocina', 'gl', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Terminaciones' and s.name = 'Muebles'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'HERR-1', 'Mano de obra Techo Galeria / entrada', 'gl', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Terminaciones' and s.name = 'Herrería'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'HERR-2', 'Materiales Herrero', 'gl', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Terminaciones' and s.name = 'Herrería'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'HERR-3', 'Conductos del hogar y parrilla + colocacion', 'gl', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Terminaciones' and s.name = 'Herrería'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'HERR-4', 'Canasto cesto de basura', 'un', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Terminaciones' and s.name = 'Herrería'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'MANO-2', 'Contratista principal (armado y llenado de estructura resistente, mamposteria completa, revoques totales, contrapisos y carpetas)', 'gl', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Varios' and s.name = 'Mano de obra'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'VARI-1', 'Seguros personal y resp. civil', 'gl', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Varios' and s.name = 'Varios'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'VARI-2', 'Volquetes', 'gl', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Varios' and s.name = 'Varios'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'VARI-3', 'Sanitario de obra', 'gl', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Varios' and s.name = 'Varios'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'VARI-4', 'Edenor', 'gl', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Varios' and s.name = 'Varios'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'VARI-5', 'flete', 'gl', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Varios' and s.name = 'Varios'
  on conflict (code) do nothing;
insert into public.items (code, description, unit, category_id)
  select 'VARI-6', 'expensas', 'gl', s.id
  from public.cost_categories s join public.cost_categories p on p.id = s.parent_id
  where p.name = 'Varios' and s.name = 'Varios'
  on conflict (code) do nothing;

-- 5. Lineas de presupuesto de SR583 ------------------------------------------
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Compre Lote', 'gl', 1, round((39200)::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'TRAM-1';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Honorarios inmobiliaria', 'gl', 1, round((1568)::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'TRAM-2';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Gastos cesion', 'gl', 1, round((355000)::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'TRAM-3';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Gastos Eidico', 'gl', 1, round(((93170.76 / coalesce(public.fx_rate_at('2025-02-25'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'TRAM-4';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Gastos varios (renders - impresiones etc)', 'gl', 1, round(((74900 / coalesce(public.fx_rate_at(current_date), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'TRAM-5';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Gestoria', 'gl', 1, round(((4923667.4 / coalesce(public.fx_rate_at(current_date), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'TRAM-6';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Mano de obra de perforaciones de pilotes', 'gl', 1, round(((900000 / coalesce(public.fx_rate_at('2025-09-17'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'PILO-1';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Hormigon', 'gl', 1, round(((1192000 / coalesce(public.fx_rate_at('2025-09-23'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'PILO-2';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Corralon', 'gl', 1, round((19000)::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'CORR-1';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Materiales Yesería', 'gl', 1, round(((217817 / coalesce(public.fx_rate_at('2025-10-24'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'YESE-1';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Mano de obra', 'gl', 1, round(((1300000 / coalesce(public.fx_rate_at('2025-10-24'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'YESE-2';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Pintura interior/ exterior', 'gl', 1, round(((2500000 / coalesce(public.fx_rate_at('2025-10-24'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'YESE-3';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Mano de obra Pintura', 'gl', 1, round(((2500000 / coalesce(public.fx_rate_at('2025-10-24'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'YESE-4';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Pileta de Patio 4 entradas 40x63 awaduct', 'ml', 4, round(((6652.62 / coalesce(public.fx_rate_at('2026-05-02'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'INST-1';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Boca acceso Cocina 3 entradas 63x50 awaduct', 'rollo', 2, round(((5050.59 / coalesce(public.fx_rate_at('2026-05-02'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'INST-2';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Codo de 110 a 90 awaduct', 'un', 5, round(((2612.85 / coalesce(public.fx_rate_at('2026-05-02'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'INST-3';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'codo 110 a 90 HHC awaduct', 'un', 5, round(((3126.41 / coalesce(public.fx_rate_at('2026-05-02'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'INST-4';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Codo de 110 a 45 awaduct', 'bolsa', 10, round(((2405.28 / coalesce(public.fx_rate_at('2026-05-02'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'INST-5';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Codo 110 a 45HHC awaduct', 'un', 5, round(((2882.74 / coalesce(public.fx_rate_at('2026-05-02'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'INST-6';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Ramal a 45 de 110x63 awaduct', 'un', 6, round(((3912.66 / coalesce(public.fx_rate_at('2026-05-02'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'INST-7';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Ramal a 45 de 110x110 awaduct', 'un', 10, round(((5508.1 / coalesce(public.fx_rate_at('2026-05-02'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'INST-8';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Codo de 63 a 45 awaduct', 'un', 17, round(((1142.84 / coalesce(public.fx_rate_at('2026-05-02'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'INST-9';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Codo 63 a 45 HH awaduct', 'un', 10, round(((1347.97 / coalesce(public.fx_rate_at('2026-05-02'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'INST-10';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'codo de 63 a 90 awaduct', 'un', 4, round(((1206.81 / coalesce(public.fx_rate_at('2026-05-02'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'INST-11';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'codo 63 a 90 HH awaduct', 'un', 5, round(((1411.91 / coalesce(public.fx_rate_at('2026-05-02'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'INST-12';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Codo 50 a 45 HH awaduct', 'un', 5, round(((841.31 / coalesce(public.fx_rate_at('2026-05-02'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'INST-13';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Codo de 50 a 45 awaduct', 'un', 5, round(((380.28 / coalesce(public.fx_rate_at('2026-05-02'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'INST-14';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Codo de 50 a 90 awaduct', 'un', 4, round(((680.28 / coalesce(public.fx_rate_at('2026-05-02'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'INST-15';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Codo 50 a 90 HH awaduct', 'un', 4, round(((841.31 / coalesce(public.fx_rate_at('2026-05-02'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'INST-16';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Codo de 40 a 45 awaduct', 'un', 15, round(((475.32 / coalesce(public.fx_rate_at('2026-05-02'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'INST-17';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Codo 40 a 45 HH awaduct', 'un', 10, round(((603.66 / coalesce(public.fx_rate_at('2026-05-02'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'INST-18';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Codo TE 40 a 90 awaduct', 'un', 8, round(((1011.5 / coalesce(public.fx_rate_at('2026-05-02'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'INST-19';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Codo 40 a 90 HH awaduct', 'un', 10, round(((636.33 / coalesce(public.fx_rate_at('2026-05-02'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'INST-20';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Ramal a 45 de 40x40 HHH awaduct', 'un', 4, round(((1461.72 / coalesce(public.fx_rate_at('2026-05-02'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'INST-21';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Solucion lubricante x 400', 'un', 8, round(((10385.72 / coalesce(public.fx_rate_at('2026-05-02'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'INST-22';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Cano awaduct 110x4mts', 'un', 10, round(((17630.05 / coalesce(public.fx_rate_at('2026-05-02'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'INST-23';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Cano awaduct 63x4mts', 'un', 4, round(((9675.4 / coalesce(public.fx_rate_at('2026-05-02'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'INST-24';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Cano awaduct 50x2mts', 'un', 2, round(((4290.58 / coalesce(public.fx_rate_at('2026-05-02'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'INST-25';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Cano awaduct 40x4mts', 'un', 4, round(((6163.55 / coalesce(public.fx_rate_at('2026-05-02'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'INST-26';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Adaptador pileta descarga aire acondicionado .40x3/4', 'un', 6, round(((348.88 / coalesce(public.fx_rate_at('2026-05-02'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'INST-27';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Manguito reparacion 110 awaduct', 'un', 10, round(((2487.21 / coalesce(public.fx_rate_at('2026-05-02'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'INST-28';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Manguito reparacion 63 awaduct', 'un', 5, round(((1142.84 / coalesce(public.fx_rate_at('2026-05-02'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'INST-29';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Manguito reparacion 50 awaduct', 'un', 5, round(((860.5 / coalesce(public.fx_rate_at('2026-05-02'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'INST-30';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Codo 110 c/3 acom.A 63 Boca acceso Horizontal awaduct', 'un', 3, round(((5258.84 / coalesce(public.fx_rate_at('2026-05-02'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'INST-31';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'manguito reparacion 40 awaduct', 'un', 5, round(((783.59 / coalesce(public.fx_rate_at('2026-05-02'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'INST-32';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Buje Red. 110x63 awaduct', 'un', 4, round(((1907.04 / coalesce(public.fx_rate_at('2026-05-02'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'INST-33';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Cano polietileno 3/4 K-4 (R.100mts) valor x mt', 'un', 25, round(((348.61 / coalesce(public.fx_rate_at('2026-05-02'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'INST-34';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Enchufe doble codo 3/4 p/cano de polietileno', 'un', 15, round(((173.28 / coalesce(public.fx_rate_at('2026-05-02'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'INST-35';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Enchufe doble 3/4 p/cano de polietileno', 'un', 6, round(((110.77 / coalesce(public.fx_rate_at('2026-05-02'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'INST-36';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'enchufe triple tee 3/4 p/cano de polietileno', 'un', 4, round(((283.31 / coalesce(public.fx_rate_at('2026-05-02'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'INST-37';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'latyn fleje perforado 17x0.7mmx10m', 'un', 1, round(((8590.14 / coalesce(public.fx_rate_at('2026-05-02'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'INST-38';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'fischer tarugo sab+TMF 22x45 bolsa x100', 'un', 1, round(((616.83 / coalesce(public.fx_rate_at('2026-05-02'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'INST-39';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'embudo horiz. 110mm reja plast. 20x20 duratop xrs', 'un', 1, round(((6319.61 / coalesce(public.fx_rate_at('2026-05-02'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'INST-40';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'tapa PVC 110 tigre ramat', 'un', 15, round(((1349.87 / coalesce(public.fx_rate_at('2026-05-02'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'INST-41';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Tapa pvc 40 tigre ramat', 'un', 15, round(((393.4 / coalesce(public.fx_rate_at('2026-05-02'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'INST-42';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'llave de paso de 20 tigre fusion', 'un', 15, round(((11050.44 / coalesce(public.fx_rate_at('2026-05-02'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'INST-43';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'llave de paso de 25 tigre fusion', 'un', 2, round(((13336.73 / coalesce(public.fx_rate_at('2026-05-02'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'INST-44';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'esferica 32mm p/exterior paso total acqua system', 'un', 5, round(((18032.12 / coalesce(public.fx_rate_at('2026-05-02'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'INST-45';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'esperica 25mm p/exterior paso total acqua system', 'un', 2, round(((13029.8 / coalesce(public.fx_rate_at('2026-05-02'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'INST-46';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'codo rca.met.hembra 20x1/2 tigre fusion', 'un', 26, round(((1474.38 / coalesce(public.fx_rate_at('2026-05-02'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'INST-47';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'codo rosca met. Hembra 25xx3/4 tigre fusion', 'un', 6, round(((2133.87 / coalesce(public.fx_rate_at('2026-05-02'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'INST-48';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'codo rosca met. Hembra 32x1 tigre fusion', 'un', 3, round(((4027.68 / coalesce(public.fx_rate_at('2026-05-02'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'INST-49';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'tubo macho 20x1/2 tigre fusion', 'un', 10, round(((1829.04 / coalesce(public.fx_rate_at('2026-05-02'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'INST-50';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'tubo macho 25x3/4 tigre fusion', 'un', 4, round(((2362.51 / coalesce(public.fx_rate_at('2026-05-02'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'INST-51';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'tubo macho 32x1"tigre fusion', 'un', 8, round(((4839.32 / coalesce(public.fx_rate_at('2026-05-02'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'INST-52';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'tubo hembra 20x1/2 tigre fusion', 'un', 10, round(((1467.04 / coalesce(public.fx_rate_at('2026-05-02'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'INST-53';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Tubo hembra 25x3/4 tigre fusion', 'un', 4, round(((2133.87 / coalesce(public.fx_rate_at('2026-05-02'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'INST-54';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Tubo hembra 32x1" tigre fusion', 'un', 3, round(((3685.96 / coalesce(public.fx_rate_at('2026-05-02'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'INST-55';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Codo de 20 a 90 tigre fusion', 'un', 50, round(((196.74 / coalesce(public.fx_rate_at('2026-05-02'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'INST-56';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Codo de 25 x 90 tigre fusion', 'un', 40, round(((308.9 / coalesce(public.fx_rate_at('2026-05-02'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'INST-57';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Codo de 32 a 90 tigre fusion', 'un', 30, round(((514.4 / coalesce(public.fx_rate_at('2026-05-02'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'INST-58';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'TEE de 20 tigre fusion', 'un', 20, round(((294.87 / coalesce(public.fx_rate_at('2026-05-02'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'INST-59';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'TEE de 25 tigre fusion', 'un', 20, round(((497.6 / coalesce(public.fx_rate_at('2026-05-02'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'INST-60';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'TEE de 32 tigre fusion', 'un', 15, round(((755.6 / coalesce(public.fx_rate_at('2026-05-02'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'INST-61';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Union normal de 20 tigre fusion', 'un', 20, round(((148.61 / coalesce(public.fx_rate_at('2026-05-02'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'INST-62';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Union normal de 25 tigre fusion', 'un', 20, round(((240.06 / coalesce(public.fx_rate_at('2026-05-02'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'INST-63';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Union normal de 32 tigre fusion', 'un', 10, round(((339.13 / coalesce(public.fx_rate_at('2026-05-02'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'INST-64';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Buje 25x20 tigre fusion', 'un', 15, round(((255.75 / coalesce(public.fx_rate_at('2026-05-02'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'INST-65';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Buje 32x25 tigre fusion', 'un', 15, round(((377.54 / coalesce(public.fx_rate_at('2026-05-02'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'INST-66';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Curva sobrepasaje 20 iny tigre fusion', 'un', 15, round(((750.76 / coalesce(public.fx_rate_at('2026-05-02'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'INST-67';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Curva sobrepasaje de 32 acqua system', 'un', 5, round(((2027.27 / coalesce(public.fx_rate_at('2026-05-02'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'INST-68';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Curva sobrepasaje 25 INY tigre fusion', 'un', 5, round(((1084.14 / coalesce(public.fx_rate_at('2026-05-02'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'INST-69';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Rotoplas cisterna 110mts modular c/flot-fil-aut', 'un', 1, round(((688733.49 / coalesce(public.fx_rate_at('2026-05-02'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'INST-70';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'adaptador p/tanque  1 c/bridas', 'un', 1, round(((2719.98 / coalesce(public.fx_rate_at('2026-05-02'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'INST-71';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Adaptador p/tanque PPN 3/4 c/bridas', 'un', 1, round(((2551.82 / coalesce(public.fx_rate_at('2026-05-02'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'INST-72';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Valvula retencion Vert. 1 BDE.', 'un', 1, round(((10844.32 / coalesce(public.fx_rate_at('2026-05-02'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'INST-73';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Boya de telgopor 3/4', 'un', 1, round(((9598.22 / coalesce(public.fx_rate_at('2026-05-02'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'INST-74';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Flotante a presion 3/4 sin boya', 'un', 1, round(((40761.63 / coalesce(public.fx_rate_at('2026-05-02'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'INST-75';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'tapon PPN 1/2', 'un', 30, round(((135.33 / coalesce(public.fx_rate_at('2026-05-02'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'INST-76';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Tapon PPN 3/4', 'un', 8, round(((159.78 / coalesce(public.fx_rate_at('2026-05-02'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'INST-77';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'tapon PPN 1/2', 'un', 5, round(((373.14 / coalesce(public.fx_rate_at('2026-05-02'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'INST-78';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Tapa de 20 tigre fusion', 'un', 8, round(((144.8 / coalesce(public.fx_rate_at('2026-05-02'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'INST-79';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Tapa de 25 tigre fusion', 'un', 4, round(((231.37 / coalesce(public.fx_rate_at('2026-05-02'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'INST-80';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Tapa de 32 tigre fusion', 'un', 3, round(((284.17 / coalesce(public.fx_rate_at('2026-05-02'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'INST-81';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Rollo cinta teflon de 3/4 x 40mts alta densidad', 'un', 3, round(((4115.87 / coalesce(public.fx_rate_at('2026-05-02'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'INST-82';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Sellador hidro 3x125 C,C', 'un', 3, round(((5677.86 / coalesce(public.fx_rate_at('2026-05-02'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'INST-83';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Cano Tigre fusion PN-20 20', 'un', 15, round(((3529.14 / coalesce(public.fx_rate_at('2026-05-02'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'INST-84';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Cano tigre fusion PN-20 25', 'un', 15, round(((5311.86 / coalesce(public.fx_rate_at('2026-05-02'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'INST-85';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Cano tigre fusion PN-20 32', 'un', 10, round(((8625.37 / coalesce(public.fx_rate_at('2026-05-02'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'INST-86';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Sigas valvula esferica 32mm', 'un', 1, round(((46602.79 / coalesce(public.fx_rate_at('2026-05-02'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'INST-87';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Sigas valvula esferica 25mm', 'un', 1, round(((21737.53 / coalesce(public.fx_rate_at('2026-05-02'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'INST-88';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'sigas codo 32x3/4 rosca hembra', 'un', 1, round(((8556.55 / coalesce(public.fx_rate_at('2026-05-02'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'INST-89';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'sigas codo a 90 de 32mm', 'un', 10, round(((3382.2 / coalesce(public.fx_rate_at('2026-05-02'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'INST-90';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'sigas codo 25 x 1/2 rosca hembra', 'un', 1, round(((5407.44 / coalesce(public.fx_rate_at('2026-05-02'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'INST-91';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'sigas codo a 90 de 25mm', 'un', 10, round(((2200.32 / coalesce(public.fx_rate_at('2026-05-02'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'INST-92';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'sigas union normal 32mm', 'un', 5, round(((1853.29 / coalesce(public.fx_rate_at('2026-05-02'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'INST-93';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'sigas union normal 25mm', 'un', 5, round(((1615.25 / coalesce(public.fx_rate_at('2026-05-02'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'INST-94';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'sigas codo 32x1 rosca hembra', 'un', 1, round(((10458.42 / coalesce(public.fx_rate_at('2026-05-02'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'INST-95';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'sigas TEE reduccion 32x25mm', 'un', 1, round(((4823.44 / coalesce(public.fx_rate_at('2026-05-02'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'INST-96';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Tapon epoxi 3/4', 'un', 2, round(((1323.88 / coalesce(public.fx_rate_at('2026-05-02'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'INST-97';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'tapon epoxi 1/2', 'un', 1, round(((851.48 / coalesce(public.fx_rate_at('2026-05-02'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'INST-98';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'codo red. Epoxi 1x3/4', 'un', 1, round(((3060.13 / coalesce(public.fx_rate_at('2026-05-02'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'INST-99';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'niple epoxi 1x10cm', 'un', 1, round(((2079 / coalesce(public.fx_rate_at('2026-05-02'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'INST-100';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'niple epoxi 1x15cm', 'un', 1, round(((3108.26 / coalesce(public.fx_rate_at('2026-05-02'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'INST-101';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'esmalte epoxi 250cm3 (conjunto AyB 2x125)', 'un', 1, round(((10091.87 / coalesce(public.fx_rate_at('2026-05-02'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'INST-102';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'pincel calisco 1" PCS-10', 'un', 1, round(((1468.46 / coalesce(public.fx_rate_at('2026-05-02'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'INST-103';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'sigas tubo 32x4mts. Acero-polietileno', 'un', 3, round(((32520.6 / coalesce(public.fx_rate_at('2026-05-02'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'INST-104';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'sigas tubo 25x4mts. Acero-polietileno', 'un', 3, round(((21335.19 / coalesce(public.fx_rate_at('2026-05-02'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'INST-105';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'kit coelctor 6 circuitos 20mm plascio ent.der.', 'un', 1, round(((426297.91 / coalesce(public.fx_rate_at('2026-05-02'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'INST-106';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Tubo pecc tubotherm 3/4 (20x2.0)(rollo x 100mts)', 'un', 7, round(((1040.64 / coalesce(public.fx_rate_at('2026-05-02'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'INST-107';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Manta aislante termica dema 10mm 1x20', 'un', 7, round(((24544.25 / coalesce(public.fx_rate_at('2026-05-02'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'INST-108';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'prescintos 200mm x100 unid.', 'un', 20, round(((2962.15 / coalesce(public.fx_rate_at('2026-05-02'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'INST-109';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Bomba presurizadora', 'un', 1, round(((90137 / coalesce(public.fx_rate_at('2026-06-02'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'INST-110';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Flexibles, sifones, canillas, terminaciones', 'gl', 1, round(((409413.38 / coalesce(public.fx_rate_at('2026-01-27'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'INST-111';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Matriculado de gas', 'gl', 1, round(((550000 / coalesce(public.fx_rate_at('2026-01-27'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'TRAM-7';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Mano de obra (agua fria y caliente, instalacion cloacal y pluvial completa, instalacion de gas completa, Losa radiante y caldera, colocacion de artefactos)', 'gl', 1, round(((5000000 / coalesce(public.fx_rate_at(current_date), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'MANO-1';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Ferrum - Bidet Bari Blanca 1A BKM1B', 'un', 2, round(((66260 / coalesce(public.fx_rate_at('2025-07-16'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'ACCE-1';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Ferrum - Inodoro Bari Largo Blanco IKLMB', 'un', 3, round(((90202 / coalesce(public.fx_rate_at('2025-07-16'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'ACCE-2';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Ferrum - Deposito Bari Apoyar Blanco dual DKW6F', 'un', 3, round(((86821 / coalesce(public.fx_rate_at('2025-07-16'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'ACCE-3';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Ferrum - Asiento inod. Bari TKWP B', 'un', 3, round(((39873 / coalesce(public.fx_rate_at('2025-07-16'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'ACCE-4';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Peirano - Lavatorio Bicom. C.Ceram adra cr', 'un', 2, round(((38234.22 / coalesce(public.fx_rate_at('2025-07-16'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'ACCE-5';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Peirano - Ducha Emb Bicomando C.Cerm C/transf. Adra pl', 'un', 2, round(((72326.3 / coalesce(public.fx_rate_at('2025-07-16'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'ACCE-6';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Peirano - Bide Bicom. C. Ceram adra cr', 'un', 2, round(((41354 / coalesce(public.fx_rate_at('2025-07-16'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'ACCE-7';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Peirano - Lavatorio Monoc. Bajo Adra Cr', 'un', 1, round(((43163.55 / coalesce(public.fx_rate_at('2025-07-16'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'ACCE-8';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Zedra - Bacha Kahlo 36x12,5cm', 'un', 2, round(((52597.19 / coalesce(public.fx_rate_at('2025-07-16'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'ACCE-9';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Gulliart - Bacha de apoyo due 1A BL 1 Orif 420x245x1', 'un', 1, round(((71943.14 / coalesce(public.fx_rate_at('2025-07-16'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'ACCE-10';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Peirano - Porta Rollo linea 13000', 'un', 3, round(((149411.63 / coalesce(public.fx_rate_at('2025-07-16'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'ACCE-11';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Peirano - Toallero barral linea 13000 CR', 'un', 3, round(((28912.01 / coalesce(public.fx_rate_at('2025-07-16'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'ACCE-12';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Peirano - Cocina monoc. ADRA CR', 'un', 1, round(((65867.95 / coalesce(public.fx_rate_at('2025-07-16'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'ACCE-13';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Bacha Johnson - Luxor mini SI55A 55x41,5x20', 'un', 1, round(((124507.47 / coalesce(public.fx_rate_at('2025-07-16'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'ACCE-14';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Caldera Ariston Dual HS x 24 FF R/FF', 'un', 1, round(((1295873.51 / coalesce(public.fx_rate_at('2025-07-16'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'ACCE-15';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Monoc. Cocina MSDA Giratoria Cromo Dique', 'un', 2, round(((32002.79 / coalesce(public.fx_rate_at('2025-07-16'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'ACCE-16';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Bacha Parrilla - Bacha De Cocina Simple Johnson Acero Zz52/18', 'un', 1, round(((97885 / coalesce(public.fx_rate_at('2025-11-11'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'ACCE-17';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Bacha Lavadero - Bacha Simple Mi Pileta 782E Sobremesada Acero Inoxidable 34x37x17 cm', 'un', 1, round(((121000 / coalesce(public.fx_rate_at('2025-11-11'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'ACCE-18';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Mano de obra', 'gl', 1, round(((4025000 / coalesce(public.fx_rate_at(current_date), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'INST-112';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Certificación eléctrica + matriculado tramite edenor DCI Luz de obra', 'gl', 1, round(((280000 / coalesce(public.fx_rate_at('2025-03-13'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'TRAM-8';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Certificación eléctrica + matriculado tramite edenor DCI Luz Final de obra', 'gl', 1, round(((280000 / coalesce(public.fx_rate_at('2026-01-15'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'TRAM-9';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Materiales Electricos (cables, tablero, teclas, modulos)', 'gl', 1, round(((2800000 / coalesce(public.fx_rate_at('2025-11-11'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'MATE-1';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Porcellanato en PB + banos', 'm2', 122, round(((18000 / coalesce(public.fx_rate_at('2026-01-15'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'PISO-1';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Microcemento en Galería', 'm2', 21, round(((2007596.1 / coalesce(public.fx_rate_at('2026-05-28'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'PISO-2';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Carpinterías de Aluminio (línea modena, color aluminio negro, vidrios 6mm y laminado 3+3 en paños grandes, con mosquiteros y sin premarcos)', 'gl', 1, round(((7700000 / coalesce(public.fx_rate_at('2025-03-07'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'CARP-1';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Puerta de acceso (estimada - falta especificar)', 'un', 1, round(((1200000 / coalesce(public.fx_rate_at('2025-12-04'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'CARP-2';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Puertas  (pta lisa 70 pino/80 pino 15cm mdf 5,5 p/p pintar)', 'gl', 1, round(((949000 / coalesce(public.fx_rate_at('2025-05-20'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'CARP-3';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Picaportes puertas', 'gl', 1, round(((81000 / coalesce(public.fx_rate_at('2025-11-11'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'CARP-4';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Zocalos/ contramarcos', 'gl', 1, round(((450000 / coalesce(public.fx_rate_at('2026-01-15'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'CARP-5';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Mesada cocina ( m2 + ml)', 'gl', 1, round(((1140000 / coalesce(public.fx_rate_at('2026-01-06'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'MUEB-1';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Colocacioh mesadas', 'gl', 1, round(((400000 / coalesce(public.fx_rate_at('2026-01-06'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'MUEB-2';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Mesada Lavadero (m2 + ml)', 'gl', 1, round(((380000 / coalesce(public.fx_rate_at('2026-01-06'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'MUEB-3';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Mueble de Cocina', 'gl', 1, round(((3100000 / coalesce(public.fx_rate_at('2026-05-28'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'MUEB-4';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Mano de obra Techo Galeria / entrada', 'gl', 1, round(((2000000 / coalesce(public.fx_rate_at('2026-01-06'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'HERR-1';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Materiales Herrero', 'gl', 1, round(((3150000 / coalesce(public.fx_rate_at('2026-01-06'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'HERR-2';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Conductos del hogar y parrilla + colocacion', 'gl', 1, round(((1400000 / coalesce(public.fx_rate_at('2026-01-06'), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'HERR-3';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Canasto cesto de basura', 'un', 1, round(((200000 / coalesce(public.fx_rate_at(current_date), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'HERR-4';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Contratista principal (armado y llenado de estructura resistente, mamposteria completa, revoques totales, contrapisos y carpetas)', 'gl', 1, round(((50000000 / coalesce(public.fx_rate_at(current_date), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'MANO-2';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Seguros personal y resp. civil', 'gl', 1, round(((1000000 / coalesce(public.fx_rate_at(current_date), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'VARI-1';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Volquetes', 'gl', 1, round(((720000 / coalesce(public.fx_rate_at(current_date), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'VARI-2';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Sanitario de obra', 'gl', 1, round(((250000 / coalesce(public.fx_rate_at(current_date), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'VARI-3';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'Edenor', 'gl', 1, round(((200000 / coalesce(public.fx_rate_at(current_date), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'VARI-4';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'flete', 'gl', 1, round(((160000 / coalesce(public.fx_rate_at(current_date), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'VARI-5';
insert into public.budget_lines (project_id, item_id, category_id, description, unit, qty_original, price_original_usd)
  select pr.id, i.id, i.category_id, 'expensas', 'gl', 1, round(((6700000 / coalesce(public.fx_rate_at(current_date), 1200)))::numeric, 4)
  from public.projects pr, public.items i
  where pr.code = 'SR583' and i.code = 'VARI-6';

-- 6. Gastos reales: solo lo COMPRADO -----------------------------------------
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'Compre Lote', current_date, 1, 39200, 'USD', null, 'recibida'
  from public.projects pr
  join public.items i on i.code = 'TRAM-1'
  left join public.suppliers sp on sp.name = 'Clientes'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'Honorarios inmobiliaria', current_date, 1, 1568, 'USD', null, 'recibida'
  from public.projects pr
  join public.items i on i.code = 'TRAM-2'
  left join public.suppliers sp on sp.name = 'Inmobiliaria'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'Gastos cesion', current_date, 1, 355000, 'USD', null, 'recibida'
  from public.projects pr
  join public.items i on i.code = 'TRAM-3'
  left join public.suppliers sp on sp.name = 'escribania'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'Gastos Eidico', '2025-02-25', 1, 93170.76, 'ARS', coalesce(public.fx_rate_at('2025-02-25'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'TRAM-4'
  left join public.suppliers sp on sp.name = 'Eidico'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'Gastos varios (renders - impresiones etc)', current_date, 1, 74900, 'ARS', coalesce(public.fx_rate_at(current_date), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'TRAM-5'
  left join public.suppliers sp on sp.name = 'Estudio Lenga'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'Gestoria', current_date, 1, 4923667.4, 'ARS', coalesce(public.fx_rate_at(current_date), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'TRAM-6'
  left join public.suppliers sp on sp.name = 'Estudio Figueras'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'Mano de obra de perforaciones de pilotes', '2025-09-17', 1, 900000, 'ARS', coalesce(public.fx_rate_at('2025-09-17'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'PILO-1'
  left join public.suppliers sp on sp.name = 'Juan -+54 9 230 450-4450'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'Hormigon', '2025-09-23', 1, 1192000, 'ARS', coalesce(public.fx_rate_at('2025-09-23'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'PILO-2'
  left join public.suppliers sp on sp.name = 'Nueva Casa'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'Corralon', current_date, 1, 19000, 'USD', null, 'recibida'
  from public.projects pr
  join public.items i on i.code = 'CORR-1'
  left join public.suppliers sp on sp.name = 'Cordani'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'Pileta de Patio 4 entradas 40x63 awaduct', '2026-05-02', 4, 6652.62, 'ARS', coalesce(public.fx_rate_at('2026-05-02'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'INST-1'
  left join public.suppliers sp on sp.name = 'Sanitarios Panamericana'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'Boca acceso Cocina 3 entradas 63x50 awaduct', '2026-05-02', 2, 5050.59, 'ARS', coalesce(public.fx_rate_at('2026-05-02'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'INST-2'
  left join public.suppliers sp on sp.name = 'Sanitarios Panamericana'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'Codo de 110 a 90 awaduct', '2026-05-02', 5, 2612.85, 'ARS', coalesce(public.fx_rate_at('2026-05-02'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'INST-3'
  left join public.suppliers sp on sp.name = 'Sanitarios Panamericana'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'codo 110 a 90 HHC awaduct', '2026-05-02', 5, 3126.41, 'ARS', coalesce(public.fx_rate_at('2026-05-02'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'INST-4'
  left join public.suppliers sp on sp.name = 'Sanitarios Panamericana'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'Codo de 110 a 45 awaduct', '2026-05-02', 10, 2405.28, 'ARS', coalesce(public.fx_rate_at('2026-05-02'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'INST-5'
  left join public.suppliers sp on sp.name = 'Sanitarios Panamericana'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'Codo 110 a 45HHC awaduct', '2026-05-02', 5, 2882.74, 'ARS', coalesce(public.fx_rate_at('2026-05-02'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'INST-6'
  left join public.suppliers sp on sp.name = 'Sanitarios Panamericana'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'Ramal a 45 de 110x63 awaduct', '2026-05-02', 6, 3912.66, 'ARS', coalesce(public.fx_rate_at('2026-05-02'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'INST-7'
  left join public.suppliers sp on sp.name = 'Sanitarios Panamericana'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'Ramal a 45 de 110x110 awaduct', '2026-05-02', 10, 5508.1, 'ARS', coalesce(public.fx_rate_at('2026-05-02'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'INST-8'
  left join public.suppliers sp on sp.name = 'Sanitarios Panamericana'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'Codo de 63 a 45 awaduct', '2026-05-02', 17, 1142.84, 'ARS', coalesce(public.fx_rate_at('2026-05-02'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'INST-9'
  left join public.suppliers sp on sp.name = 'Sanitarios Panamericana'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'Codo 63 a 45 HH awaduct', '2026-05-02', 10, 1347.97, 'ARS', coalesce(public.fx_rate_at('2026-05-02'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'INST-10'
  left join public.suppliers sp on sp.name = 'Sanitarios Panamericana'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'codo de 63 a 90 awaduct', '2026-05-02', 4, 1206.81, 'ARS', coalesce(public.fx_rate_at('2026-05-02'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'INST-11'
  left join public.suppliers sp on sp.name = 'Sanitarios Panamericana'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'codo 63 a 90 HH awaduct', '2026-05-02', 5, 1411.91, 'ARS', coalesce(public.fx_rate_at('2026-05-02'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'INST-12'
  left join public.suppliers sp on sp.name = 'Sanitarios Panamericana'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'Codo 50 a 45 HH awaduct', '2026-05-02', 5, 841.31, 'ARS', coalesce(public.fx_rate_at('2026-05-02'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'INST-13'
  left join public.suppliers sp on sp.name = 'Sanitarios Panamericana'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'Codo de 50 a 45 awaduct', '2026-05-02', 5, 380.28, 'ARS', coalesce(public.fx_rate_at('2026-05-02'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'INST-14'
  left join public.suppliers sp on sp.name = 'Sanitarios Panamericana'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'Codo de 50 a 90 awaduct', '2026-05-02', 4, 680.28, 'ARS', coalesce(public.fx_rate_at('2026-05-02'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'INST-15'
  left join public.suppliers sp on sp.name = 'Sanitarios Panamericana'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'Codo 50 a 90 HH awaduct', '2026-05-02', 4, 841.31, 'ARS', coalesce(public.fx_rate_at('2026-05-02'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'INST-16'
  left join public.suppliers sp on sp.name = 'Sanitarios Panamericana'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'Codo de 40 a 45 awaduct', '2026-05-02', 15, 475.32, 'ARS', coalesce(public.fx_rate_at('2026-05-02'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'INST-17'
  left join public.suppliers sp on sp.name = 'Sanitarios Panamericana'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'Codo 40 a 45 HH awaduct', '2026-05-02', 10, 603.66, 'ARS', coalesce(public.fx_rate_at('2026-05-02'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'INST-18'
  left join public.suppliers sp on sp.name = 'Sanitarios Panamericana'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'Codo TE 40 a 90 awaduct', '2026-05-02', 8, 1011.5, 'ARS', coalesce(public.fx_rate_at('2026-05-02'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'INST-19'
  left join public.suppliers sp on sp.name = 'Sanitarios Panamericana'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'Codo 40 a 90 HH awaduct', '2026-05-02', 10, 636.33, 'ARS', coalesce(public.fx_rate_at('2026-05-02'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'INST-20'
  left join public.suppliers sp on sp.name = 'Sanitarios Panamericana'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'Ramal a 45 de 40x40 HHH awaduct', '2026-05-02', 4, 1461.72, 'ARS', coalesce(public.fx_rate_at('2026-05-02'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'INST-21'
  left join public.suppliers sp on sp.name = 'Sanitarios Panamericana'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'Solucion lubricante x 400', '2026-05-02', 8, 10385.72, 'ARS', coalesce(public.fx_rate_at('2026-05-02'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'INST-22'
  left join public.suppliers sp on sp.name = 'Sanitarios Panamericana'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'Cano awaduct 110x4mts', '2026-05-02', 10, 17630.05, 'ARS', coalesce(public.fx_rate_at('2026-05-02'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'INST-23'
  left join public.suppliers sp on sp.name = 'Sanitarios Panamericana'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'Cano awaduct 63x4mts', '2026-05-02', 4, 9675.4, 'ARS', coalesce(public.fx_rate_at('2026-05-02'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'INST-24'
  left join public.suppliers sp on sp.name = 'Sanitarios Panamericana'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'Cano awaduct 50x2mts', '2026-05-02', 2, 4290.58, 'ARS', coalesce(public.fx_rate_at('2026-05-02'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'INST-25'
  left join public.suppliers sp on sp.name = 'Sanitarios Panamericana'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'Cano awaduct 40x4mts', '2026-05-02', 4, 6163.55, 'ARS', coalesce(public.fx_rate_at('2026-05-02'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'INST-26'
  left join public.suppliers sp on sp.name = 'Sanitarios Panamericana'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'Adaptador pileta descarga aire acondicionado .40x3/4', '2026-05-02', 6, 348.88, 'ARS', coalesce(public.fx_rate_at('2026-05-02'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'INST-27'
  left join public.suppliers sp on sp.name = 'Sanitarios Panamericana'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'Manguito reparacion 110 awaduct', '2026-05-02', 10, 2487.21, 'ARS', coalesce(public.fx_rate_at('2026-05-02'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'INST-28'
  left join public.suppliers sp on sp.name = 'Sanitarios Panamericana'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'Manguito reparacion 63 awaduct', '2026-05-02', 5, 1142.84, 'ARS', coalesce(public.fx_rate_at('2026-05-02'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'INST-29'
  left join public.suppliers sp on sp.name = 'Sanitarios Panamericana'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'Manguito reparacion 50 awaduct', '2026-05-02', 5, 860.5, 'ARS', coalesce(public.fx_rate_at('2026-05-02'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'INST-30'
  left join public.suppliers sp on sp.name = 'Sanitarios Panamericana'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'Codo 110 c/3 acom.A 63 Boca acceso Horizontal awaduct', '2026-05-02', 3, 5258.84, 'ARS', coalesce(public.fx_rate_at('2026-05-02'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'INST-31'
  left join public.suppliers sp on sp.name = 'Sanitarios Panamericana'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'manguito reparacion 40 awaduct', '2026-05-02', 5, 783.59, 'ARS', coalesce(public.fx_rate_at('2026-05-02'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'INST-32'
  left join public.suppliers sp on sp.name = 'Sanitarios Panamericana'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'Buje Red. 110x63 awaduct', '2026-05-02', 4, 1907.04, 'ARS', coalesce(public.fx_rate_at('2026-05-02'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'INST-33'
  left join public.suppliers sp on sp.name = 'Sanitarios Panamericana'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'Cano polietileno 3/4 K-4 (R.100mts) valor x mt', '2026-05-02', 25, 348.61, 'ARS', coalesce(public.fx_rate_at('2026-05-02'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'INST-34'
  left join public.suppliers sp on sp.name = 'Sanitarios Panamericana'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'Enchufe doble codo 3/4 p/cano de polietileno', '2026-05-02', 15, 173.28, 'ARS', coalesce(public.fx_rate_at('2026-05-02'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'INST-35'
  left join public.suppliers sp on sp.name = 'Sanitarios Panamericana'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'Enchufe doble 3/4 p/cano de polietileno', '2026-05-02', 6, 110.77, 'ARS', coalesce(public.fx_rate_at('2026-05-02'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'INST-36'
  left join public.suppliers sp on sp.name = 'Sanitarios Panamericana'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'enchufe triple tee 3/4 p/cano de polietileno', '2026-05-02', 4, 283.31, 'ARS', coalesce(public.fx_rate_at('2026-05-02'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'INST-37'
  left join public.suppliers sp on sp.name = 'Sanitarios Panamericana'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'latyn fleje perforado 17x0.7mmx10m', '2026-05-02', 1, 8590.14, 'ARS', coalesce(public.fx_rate_at('2026-05-02'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'INST-38'
  left join public.suppliers sp on sp.name = 'Sanitarios Panamericana'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'fischer tarugo sab+TMF 22x45 bolsa x100', '2026-05-02', 1, 616.83, 'ARS', coalesce(public.fx_rate_at('2026-05-02'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'INST-39'
  left join public.suppliers sp on sp.name = 'Sanitarios Panamericana'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'embudo horiz. 110mm reja plast. 20x20 duratop xrs', '2026-05-02', 1, 6319.61, 'ARS', coalesce(public.fx_rate_at('2026-05-02'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'INST-40'
  left join public.suppliers sp on sp.name = 'Sanitarios Panamericana'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'tapa PVC 110 tigre ramat', '2026-05-02', 15, 1349.87, 'ARS', coalesce(public.fx_rate_at('2026-05-02'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'INST-41'
  left join public.suppliers sp on sp.name = 'Sanitarios Panamericana'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'Tapa pvc 40 tigre ramat', '2026-05-02', 15, 393.4, 'ARS', coalesce(public.fx_rate_at('2026-05-02'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'INST-42'
  left join public.suppliers sp on sp.name = 'Sanitarios Panamericana'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'llave de paso de 20 tigre fusion', '2026-05-02', 15, 11050.44, 'ARS', coalesce(public.fx_rate_at('2026-05-02'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'INST-43'
  left join public.suppliers sp on sp.name = 'Sanitarios Panamericana'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'llave de paso de 25 tigre fusion', '2026-05-02', 2, 13336.73, 'ARS', coalesce(public.fx_rate_at('2026-05-02'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'INST-44'
  left join public.suppliers sp on sp.name = 'Sanitarios Panamericana'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'esferica 32mm p/exterior paso total acqua system', '2026-05-02', 5, 18032.12, 'ARS', coalesce(public.fx_rate_at('2026-05-02'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'INST-45'
  left join public.suppliers sp on sp.name = 'Sanitarios Panamericana'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'esperica 25mm p/exterior paso total acqua system', '2026-05-02', 2, 13029.8, 'ARS', coalesce(public.fx_rate_at('2026-05-02'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'INST-46'
  left join public.suppliers sp on sp.name = 'Sanitarios Panamericana'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'codo rca.met.hembra 20x1/2 tigre fusion', '2026-05-02', 26, 1474.38, 'ARS', coalesce(public.fx_rate_at('2026-05-02'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'INST-47'
  left join public.suppliers sp on sp.name = 'Sanitarios Panamericana'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'codo rosca met. Hembra 25xx3/4 tigre fusion', '2026-05-02', 6, 2133.87, 'ARS', coalesce(public.fx_rate_at('2026-05-02'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'INST-48'
  left join public.suppliers sp on sp.name = 'Sanitarios Panamericana'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'codo rosca met. Hembra 32x1 tigre fusion', '2026-05-02', 3, 4027.68, 'ARS', coalesce(public.fx_rate_at('2026-05-02'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'INST-49'
  left join public.suppliers sp on sp.name = 'Sanitarios Panamericana'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'tubo macho 20x1/2 tigre fusion', '2026-05-02', 10, 1829.04, 'ARS', coalesce(public.fx_rate_at('2026-05-02'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'INST-50'
  left join public.suppliers sp on sp.name = 'Sanitarios Panamericana'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'tubo macho 25x3/4 tigre fusion', '2026-05-02', 4, 2362.51, 'ARS', coalesce(public.fx_rate_at('2026-05-02'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'INST-51'
  left join public.suppliers sp on sp.name = 'Sanitarios Panamericana'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'tubo macho 32x1"tigre fusion', '2026-05-02', 8, 4839.32, 'ARS', coalesce(public.fx_rate_at('2026-05-02'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'INST-52'
  left join public.suppliers sp on sp.name = 'Sanitarios Panamericana'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'tubo hembra 20x1/2 tigre fusion', '2026-05-02', 10, 1467.04, 'ARS', coalesce(public.fx_rate_at('2026-05-02'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'INST-53'
  left join public.suppliers sp on sp.name = 'Sanitarios Panamericana'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'Tubo hembra 25x3/4 tigre fusion', '2026-05-02', 4, 2133.87, 'ARS', coalesce(public.fx_rate_at('2026-05-02'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'INST-54'
  left join public.suppliers sp on sp.name = 'Sanitarios Panamericana'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'Tubo hembra 32x1" tigre fusion', '2026-05-02', 3, 3685.96, 'ARS', coalesce(public.fx_rate_at('2026-05-02'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'INST-55'
  left join public.suppliers sp on sp.name = 'Sanitarios Panamericana'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'Codo de 20 a 90 tigre fusion', '2026-05-02', 50, 196.74, 'ARS', coalesce(public.fx_rate_at('2026-05-02'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'INST-56'
  left join public.suppliers sp on sp.name = 'Sanitarios Panamericana'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'Codo de 25 x 90 tigre fusion', '2026-05-02', 40, 308.9, 'ARS', coalesce(public.fx_rate_at('2026-05-02'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'INST-57'
  left join public.suppliers sp on sp.name = 'Sanitarios Panamericana'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'Codo de 32 a 90 tigre fusion', '2026-05-02', 30, 514.4, 'ARS', coalesce(public.fx_rate_at('2026-05-02'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'INST-58'
  left join public.suppliers sp on sp.name = 'Sanitarios Panamericana'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'TEE de 20 tigre fusion', '2026-05-02', 20, 294.87, 'ARS', coalesce(public.fx_rate_at('2026-05-02'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'INST-59'
  left join public.suppliers sp on sp.name = 'Sanitarios Panamericana'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'TEE de 25 tigre fusion', '2026-05-02', 20, 497.6, 'ARS', coalesce(public.fx_rate_at('2026-05-02'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'INST-60'
  left join public.suppliers sp on sp.name = 'Sanitarios Panamericana'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'TEE de 32 tigre fusion', '2026-05-02', 15, 755.6, 'ARS', coalesce(public.fx_rate_at('2026-05-02'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'INST-61'
  left join public.suppliers sp on sp.name = 'Sanitarios Panamericana'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'Union normal de 20 tigre fusion', '2026-05-02', 20, 148.61, 'ARS', coalesce(public.fx_rate_at('2026-05-02'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'INST-62'
  left join public.suppliers sp on sp.name = 'Sanitarios Panamericana'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'Union normal de 25 tigre fusion', '2026-05-02', 20, 240.06, 'ARS', coalesce(public.fx_rate_at('2026-05-02'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'INST-63'
  left join public.suppliers sp on sp.name = 'Sanitarios Panamericana'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'Union normal de 32 tigre fusion', '2026-05-02', 10, 339.13, 'ARS', coalesce(public.fx_rate_at('2026-05-02'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'INST-64'
  left join public.suppliers sp on sp.name = 'Sanitarios Panamericana'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'Buje 25x20 tigre fusion', '2026-05-02', 15, 255.75, 'ARS', coalesce(public.fx_rate_at('2026-05-02'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'INST-65'
  left join public.suppliers sp on sp.name = 'Sanitarios Panamericana'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'Buje 32x25 tigre fusion', '2026-05-02', 15, 377.54, 'ARS', coalesce(public.fx_rate_at('2026-05-02'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'INST-66'
  left join public.suppliers sp on sp.name = 'Sanitarios Panamericana'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'Curva sobrepasaje 20 iny tigre fusion', '2026-05-02', 15, 750.76, 'ARS', coalesce(public.fx_rate_at('2026-05-02'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'INST-67'
  left join public.suppliers sp on sp.name = 'Sanitarios Panamericana'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'Curva sobrepasaje de 32 acqua system', '2026-05-02', 5, 2027.27, 'ARS', coalesce(public.fx_rate_at('2026-05-02'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'INST-68'
  left join public.suppliers sp on sp.name = 'Sanitarios Panamericana'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'Curva sobrepasaje 25 INY tigre fusion', '2026-05-02', 5, 1084.14, 'ARS', coalesce(public.fx_rate_at('2026-05-02'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'INST-69'
  left join public.suppliers sp on sp.name = 'Sanitarios Panamericana'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'Rotoplas cisterna 110mts modular c/flot-fil-aut', '2026-05-02', 1, 688733.49, 'ARS', coalesce(public.fx_rate_at('2026-05-02'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'INST-70'
  left join public.suppliers sp on sp.name = 'Sanitarios Panamericana'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'adaptador p/tanque  1 c/bridas', '2026-05-02', 1, 2719.98, 'ARS', coalesce(public.fx_rate_at('2026-05-02'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'INST-71'
  left join public.suppliers sp on sp.name = 'Sanitarios Panamericana'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'Adaptador p/tanque PPN 3/4 c/bridas', '2026-05-02', 1, 2551.82, 'ARS', coalesce(public.fx_rate_at('2026-05-02'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'INST-72'
  left join public.suppliers sp on sp.name = 'Sanitarios Panamericana'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'Valvula retencion Vert. 1 BDE.', '2026-05-02', 1, 10844.32, 'ARS', coalesce(public.fx_rate_at('2026-05-02'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'INST-73'
  left join public.suppliers sp on sp.name = 'Sanitarios Panamericana'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'Boya de telgopor 3/4', '2026-05-02', 1, 9598.22, 'ARS', coalesce(public.fx_rate_at('2026-05-02'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'INST-74'
  left join public.suppliers sp on sp.name = 'Sanitarios Panamericana'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'Flotante a presion 3/4 sin boya', '2026-05-02', 1, 40761.63, 'ARS', coalesce(public.fx_rate_at('2026-05-02'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'INST-75'
  left join public.suppliers sp on sp.name = 'Sanitarios Panamericana'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'tapon PPN 1/2', '2026-05-02', 30, 135.33, 'ARS', coalesce(public.fx_rate_at('2026-05-02'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'INST-76'
  left join public.suppliers sp on sp.name = 'Sanitarios Panamericana'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'Tapon PPN 3/4', '2026-05-02', 8, 159.78, 'ARS', coalesce(public.fx_rate_at('2026-05-02'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'INST-77'
  left join public.suppliers sp on sp.name = 'Sanitarios Panamericana'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'tapon PPN 1/2', '2026-05-02', 5, 373.14, 'ARS', coalesce(public.fx_rate_at('2026-05-02'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'INST-78'
  left join public.suppliers sp on sp.name = 'Sanitarios Panamericana'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'Tapa de 20 tigre fusion', '2026-05-02', 8, 144.8, 'ARS', coalesce(public.fx_rate_at('2026-05-02'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'INST-79'
  left join public.suppliers sp on sp.name = 'Sanitarios Panamericana'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'Tapa de 25 tigre fusion', '2026-05-02', 4, 231.37, 'ARS', coalesce(public.fx_rate_at('2026-05-02'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'INST-80'
  left join public.suppliers sp on sp.name = 'Sanitarios Panamericana'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'Tapa de 32 tigre fusion', '2026-05-02', 3, 284.17, 'ARS', coalesce(public.fx_rate_at('2026-05-02'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'INST-81'
  left join public.suppliers sp on sp.name = 'Sanitarios Panamericana'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'Rollo cinta teflon de 3/4 x 40mts alta densidad', '2026-05-02', 3, 4115.87, 'ARS', coalesce(public.fx_rate_at('2026-05-02'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'INST-82'
  left join public.suppliers sp on sp.name = 'Sanitarios Panamericana'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'Sellador hidro 3x125 C,C', '2026-05-02', 3, 5677.86, 'ARS', coalesce(public.fx_rate_at('2026-05-02'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'INST-83'
  left join public.suppliers sp on sp.name = 'Sanitarios Panamericana'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'Cano Tigre fusion PN-20 20', '2026-05-02', 15, 3529.14, 'ARS', coalesce(public.fx_rate_at('2026-05-02'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'INST-84'
  left join public.suppliers sp on sp.name = 'Sanitarios Panamericana'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'Cano tigre fusion PN-20 25', '2026-05-02', 15, 5311.86, 'ARS', coalesce(public.fx_rate_at('2026-05-02'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'INST-85'
  left join public.suppliers sp on sp.name = 'Sanitarios Panamericana'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'Cano tigre fusion PN-20 32', '2026-05-02', 10, 8625.37, 'ARS', coalesce(public.fx_rate_at('2026-05-02'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'INST-86'
  left join public.suppliers sp on sp.name = 'Sanitarios Panamericana'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'Sigas valvula esferica 32mm', '2026-05-02', 1, 46602.79, 'ARS', coalesce(public.fx_rate_at('2026-05-02'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'INST-87'
  left join public.suppliers sp on sp.name = 'Sanitarios Panamericana'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'Sigas valvula esferica 25mm', '2026-05-02', 1, 21737.53, 'ARS', coalesce(public.fx_rate_at('2026-05-02'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'INST-88'
  left join public.suppliers sp on sp.name = 'Sanitarios Panamericana'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'sigas codo 32x3/4 rosca hembra', '2026-05-02', 1, 8556.55, 'ARS', coalesce(public.fx_rate_at('2026-05-02'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'INST-89'
  left join public.suppliers sp on sp.name = 'Sanitarios Panamericana'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'sigas codo a 90 de 32mm', '2026-05-02', 10, 3382.2, 'ARS', coalesce(public.fx_rate_at('2026-05-02'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'INST-90'
  left join public.suppliers sp on sp.name = 'Sanitarios Panamericana'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'sigas codo 25 x 1/2 rosca hembra', '2026-05-02', 1, 5407.44, 'ARS', coalesce(public.fx_rate_at('2026-05-02'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'INST-91'
  left join public.suppliers sp on sp.name = 'Sanitarios Panamericana'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'sigas codo a 90 de 25mm', '2026-05-02', 10, 2200.32, 'ARS', coalesce(public.fx_rate_at('2026-05-02'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'INST-92'
  left join public.suppliers sp on sp.name = 'Sanitarios Panamericana'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'sigas union normal 32mm', '2026-05-02', 5, 1853.29, 'ARS', coalesce(public.fx_rate_at('2026-05-02'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'INST-93'
  left join public.suppliers sp on sp.name = 'Sanitarios Panamericana'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'sigas union normal 25mm', '2026-05-02', 5, 1615.25, 'ARS', coalesce(public.fx_rate_at('2026-05-02'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'INST-94'
  left join public.suppliers sp on sp.name = 'Sanitarios Panamericana'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'sigas codo 32x1 rosca hembra', '2026-05-02', 1, 10458.42, 'ARS', coalesce(public.fx_rate_at('2026-05-02'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'INST-95'
  left join public.suppliers sp on sp.name = 'Sanitarios Panamericana'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'sigas TEE reduccion 32x25mm', '2026-05-02', 1, 4823.44, 'ARS', coalesce(public.fx_rate_at('2026-05-02'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'INST-96'
  left join public.suppliers sp on sp.name = 'Sanitarios Panamericana'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'Tapon epoxi 3/4', '2026-05-02', 2, 1323.88, 'ARS', coalesce(public.fx_rate_at('2026-05-02'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'INST-97'
  left join public.suppliers sp on sp.name = 'Sanitarios Panamericana'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'tapon epoxi 1/2', '2026-05-02', 1, 851.48, 'ARS', coalesce(public.fx_rate_at('2026-05-02'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'INST-98'
  left join public.suppliers sp on sp.name = 'Sanitarios Panamericana'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'codo red. Epoxi 1x3/4', '2026-05-02', 1, 3060.13, 'ARS', coalesce(public.fx_rate_at('2026-05-02'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'INST-99'
  left join public.suppliers sp on sp.name = 'Sanitarios Panamericana'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'niple epoxi 1x10cm', '2026-05-02', 1, 2079, 'ARS', coalesce(public.fx_rate_at('2026-05-02'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'INST-100'
  left join public.suppliers sp on sp.name = 'Sanitarios Panamericana'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'niple epoxi 1x15cm', '2026-05-02', 1, 3108.26, 'ARS', coalesce(public.fx_rate_at('2026-05-02'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'INST-101'
  left join public.suppliers sp on sp.name = 'Sanitarios Panamericana'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'esmalte epoxi 250cm3 (conjunto AyB 2x125)', '2026-05-02', 1, 10091.87, 'ARS', coalesce(public.fx_rate_at('2026-05-02'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'INST-102'
  left join public.suppliers sp on sp.name = 'Sanitarios Panamericana'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'pincel calisco 1" PCS-10', '2026-05-02', 1, 1468.46, 'ARS', coalesce(public.fx_rate_at('2026-05-02'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'INST-103'
  left join public.suppliers sp on sp.name = 'Sanitarios Panamericana'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'sigas tubo 32x4mts. Acero-polietileno', '2026-05-02', 3, 32520.6, 'ARS', coalesce(public.fx_rate_at('2026-05-02'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'INST-104'
  left join public.suppliers sp on sp.name = 'Sanitarios Panamericana'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'sigas tubo 25x4mts. Acero-polietileno', '2026-05-02', 3, 21335.19, 'ARS', coalesce(public.fx_rate_at('2026-05-02'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'INST-105'
  left join public.suppliers sp on sp.name = 'Sanitarios Panamericana'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'kit coelctor 6 circuitos 20mm plascio ent.der.', '2026-05-02', 1, 426297.91, 'ARS', coalesce(public.fx_rate_at('2026-05-02'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'INST-106'
  left join public.suppliers sp on sp.name = 'Sanitarios Panamericana'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'Tubo pecc tubotherm 3/4 (20x2.0)(rollo x 100mts)', '2026-05-02', 7, 1040.64, 'ARS', coalesce(public.fx_rate_at('2026-05-02'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'INST-107'
  left join public.suppliers sp on sp.name = 'Sanitarios Panamericana'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'Manta aislante termica dema 10mm 1x20', '2026-05-02', 7, 24544.25, 'ARS', coalesce(public.fx_rate_at('2026-05-02'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'INST-108'
  left join public.suppliers sp on sp.name = 'Sanitarios Panamericana'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'prescintos 200mm x100 unid.', '2026-05-02', 20, 2962.15, 'ARS', coalesce(public.fx_rate_at('2026-05-02'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'INST-109'
  left join public.suppliers sp on sp.name = 'Sanitarios Panamericana'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'Bomba presurizadora', '2026-06-02', 1, 90137, 'ARS', coalesce(public.fx_rate_at('2026-06-02'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'INST-110'
  left join public.suppliers sp on sp.name = 'mercado libre'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'Matriculado de gas', '2026-01-27', 1, 550000, 'ARS', coalesce(public.fx_rate_at('2026-01-27'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'TRAM-7'
  left join public.suppliers sp on sp.name = 'Raul'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'Ferrum - Bidet Bari Blanca 1A BKM1B', '2025-07-16', 2, 66260, 'ARS', coalesce(public.fx_rate_at('2025-07-16'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'ACCE-1'
  left join public.suppliers sp on sp.name = 'Pentacons'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'Ferrum - Inodoro Bari Largo Blanco IKLMB', '2025-07-16', 3, 90202, 'ARS', coalesce(public.fx_rate_at('2025-07-16'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'ACCE-2'
  left join public.suppliers sp on sp.name = 'Pentacons'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'Ferrum - Deposito Bari Apoyar Blanco dual DKW6F', '2025-07-16', 3, 86821, 'ARS', coalesce(public.fx_rate_at('2025-07-16'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'ACCE-3'
  left join public.suppliers sp on sp.name = 'Pentacons'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'Ferrum - Asiento inod. Bari TKWP B', '2025-07-16', 3, 39873, 'ARS', coalesce(public.fx_rate_at('2025-07-16'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'ACCE-4'
  left join public.suppliers sp on sp.name = 'Pentacons'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'Peirano - Lavatorio Bicom. C.Ceram adra cr', '2025-07-16', 2, 38234.22, 'ARS', coalesce(public.fx_rate_at('2025-07-16'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'ACCE-5'
  left join public.suppliers sp on sp.name = 'Pentacons'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'Peirano - Ducha Emb Bicomando C.Cerm C/transf. Adra pl', '2025-07-16', 2, 72326.3, 'ARS', coalesce(public.fx_rate_at('2025-07-16'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'ACCE-6'
  left join public.suppliers sp on sp.name = 'Pentacons'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'Peirano - Bide Bicom. C. Ceram adra cr', '2025-07-16', 2, 41354, 'ARS', coalesce(public.fx_rate_at('2025-07-16'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'ACCE-7'
  left join public.suppliers sp on sp.name = 'Pentacons'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'Peirano - Lavatorio Monoc. Bajo Adra Cr', '2025-07-16', 1, 43163.55, 'ARS', coalesce(public.fx_rate_at('2025-07-16'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'ACCE-8'
  left join public.suppliers sp on sp.name = 'Pentacons'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'Zedra - Bacha Kahlo 36x12,5cm', '2025-07-16', 2, 52597.19, 'ARS', coalesce(public.fx_rate_at('2025-07-16'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'ACCE-9'
  left join public.suppliers sp on sp.name = 'Pentacons'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'Gulliart - Bacha de apoyo due 1A BL 1 Orif 420x245x1', '2025-07-16', 1, 71943.14, 'ARS', coalesce(public.fx_rate_at('2025-07-16'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'ACCE-10'
  left join public.suppliers sp on sp.name = 'Pentacons'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'Peirano - Porta Rollo linea 13000', '2025-07-16', 3, 149411.63, 'ARS', coalesce(public.fx_rate_at('2025-07-16'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'ACCE-11'
  left join public.suppliers sp on sp.name = 'Pentacons'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'Peirano - Toallero barral linea 13000 CR', '2025-07-16', 3, 28912.01, 'ARS', coalesce(public.fx_rate_at('2025-07-16'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'ACCE-12'
  left join public.suppliers sp on sp.name = 'Pentacons'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'Peirano - Cocina monoc. ADRA CR', '2025-07-16', 1, 65867.95, 'ARS', coalesce(public.fx_rate_at('2025-07-16'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'ACCE-13'
  left join public.suppliers sp on sp.name = 'Pentacons'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'Bacha Johnson - Luxor mini SI55A 55x41,5x20', '2025-07-16', 1, 124507.47, 'ARS', coalesce(public.fx_rate_at('2025-07-16'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'ACCE-14'
  left join public.suppliers sp on sp.name = 'Pentacons'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'Caldera Ariston Dual HS x 24 FF R/FF', '2025-07-16', 1, 1295873.51, 'ARS', coalesce(public.fx_rate_at('2025-07-16'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'ACCE-15'
  left join public.suppliers sp on sp.name = 'Pentacons'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'Monoc. Cocina MSDA Giratoria Cromo Dique', '2025-07-16', 2, 32002.79, 'ARS', coalesce(public.fx_rate_at('2025-07-16'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'ACCE-16'
  left join public.suppliers sp on sp.name = 'Pentacons'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'Certificación eléctrica + matriculado tramite edenor DCI Luz de obra', '2025-03-13', 1, 280000, 'ARS', coalesce(public.fx_rate_at('2025-03-13'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'TRAM-8'
  left join public.suppliers sp on sp.name = 'ivan matriculado'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'Porcellanato en PB + banos', '2026-01-15', 122, 18000, 'ARS', coalesce(public.fx_rate_at('2026-01-15'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'PISO-1'
  left join public.suppliers sp on sp.name = 'Grupo Gemme'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'Carpinterías de Aluminio (línea modena, color aluminio negro, vidrios 6mm y laminado 3+3 en paños grandes, con mosquiteros y sin premarcos)', '2025-03-07', 1, 7700000, 'ARS', coalesce(public.fx_rate_at('2025-03-07'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'CARP-1'
  left join public.suppliers sp on sp.name = 'Carli'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'Puertas  (pta lisa 70 pino/80 pino 15cm mdf 5,5 p/p pintar)', '2025-05-20', 1, 949000, 'ARS', coalesce(public.fx_rate_at('2025-05-20'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'CARP-3'
  left join public.suppliers sp on sp.name = 'Pentacons'
  where pr.code = 'SR583';
insert into public.expenses (project_id, item_id, supplier_id, category_id,
       description, expense_date, qty, unit_price, currency, fx_usd, purchase_stage)
  select pr.id, i.id, sp.id, i.category_id, 'Mueble de Cocina', '2026-05-28', 1, 3100000, 'ARS', coalesce(public.fx_rate_at('2026-05-28'), 1200), 'recibida'
  from public.projects pr
  join public.items i on i.code = 'MUEB-4'
  left join public.suppliers sp on sp.name = 'Alejandro - FPD'
  where pr.code = 'SR583';

commit;