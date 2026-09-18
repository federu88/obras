-- ===========================================================================
-- Gastos diarios de los lotes 583 y 84, desde 'Gastos SR84 y 583_Presupuesto1.7.xlsx'
-- Generado el 2026-09-18. Correr UNA SOLA VEZ.
--
-- Fechas: las que quedaron como TEXTO en el Excel se parsean dia/mes/año —
-- quedaron sin parsear justamente porque el dia es mayor a 12, asi que no
-- son ambiguas. Las que Excel si parseo se corrigen SOLO cuando el dia
-- guardado coincide con el mes nombrado en el concepto y el mes no: dar
-- vuelta todas romperia las 102 que estan bien.
-- ===========================================================================

begin;

-- Categorias que faltan ------------------------------------------------------
insert into public.cost_categories (parent_id, name, kind)
  select c.id, 'Servicios de obra', 'indirecto' from public.cost_categories c
  where c.parent_id is null and c.name = 'Costos indirectos'
    and not exists (select 1 from public.cost_categories x where x.parent_id = c.id and x.name = 'Servicios de obra');
insert into public.cost_categories (parent_id, name, kind)
  select c.id, 'Gastos de obra', 'directo' from public.cost_categories c
  where c.parent_id is null and c.name = 'Varios'
    and not exists (select 1 from public.cost_categories x where x.parent_id = c.id and x.name = 'Gastos de obra');
insert into public.cost_categories (parent_id, name, kind)
  select c.id, 'Tareas preliminares', 'directo' from public.cost_categories c
  where c.parent_id is null and c.name = 'Varios'
    and not exists (select 1 from public.cost_categories x where x.parent_id = c.id and x.name = 'Tareas preliminares');

-- Gastos diarios lote 583 -> SR583 -----------------
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'Expensas mes noviembre', '2024-11-07', 1, 280957, 'ARS',
         coalesce(public.fx_rate_at('2024-11-07'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Costos indirectos'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Expensas'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'Expensas mes diciembre', '2024-12-02', 1, 424000, 'ARS',
         coalesce(public.fx_rate_at('2024-12-02'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Costos indirectos'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Expensas'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'Expensas mes enero', '2025-01-09', 1, 181034.93, 'ARS',
         coalesce(public.fx_rate_at('2025-01-09'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Costos indirectos'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Expensas'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'Expensas mes febrero', '2025-02-06', 1, 304680.17, 'ARS',
         coalesce(public.fx_rate_at('2025-02-06'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Costos indirectos'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Expensas'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'Expensas mes marzo', '2025-03-10', 1, 251235.83, 'ARS',
         coalesce(public.fx_rate_at('2025-03-10'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Costos indirectos'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Expensas'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'expensas mes abril', '2025-04-10', 1, 295185.98, 'ARS',
         coalesce(public.fx_rate_at('2025-04-10'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Costos indirectos'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Expensas'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'expensas mes mayo', '2025-05-09', 1, 534369.45, 'ARS',
         coalesce(public.fx_rate_at('2025-05-09'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Costos indirectos'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Expensas'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'Expensas mes junio', '2025-06-06', 1, 315445.59, 'ARS',
         coalesce(public.fx_rate_at('2025-06-06'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Costos indirectos'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Expensas'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'Expensas mes julio', '2025-07-04', 1, 479190.68, 'ARS',
         coalesce(public.fx_rate_at('2025-07-04'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Costos indirectos'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Expensas'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'Expensas mes agosto', '2025-08-06', 1, 502863.58, 'ARS',
         coalesce(public.fx_rate_at('2025-08-06'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Costos indirectos'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Expensas'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'Expensas mes septiembre', '2025-09-11', 1, 615363.18, 'ARS',
         coalesce(public.fx_rate_at('2025-09-11'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Costos indirectos'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Expensas'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'Expensas mes octubre', '2025-10-08', 1, 561970.48, 'ARS',
         coalesce(public.fx_rate_at('2025-10-08'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Costos indirectos'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Expensas'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'Expensas mes noviembre', '2025-11-07', 1, 469155.74, 'ARS',
         coalesce(public.fx_rate_at('2025-11-07'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Costos indirectos'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Expensas'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'Expensas mes diciembre', '2025-12-04', 1, 535318.3, 'ARS',
         coalesce(public.fx_rate_at('2025-12-04'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Costos indirectos'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Expensas'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'expensas mes enero', '2026-01-09', 1, 559723.44, 'ARS',
         coalesce(public.fx_rate_at('2026-01-09'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Costos indirectos'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Expensas'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'Expensas mes febrero', '2026-02-06', 1, 564332.29, 'ARS',
         coalesce(public.fx_rate_at('2026-02-06'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Costos indirectos'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Expensas'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'Expensas mes marzo', '2026-03-05', 1, 587789.13, 'ARS',
         coalesce(public.fx_rate_at('2026-03-05'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Costos indirectos'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Expensas'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'Expensas mes abril', '2026-04-09', 1, 601686.94, 'ARS',
         coalesce(public.fx_rate_at('2026-04-09'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Costos indirectos'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Expensas'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'expensas mes mayo', '2026-05-11', 1, 618247.14, 'ARS',
         coalesce(public.fx_rate_at('2026-05-11'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Costos indirectos'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Expensas'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'expensas mes junio', '2026-06-09', 1, 838982.32, 'ARS',
         coalesce(public.fx_rate_at('2026-06-09'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Costos indirectos'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Expensas'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'expensas mes julio', '2026-07-13', 1, 434827, 'ARS',
         coalesce(public.fx_rate_at('2026-07-13'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Costos indirectos'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Expensas'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'expensas mes agosto', '2026-08-07', 1, 659717.99, 'ARS',
         coalesce(public.fx_rate_at('2026-08-07'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Costos indirectos'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Expensas'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'Expensas mes septiembre', '2026-09-07', 1, 683184.4, 'ARS',
         coalesce(public.fx_rate_at('2026-09-07'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Costos indirectos'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Expensas'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'anticipio honorarios', '2024-11-05', 1, 600000, 'ARS',
         coalesce(public.fx_rate_at('2024-11-05'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Costos indirectos'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gestoría'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'Gasto gestoria', '2024-02-12', 1, 2196452.4, 'ARS',
         coalesce(public.fx_rate_at('2024-02-12'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Costos indirectos'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gestoría'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'Derechos de construccion', '2025-02-27', 1, 1477215, 'ARS',
         coalesce(public.fx_rate_at('2025-02-27'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Costos indirectos'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gestoría'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'matriculado de edenor', '2025-03-13', 1, 177500, 'ARS',
         coalesce(public.fx_rate_at('2025-03-13'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Costos indirectos'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gestoría'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'materiales edenor', '2025-03-13', 1, 71172, 'ARS',
         coalesce(public.fx_rate_at('2025-03-13'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Costos indirectos'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gestoría'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'Renders', '2025-03-20', 1, 50000, 'ARS',
         coalesce(public.fx_rate_at('2025-03-20'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Costos indirectos'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gestoría'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'anticipio honorarios', '2025-04-14', 1, 600000, 'ARS',
         coalesce(public.fx_rate_at('2025-04-14'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Costos indirectos'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gestoría'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'cartel de obra', '2025-04-21', 1, 18900, 'ARS',
         coalesce(public.fx_rate_at('2025-04-21'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Costos indirectos'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gestoría'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'impresiones', '2025-06-19', 1, 5970, 'ARS',
         coalesce(public.fx_rate_at('2025-06-19'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Costos indirectos'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gestoría'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'Puertas', '2025-05-20', 1, 949000, 'ARS',
         coalesce(public.fx_rate_at('2025-05-20'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'electricista', '2025-05-23', 1, 150000, 'ARS',
         coalesce(public.fx_rate_at('2025-05-23'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'aberturas', '2025-03-07', 1, 7700000, 'ARS',
         coalesce(public.fx_rate_at('2025-03-07'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'Accesorios Casa', '2025-07-16', 1, 2989153.54, 'ARS',
         coalesce(public.fx_rate_at('2025-07-16'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'Pilotes', '2025-09-17', 1, 900000, 'ARS',
         coalesce(public.fx_rate_at('2025-09-17'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'madera porton', '2025-09-17', 1, 27300, 'ARS',
         coalesce(public.fx_rate_at('2025-09-17'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'bano quimico', '2025-09-17', 1, 50000, 'ARS',
         coalesce(public.fx_rate_at('2025-09-17'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, '8m3 de hormigon pilotines', '2025-09-23', 1, 1192000, 'ARS',
         coalesce(public.fx_rate_at('2025-09-23'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'sanitarios', '2025-08-07', 1, 87550, 'ARS',
         coalesce(public.fx_rate_at('2025-08-07'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'materiales sanitarios', '2025-08-13', 1, 15307.8, 'ARS',
         coalesce(public.fx_rate_at('2025-08-13'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'bano quimico', '2025-10-22', 1, 60000, 'ARS',
         coalesce(public.fx_rate_at('2025-10-22'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'sacada de tierra', '2025-10-22', 1, 750000, 'ARS',
         coalesce(public.fx_rate_at('2025-10-22'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'caja navidena', '2025-11-28', 1, 134900, 'ARS',
         coalesce(public.fx_rate_at('2025-11-28'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'ferreteria', '2025-09-01', 1, 72350, 'ARS',
         coalesce(public.fx_rate_at('2025-09-01'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'ferreteria', '2025-10-17', 1, 53236.2, 'ARS',
         coalesce(public.fx_rate_at('2025-10-17'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'ferreteria', '2025-10-20', 1, 23487.18, 'ARS',
         coalesce(public.fx_rate_at('2025-10-20'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'corralon', '2025-10-17', 1, 70140, 'ARS',
         coalesce(public.fx_rate_at('2025-10-17'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'bomba', '2026-02-12', 1, 90137, 'ARS',
         coalesce(public.fx_rate_at('2026-02-12'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'volquete', '2026-04-01', 1, 160000, 'ARS',
         coalesce(public.fx_rate_at('2026-04-01'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'bano quimico', '2026-04-01', 1, 120000, 'ARS',
         coalesce(public.fx_rate_at('2026-04-01'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'materiales sanitarios', '2026-03-12', 1, 111004.08, 'ARS',
         coalesce(public.fx_rate_at('2026-03-12'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'material para molduras', '2026-02-05', 1, 5599, 'ARS',
         coalesce(public.fx_rate_at('2026-02-05'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'materiales sanitarios', '2026-03-12', 1, 7600, 'ARS',
         coalesce(public.fx_rate_at('2026-03-12'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'materiales de obra', '2026-02-03', 1, 43200, 'ARS',
         coalesce(public.fx_rate_at('2026-02-03'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'materiales electricos', '2026-02-03', 1, 5232.27, 'ARS',
         coalesce(public.fx_rate_at('2026-02-03'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pintura', '2026-04-16', 1, 171300, 'ARS',
         coalesce(public.fx_rate_at('2026-04-16'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pintura', '2026-04-28', 1, 420000, 'ARS',
         coalesce(public.fx_rate_at('2026-04-28'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'corralon', '2026-04-28', 1, 2380000, 'ARS',
         coalesce(public.fx_rate_at('2026-04-28'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'membrana techo', '2026-05-27', 1, 390000, 'ARS',
         coalesce(public.fx_rate_at('2026-05-27'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'cocina al 50%', '2026-05-28', 1, 1550000, 'ARS',
         coalesce(public.fx_rate_at('2026-05-28'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pisos grupo gemme', '2026-05-28', 1, 2007596.1, 'ARS',
         coalesce(public.fx_rate_at('2026-05-28'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'Materiales', '2026-05-29', 1, 104000, 'ARS',
         coalesce(public.fx_rate_at('2026-05-29'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'corralon', '2026-06-17', 1, 1180000, 'ARS',
         coalesce(public.fx_rate_at('2026-06-17'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pintura', '2026-06-17', 1, 309000, 'ARS',
         coalesce(public.fx_rate_at('2026-06-17'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'herrero', '2026-06-26', 1, 4000000, 'ARS',
         coalesce(public.fx_rate_at('2026-06-26'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pintura', '2026-06-24', 1, 148000, 'ARS',
         coalesce(public.fx_rate_at('2026-06-24'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'rejilla lineal', '2026-06-26', 1, 40000, 'ARS',
         coalesce(public.fx_rate_at('2026-06-26'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pintura', '2026-07-06', 1, 298400, 'ARS',
         coalesce(public.fx_rate_at('2026-07-06'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'zocalos', '2026-07-16', 1, 115000, 'ARS',
         coalesce(public.fx_rate_at('2026-07-16'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'maderas para pergola', '2026-07-17', 1, 192000, 'ARS',
         coalesce(public.fx_rate_at('2026-07-17'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'materiales electricos', '2026-07-17', 1, 421700, 'ARS',
         coalesce(public.fx_rate_at('2026-07-17'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, '30% de la puerta de entrada', '2026-07-30', 1, 479160, 'ARS',
         coalesce(public.fx_rate_at('2026-07-30'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'vanitory', '2026-07-30', 1, 567250, 'ARS',
         coalesce(public.fx_rate_at('2026-07-30'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'bacha lavadero', '2026-07-30', 1, 46170, 'ARS',
         coalesce(public.fx_rate_at('2026-07-30'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'bacha parrilla', '2026-07-30', 1, 43590, 'ARS',
         coalesce(public.fx_rate_at('2026-07-30'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'lamparas', '2026-07-30', 1, 33125, 'ARS',
         coalesce(public.fx_rate_at('2026-07-30'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'picaportes', '2026-07-30', 1, 72380, 'ARS',
         coalesce(public.fx_rate_at('2026-07-30'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'puerta', '2026-08-05', 1, 840840, 'ARS',
         coalesce(public.fx_rate_at('2026-08-05'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pintura', '2026-08-05', 1, 118000, 'ARS',
         coalesce(public.fx_rate_at('2026-08-05'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'rejillas', '2026-08-14', 1, 23000, 'ARS',
         coalesce(public.fx_rate_at('2026-08-14'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'mat. Sanitarios', '2026-08-21', 1, 547000, 'ARS',
         coalesce(public.fx_rate_at('2026-08-21'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'volquete', '2026-08-21', 1, 140000, 'ARS',
         coalesce(public.fx_rate_at('2026-08-21'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'bano quimico', '2026-08-21', 1, 70000, 'ARS',
         coalesce(public.fx_rate_at('2026-08-21'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'bachas', '2026-08-27', 1, 191000, 'ARS',
         coalesce(public.fx_rate_at('2026-08-27'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'uber', '2026-08-28', 1, 39558, 'ARS',
         coalesce(public.fx_rate_at('2026-08-28'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'eidico', '2026-09-11', 1, 81324, 'ARS',
         coalesce(public.fx_rate_at('2026-09-11'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pintura', '2026-09-11', 1, 135000, 'ARS',
         coalesce(public.fx_rate_at('2026-09-11'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'zingueria', '2026-09-11', 1, 73000, 'ARS',
         coalesce(public.fx_rate_at('2026-09-11'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'edenor junio', '2025-07-04', 1, 19399.75, 'ARS',
         coalesce(public.fx_rate_at('2025-07-04'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Costos indirectos'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Servicios de obra'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'edenor julio', '2025-08-06', 1, 20112.92, 'ARS',
         coalesce(public.fx_rate_at('2025-08-06'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Costos indirectos'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Servicios de obra'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'edenor agosto', '2025-09-11', 1, 16170.52, 'ARS',
         coalesce(public.fx_rate_at('2025-09-11'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Costos indirectos'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Servicios de obra'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'edenor septiembre', '2025-10-21', 1, 39190.16, 'ARS',
         coalesce(public.fx_rate_at('2025-10-21'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Costos indirectos'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Servicios de obra'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'edenor octubre', '2025-12-01', 1, 32223.82, 'ARS',
         coalesce(public.fx_rate_at('2025-12-01'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Costos indirectos'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Servicios de obra'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'edenor', '2026-05-28', 1, 73552.8, 'ARS',
         coalesce(public.fx_rate_at('2026-05-28'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Costos indirectos'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Servicios de obra'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'seguro obra', '2026-07-31', 1, 45028.44, 'ARS',
         coalesce(public.fx_rate_at('2026-07-31'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Costos indirectos'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Servicios de obra'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'seguro obra', '2026-08-07', 1, 45028.44, 'ARS',
         coalesce(public.fx_rate_at('2026-08-07'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Costos indirectos'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Servicios de obra'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago semana 4 de julio', '2025-07-04', 1, 360000, 'ARS',
         coalesce(public.fx_rate_at('2025-07-04'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago semana 11 de julio', '2025-07-11', 1, 360000, 'ARS',
         coalesce(public.fx_rate_at('2025-07-11'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago semana 9 de octubre', '2025-10-09', 1, 1240000, 'ARS',
         coalesce(public.fx_rate_at('2025-10-09'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago semana 17 de octubre', '2025-10-17', 1, 1210000, 'ARS',
         coalesce(public.fx_rate_at('2025-10-17'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago semana 24 de octubre', '2025-10-24', 1, 1360000, 'ARS',
         coalesce(public.fx_rate_at('2025-10-24'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago semana 31 de octubre', '2025-10-31', 1, 1180000, 'ARS',
         coalesce(public.fx_rate_at('2025-10-31'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago semana 7 de noviembre', '2025-11-07', 1, 1405000, 'ARS',
         coalesce(public.fx_rate_at('2025-11-07'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago semana 14 de noviembre', '2025-11-14', 1, 1840000, 'ARS',
         coalesce(public.fx_rate_at('2025-11-14'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago semana 19 de noviembre', '2025-11-19', 1, 890000, 'ARS',
         coalesce(public.fx_rate_at('2025-11-19'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago semana 28 de noviembre', '2025-11-28', 1, 300000, 'ARS',
         coalesce(public.fx_rate_at('2025-11-28'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago semana 5 de diciembre', '2025-12-05', 1, 400000, 'ARS',
         coalesce(public.fx_rate_at('2025-12-05'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago semana 12 de diciembre', '2025-12-12', 1, 400000, 'ARS',
         coalesce(public.fx_rate_at('2025-12-12'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago semana 19 de diciembre', '2025-12-18', 1, 555000, 'ARS',
         coalesce(public.fx_rate_at('2025-12-18'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago semana 26 de diciembre', '2025-12-26', 1, 235000, 'ARS',
         coalesce(public.fx_rate_at('2025-12-26'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago semana 2 de enero', '2026-01-02', 1, 600000, 'ARS',
         coalesce(public.fx_rate_at('2026-01-02'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago semana 9 de enero', '2026-01-09', 1, 1805000, 'ARS',
         coalesce(public.fx_rate_at('2026-01-09'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago semana 16 de enero', '2026-01-16', 1, 1275000, 'ARS',
         coalesce(public.fx_rate_at('2026-01-16'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago semana 23 de enero', '2026-01-23', 1, 1890000, 'ARS',
         coalesce(public.fx_rate_at('2026-01-23'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago semana 30 de enero', '2026-01-30', 1, 2055000, 'ARS',
         coalesce(public.fx_rate_at('2026-01-30'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago semana 6 de febrero', '2026-02-12', 1, 1305000, 'ARS',
         coalesce(public.fx_rate_at('2026-02-12'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago semana 13 de febrero', '2026-02-13', 1, 1570000, 'ARS',
         coalesce(public.fx_rate_at('2026-02-13'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago semana 27 de febrero', '2026-02-27', 1, 1770000, 'ARS',
         coalesce(public.fx_rate_at('2026-02-27'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago semana 3 de marzo', '2026-03-06', 1, 1370000, 'ARS',
         coalesce(public.fx_rate_at('2026-03-06'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago semana 13 de marzo', '2026-03-13', 1, 1310000, 'ARS',
         coalesce(public.fx_rate_at('2026-03-13'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago semana 20 de marzo', '2026-03-20', 1, 1510000, 'ARS',
         coalesce(public.fx_rate_at('2026-03-20'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago semana 27 de marzo', '2026-03-27', 1, 1050000, 'ARS',
         coalesce(public.fx_rate_at('2026-03-27'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago semana 1 de abril', '2026-04-01', 1, 840000, 'ARS',
         coalesce(public.fx_rate_at('2026-04-01'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago semana 10 de abril', '2026-04-10', 1, 1200000, 'ARS',
         coalesce(public.fx_rate_at('2026-04-10'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago semana 17 de abril', '2026-04-17', 1, 1020000, 'ARS',
         coalesce(public.fx_rate_at('2026-04-17'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago semana 24 de abril', '2026-04-24', 1, 1320000, 'ARS',
         coalesce(public.fx_rate_at('2026-04-24'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago semana 30 de abril', '2026-04-30', 1, 1160000, 'ARS',
         coalesce(public.fx_rate_at('2026-04-30'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago semana 7 de mayo', '2026-05-07', 1, 1510000, 'ARS',
         coalesce(public.fx_rate_at('2026-05-07'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago semana 22 de mayo', '2026-05-22', 1, 1510000, 'ARS',
         coalesce(public.fx_rate_at('2026-05-22'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago semana 28 de mayo', '2026-05-29', 1, 1160000, 'ARS',
         coalesce(public.fx_rate_at('2026-05-29'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago semana 5 de junio', '2026-06-05', 1, 1750000, 'ARS',
         coalesce(public.fx_rate_at('2026-06-05'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago semana 12 de junio', '2026-06-12', 1, 1400000, 'ARS',
         coalesce(public.fx_rate_at('2026-06-12'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago semana 19 de junio', '2026-06-19', 1, 1400000, 'ARS',
         coalesce(public.fx_rate_at('2026-06-19'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago semana 26 de junio', '2026-06-26', 1, 1750000, 'ARS',
         coalesce(public.fx_rate_at('2026-06-26'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago semana 3 de julio', '2026-07-03', 1, 1510000, 'ARS',
         coalesce(public.fx_rate_at('2026-07-03'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago semana 10 de julio', '2026-07-10', 1, 930000, 'ARS',
         coalesce(public.fx_rate_at('2026-07-10'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago semana 17 de julio', '2026-07-17', 1, 1335000, 'ARS',
         coalesce(public.fx_rate_at('2026-07-17'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago semana 24 de julio', '2026-07-24', 1, 1690000, 'ARS',
         coalesce(public.fx_rate_at('2026-07-24'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago semana 31 de julio', '2026-07-31', 1, 1455000, 'ARS',
         coalesce(public.fx_rate_at('2026-07-31'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago semana 7 de agosto', '2026-08-07', 1, 1160000, 'ARS',
         coalesce(public.fx_rate_at('2026-08-07'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago semana 14 de agosto', '2026-08-14', 1, 1750000, 'ARS',
         coalesce(public.fx_rate_at('2026-08-14'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago semana 21 de agosto', '2026-08-21', 1, 1750000, 'ARS',
         coalesce(public.fx_rate_at('2026-08-21'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago semana 28 de agosto', '2026-08-28', 1, 1120000, 'ARS',
         coalesce(public.fx_rate_at('2026-08-28'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago semana 4 de septiembre', '2026-09-07', 1, 1535000, 'ARS',
         coalesce(public.fx_rate_at('2026-09-07'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago semana 11 de septiembre', '2026-09-11', 1, 1750000, 'ARS',
         coalesce(public.fx_rate_at('2026-09-11'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'Pago plomero', '2025-08-08', 1, 300000, 'ARS',
         coalesce(public.fx_rate_at('2025-08-08'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'anticipo electricista', '2025-10-22', 1, 2012500, 'ARS',
         coalesce(public.fx_rate_at('2025-10-22'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago electricista', '2026-01-06', 1, 500000, 'ARS',
         coalesce(public.fx_rate_at('2026-01-06'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago dci', '2026-01-06', 1, 280000, 'ARS',
         coalesce(public.fx_rate_at('2026-01-06'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago electricista', '2026-02-06', 1, 200000, 'ARS',
         coalesce(public.fx_rate_at('2026-02-06'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'Pago plomero', '2026-03-06', 1, 500000, 'ARS',
         coalesce(public.fx_rate_at('2026-03-06'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago matriculado de gas', '2026-02-21', 1, 550000, 'ARS',
         coalesce(public.fx_rate_at('2026-02-21'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pag yesero', '2026-05-22', 1, 1200000, 'ARS',
         coalesce(public.fx_rate_at('2026-05-22'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago plomero', '2026-05-22', 1, 800000, 'ARS',
         coalesce(public.fx_rate_at('2026-05-22'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago electricista', '2026-05-22', 1, 600000, 'ARS',
         coalesce(public.fx_rate_at('2026-05-22'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago yesero', '2026-05-28', 1, 860000, 'ARS',
         coalesce(public.fx_rate_at('2026-05-28'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago plomero', '2026-06-12', 1, 400000, 'ARS',
         coalesce(public.fx_rate_at('2026-06-12'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago adelanto pintor', '2026-06-19', 1, 600000, 'ARS',
         coalesce(public.fx_rate_at('2026-06-19'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago adelanto pintor', '2026-06-26', 1, 600000, 'ARS',
         coalesce(public.fx_rate_at('2026-06-26'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago adelanto pintor', '2026-07-03', 1, 800000, 'ARS',
         coalesce(public.fx_rate_at('2026-07-03'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago adelanto pintor', '2026-07-17', 1, 800000, 'ARS',
         coalesce(public.fx_rate_at('2026-07-17'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago adelanto electricista', '2026-07-24', 1, 250000, 'ARS',
         coalesce(public.fx_rate_at('2026-07-24'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'Pago pintor', '2026-07-31', 1, 800000, 'ARS',
         coalesce(public.fx_rate_at('2026-07-31'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'Pago plomero', '2026-08-21', 1, 200000, 'ARS',
         coalesce(public.fx_rate_at('2026-08-21'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago pintor', '2026-08-28', 1, 500000, 'ARS',
         coalesce(public.fx_rate_at('2026-08-28'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago pintot', '2026-09-07', 1, 500000, 'ARS',
         coalesce(public.fx_rate_at('2026-09-07'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR583';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago matriculado de luz', '2026-09-15', 1, 350000, 'ARS',
         coalesce(public.fx_rate_at('2026-09-15'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR583';

-- Gastos diarios lote 84 -> SR084 ------------------
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'Expensas mes noviembre lote 84', '2024-11-07', 1, 268448.17, 'ARS',
         coalesce(public.fx_rate_at('2024-11-07'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Costos indirectos'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Expensas'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'Expensas mes diciembre lote 84', '2024-12-02', 1, 410954.71, 'ARS',
         coalesce(public.fx_rate_at('2024-12-02'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Costos indirectos'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Expensas'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'Expensas mes enero lote 84', '2025-01-09', 1, 337002.1, 'ARS',
         coalesce(public.fx_rate_at('2025-01-09'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Costos indirectos'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Expensas'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'Expensas mes febrero lote 84', '2025-02-06', 1, 126869.02, 'ARS',
         coalesce(public.fx_rate_at('2025-02-06'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Costos indirectos'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Expensas'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'Expensas mes marzo lote 84', '2025-03-10', 1, 242984.88, 'ARS',
         coalesce(public.fx_rate_at('2025-03-10'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Costos indirectos'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Expensas'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'Expensas mes abril lote 84', '2025-04-10', 1, 286868.73, 'ARS',
         coalesce(public.fx_rate_at('2025-04-10'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Costos indirectos'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Expensas'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'Expensas mes mayo lote 84', '2025-05-09', 1, 679204.75, 'ARS',
         coalesce(public.fx_rate_at('2025-05-09'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Costos indirectos'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Expensas'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'Expensas mes junio lote 84', '2025-06-05', 1, 480989.75, 'ARS',
         coalesce(public.fx_rate_at('2025-06-05'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Costos indirectos'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Expensas'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'Expensas mes julio lote 84', '2025-07-04', 1, 478925.8, 'ARS',
         coalesce(public.fx_rate_at('2025-07-04'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Costos indirectos'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Expensas'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'Expensas mes Agosto lote 84', '2025-08-06', 1, 502883.47, 'ARS',
         coalesce(public.fx_rate_at('2025-08-06'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Costos indirectos'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Expensas'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'Expensas mes Septiembre lote 84', '2025-09-11', 1, 615671.58, 'ARS',
         coalesce(public.fx_rate_at('2025-09-11'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Costos indirectos'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Expensas'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'Expensas mes Octubre lote 84', '2025-10-03', 1, 559588.78, 'ARS',
         coalesce(public.fx_rate_at('2025-10-03'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Costos indirectos'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Expensas'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'Expensas mes noviembre lote 84', '2025-11-07', 1, 466557.35, 'ARS',
         coalesce(public.fx_rate_at('2025-11-07'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Costos indirectos'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Expensas'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'Expensas mes diciembre lote 84', '2025-12-03', 1, 532430.91, 'ARS',
         coalesce(public.fx_rate_at('2025-12-03'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Costos indirectos'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Expensas'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'Expensas mes enero lote 84', '2026-01-09', 1, 555668.88, 'ARS',
         coalesce(public.fx_rate_at('2026-01-09'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Costos indirectos'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Expensas'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'Expensas mes febrero lote 84', '2026-02-10', 1, 561204.41, 'ARS',
         coalesce(public.fx_rate_at('2026-02-10'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Costos indirectos'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Expensas'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'Expensas mes marzo lote 84', '2026-03-05', 1, 584574.45, 'ARS',
         coalesce(public.fx_rate_at('2026-03-05'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Costos indirectos'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Expensas'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'Expensas mes abril lote 84', '2026-04-09', 1, 200123.22, 'ARS',
         coalesce(public.fx_rate_at('2026-04-09'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Costos indirectos'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Expensas'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'anticipio honorarios', '2024-11-05', 1, 600000, 'ARS',
         coalesce(public.fx_rate_at('2024-11-05'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Costos indirectos'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gestoría'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'gasto gestoria', '2024-02-12', 1, 2278100, 'ARS',
         coalesce(public.fx_rate_at('2024-02-12'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Costos indirectos'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gestoría'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'gastos gestoria', '2025-01-16', 1, 1493680, 'ARS',
         coalesce(public.fx_rate_at('2025-01-16'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Costos indirectos'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gestoría'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'anticipio honorarios', '2025-02-24', 1, 600000, 'ARS',
         coalesce(public.fx_rate_at('2025-02-24'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Costos indirectos'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gestoría'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'matriculado edenor', '2025-03-13', 1, 177500, 'ARS',
         coalesce(public.fx_rate_at('2025-03-13'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Costos indirectos'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gestoría'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'materiales edenor', '2025-03-13', 1, 71172, 'ARS',
         coalesce(public.fx_rate_at('2025-03-13'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Costos indirectos'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gestoría'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'Matericulado edenor', '2025-04-04', 1, 355000, 'ARS',
         coalesce(public.fx_rate_at('2025-04-04'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Costos indirectos'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gestoría'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'escribania', '2025-08-21', 1, 315000, 'ARS',
         coalesce(public.fx_rate_at('2025-08-21'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Costos indirectos'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gestoría'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'Renders', '2025-01-22', 1, 85000, 'ARS',
         coalesce(public.fx_rate_at('2025-01-22'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Costos indirectos'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Seguros'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'Seguro responsabilidad civil mes marzo 17/03/2025', '2025-03-05', 1, 4298, 'ARS',
         coalesce(public.fx_rate_at('2025-03-05'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Costos indirectos'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Seguros'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'Seguro personal', '2025-05-03', 1, 25719.22, 'ARS',
         coalesce(public.fx_rate_at('2025-05-03'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Costos indirectos'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Seguros'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'Seguro responsabilidad civil mes abril 09/05/2025', '2025-09-05', 1, 4298, 'ARS',
         coalesce(public.fx_rate_at('2025-09-05'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Costos indirectos'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Seguros'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'Seguro personal', '2025-09-05', 1, 40992.28, 'ARS',
         coalesce(public.fx_rate_at('2025-09-05'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Costos indirectos'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Seguros'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'Seguro responsabilidad civil mes mayo 3/06/2025', '2025-03-06', 1, 4298, 'ARS',
         coalesce(public.fx_rate_at('2025-03-06'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Costos indirectos'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Seguros'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'Seguro personal', '2025-03-06', 1, 70179.06999999999, 'ARS',
         coalesce(public.fx_rate_at('2025-03-06'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Costos indirectos'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Seguros'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'Seguro personal', '2025-04-07', 1, 70177.5, 'ARS',
         coalesce(public.fx_rate_at('2025-04-07'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Costos indirectos'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Seguros'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'seguro responsabilidad civil mes junio 04/07/2025', '2025-04-07', 1, 4298, 'ARS',
         coalesce(public.fx_rate_at('2025-04-07'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Costos indirectos'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Seguros'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'Seguro personal', '2025-08-06', 1, 115274.2, 'ARS',
         coalesce(public.fx_rate_at('2025-08-06'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Costos indirectos'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Seguros'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'seguro responsabilidad civil mes julio 6/8/2025', '2025-08-06', 1, 4298, 'ARS',
         coalesce(public.fx_rate_at('2025-08-06'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Costos indirectos'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Seguros'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'Seguro personal', '2025-09-11', 1, 4298, 'ARS',
         coalesce(public.fx_rate_at('2025-09-11'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Costos indirectos'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Seguros'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'seguro responsabilidad civil mes agosto 11/9/2025', '2025-09-11', 1, 115270.7, 'ARS',
         coalesce(public.fx_rate_at('2025-09-11'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Costos indirectos'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Seguros'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'Seguro personal', '2025-10-08', 1, 4298, 'ARS',
         coalesce(public.fx_rate_at('2025-10-08'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Costos indirectos'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Seguros'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'seguro responsabilidad civil mes septiembre 8/10/2025', '2025-10-08', 1, 115269.6, 'ARS',
         coalesce(public.fx_rate_at('2025-10-08'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Costos indirectos'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Seguros'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'Seguro personal', '2025-11-07', 1, 115117.2, 'ARS',
         coalesce(public.fx_rate_at('2025-11-07'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Costos indirectos'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Seguros'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'seguro responsabilidad civil mes octubre 8/10/2025', '2025-11-07', 1, 4298, 'ARS',
         coalesce(public.fx_rate_at('2025-11-07'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Costos indirectos'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Seguros'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'Seguro personal', '2025-12-01', 1, 116228.61, 'ARS',
         coalesce(public.fx_rate_at('2025-12-01'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Costos indirectos'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Seguros'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'seguro responsabilidad civil mes noviembre 8/10/2025', '2025-12-01', 1, 4298, 'ARS',
         coalesce(public.fx_rate_at('2025-12-01'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Costos indirectos'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Seguros'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'Seguro personal', '2026-01-09', 1, 114070.4, 'ARS',
         coalesce(public.fx_rate_at('2026-01-09'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Costos indirectos'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Seguros'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'seguro responsabilidad civil mes diciembre 9/1/2026', '2026-01-09', 1, 4298, 'ARS',
         coalesce(public.fx_rate_at('2026-01-09'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Costos indirectos'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Seguros'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'Seguro personal', '2026-02-09', 1, 102494.63, 'ARS',
         coalesce(public.fx_rate_at('2026-02-09'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Costos indirectos'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Seguros'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'seguro responsabilidad civil mes enero 9/2/2026', '2026-02-09', 1, 4298, 'ARS',
         coalesce(public.fx_rate_at('2026-02-09'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Costos indirectos'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Seguros'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'Seguro personal', '2026-06-03', 1, 102494.9, 'ARS',
         coalesce(public.fx_rate_at('2026-06-03'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Costos indirectos'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Seguros'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'seguro responsabilidad civil mes febreroo 9/2/2026', '2026-06-03', 1, 4302.91, 'ARS',
         coalesce(public.fx_rate_at('2026-06-03'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Costos indirectos'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Seguros'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'Flete', '2025-03-19', 1, 80000, 'ARS',
         coalesce(public.fx_rate_at('2025-03-19'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Tareas preliminares'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'Impresiones planos', '2025-03-20', 1, 3600, 'ARS',
         coalesce(public.fx_rate_at('2025-03-20'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Tareas preliminares'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'Bano quimico', '2025-03-21', 1, 45000, 'ARS',
         coalesce(public.fx_rate_at('2025-03-21'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Tareas preliminares'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'Ferreteria', '2025-03-21', 1, 179000, 'ARS',
         coalesce(public.fx_rate_at('2025-03-21'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Tareas preliminares'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'libreria', '2025-03-21', 1, 18600, 'ARS',
         coalesce(public.fx_rate_at('2025-03-21'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Tareas preliminares'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'ferreteria', '2025-03-21', 1, 11600, 'ARS',
         coalesce(public.fx_rate_at('2025-03-21'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Tareas preliminares'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'maderas ruta 25', '2025-03-21', 1, 94419.91, 'ARS',
         coalesce(public.fx_rate_at('2025-03-21'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Tareas preliminares'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'sanitarios', '2025-03-21', 1, 27250, 'ARS',
         coalesce(public.fx_rate_at('2025-03-21'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Tareas preliminares'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'cartel de obra', '2025-03-21', 1, 21000, 'ARS',
         coalesce(public.fx_rate_at('2025-03-21'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Tareas preliminares'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'Corralon', '2025-03-28', 1, 16256000, 'ARS',
         coalesce(public.fx_rate_at('2025-03-28'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Tareas preliminares'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'Andersen materiales', '2025-03-25', 1, 370266.75, 'ARS',
         coalesce(public.fx_rate_at('2025-03-25'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Tareas preliminares'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'ferreteria', '2025-03-26', 1, 11000, 'ARS',
         coalesce(public.fx_rate_at('2025-03-26'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Tareas preliminares'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'Ferreteria', '2025-03-25', 1, 62700, 'ARS',
         coalesce(public.fx_rate_at('2025-03-25'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Tareas preliminares'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'sanitarios', '2025-03-26', 1, 60000, 'ARS',
         coalesce(public.fx_rate_at('2025-03-26'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Tareas preliminares'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'chapa nort', '2025-03-25', 1, 29600, 'ARS',
         coalesce(public.fx_rate_at('2025-03-25'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Tareas preliminares'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'flete', '2025-03-28', 1, 80000, 'ARS',
         coalesce(public.fx_rate_at('2025-03-28'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Tareas preliminares'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'Ferreteria', '2025-04-04', 1, 12100, 'ARS',
         coalesce(public.fx_rate_at('2025-04-04'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Tareas preliminares'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'Acopio materiales sanitario', '2025-04-04', 1, 2796910, 'ARS',
         coalesce(public.fx_rate_at('2025-04-04'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Tareas preliminares'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'acopio materiales electricos', '2025-04-04', 1, 2235000, 'ARS',
         coalesce(public.fx_rate_at('2025-04-04'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Tareas preliminares'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'Arreglo hormigonera', '2025-03-03', 1, 490000, 'ARS',
         coalesce(public.fx_rate_at('2025-03-03'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Tareas preliminares'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago semana 21 de marzo', '2025-03-21', 1, 615000, 'ARS',
         coalesce(public.fx_rate_at('2025-03-21'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago semana 28 de marzo', '2025-03-28', 1, 495000, 'ARS',
         coalesce(public.fx_rate_at('2025-03-28'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago semana 4 de abril', '2025-04-04', 1, 615000, 'ARS',
         coalesce(public.fx_rate_at('2025-04-04'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago semana 11 de abril', '2025-04-11', 1, 775000, 'ARS',
         coalesce(public.fx_rate_at('2025-04-11'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago semana 16 de abril', '2025-04-16', 1, 670000, 'ARS',
         coalesce(public.fx_rate_at('2025-04-16'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'se le presto 200.000 al pelado', '2025-04-16', 1, 200000, 'ARS',
         coalesce(public.fx_rate_at('2025-04-16'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago semana 25 de abril', '2025-04-25', 1, 1140000, 'ARS',
         coalesce(public.fx_rate_at('2025-04-25'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'Anticipo 50% electricista', '2025-04-29', 1, 1437500, 'ARS',
         coalesce(public.fx_rate_at('2025-04-29'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago semana 30 de abril', '2025-04-30', 1, 570000, 'ARS',
         coalesce(public.fx_rate_at('2025-04-30'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago semana 9 de mayo', '2025-05-09', 1, 350000, 'ARS',
         coalesce(public.fx_rate_at('2025-05-09'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago semana 16 de mayo', '2025-05-16', 1, 1080000, 'ARS',
         coalesce(public.fx_rate_at('2025-05-16'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago semana 23 de mayo', '2025-05-23', 1, 1245000, 'ARS',
         coalesce(public.fx_rate_at('2025-05-23'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago semana 30 de mayo', '2025-05-30', 1, 810000, 'ARS',
         coalesce(public.fx_rate_at('2025-05-30'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago semana 6 de junio', '2025-06-06', 1, 1670000, 'ARS',
         coalesce(public.fx_rate_at('2025-06-06'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago semana 13 de junio', '2025-06-13', 1, 1540000, 'ARS',
         coalesce(public.fx_rate_at('2025-06-13'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago semana 19 de junio', '2025-06-19', 1, 970000, 'ARS',
         coalesce(public.fx_rate_at('2025-06-19'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago semana 27 de junio', '2025-06-27', 1, 1345000, 'ARS',
         coalesce(public.fx_rate_at('2025-06-27'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago semana 4 de julio', '2025-07-04', 1, 1390000, 'ARS',
         coalesce(public.fx_rate_at('2025-07-04'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago semana 11 de julio', '2025-07-11', 1, 1140000, 'ARS',
         coalesce(public.fx_rate_at('2025-07-11'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago semana 18 de julio', '2025-07-18', 1, 1510000, 'ARS',
         coalesce(public.fx_rate_at('2025-07-18'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago semana 25 de julio', '2025-07-25', 1, 1750000, 'ARS',
         coalesce(public.fx_rate_at('2025-07-25'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago semana 1 de agosto', '2025-08-01', 1, 1750000, 'ARS',
         coalesce(public.fx_rate_at('2025-08-01'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago semana 8 de agosto', '2025-08-08', 1, 1550000, 'ARS',
         coalesce(public.fx_rate_at('2025-08-08'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago semana 14 de agosto', '2025-08-14', 1, 1270000, 'ARS',
         coalesce(public.fx_rate_at('2025-08-14'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago semana 22 de agosto', '2025-08-22', 1, 1720000, 'ARS',
         coalesce(public.fx_rate_at('2025-08-22'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago semana 29 de agosto', '2025-08-29', 1, 1600000, 'ARS',
         coalesce(public.fx_rate_at('2025-08-29'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago semana 5 de septiembre', '2025-09-05', 1, 1705000, 'ARS',
         coalesce(public.fx_rate_at('2025-09-05'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago semana 12 de septiembre', '2025-09-12', 1, 1545000, 'ARS',
         coalesce(public.fx_rate_at('2025-09-12'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago semana 19 de septiembre', '2025-09-19', 1, 2025000, 'ARS',
         coalesce(public.fx_rate_at('2025-09-19'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago semana 26 de septiembre', '2025-09-26', 1, 1585000, 'ARS',
         coalesce(public.fx_rate_at('2025-09-26'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago semana 3 de octubre', '2025-10-03', 1, 1945000, 'ARS',
         coalesce(public.fx_rate_at('2025-10-03'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago semana 9 de octubre', '2025-10-09', 1, 490000, 'ARS',
         coalesce(public.fx_rate_at('2025-10-09'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago semana 17 de octubre', '2025-10-17', 1, 965000, 'ARS',
         coalesce(public.fx_rate_at('2025-10-17'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'Pago semana 24 de octubre', '2025-10-24', 1, 675000, 'ARS',
         coalesce(public.fx_rate_at('2025-10-24'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'Pago semana 31 de octubre', '2025-10-31', 1, 440000, 'ARS',
         coalesce(public.fx_rate_at('2025-10-31'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago semana 7 de noviembre', '2025-11-07', 1, 530000, 'ARS',
         coalesce(public.fx_rate_at('2025-11-07'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago semana 14 de noviembre', '2025-11-14', 1, 330000, 'ARS',
         coalesce(public.fx_rate_at('2025-11-14'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago semana 19 de noviembre', '2025-11-19', 1, 1145000, 'ARS',
         coalesce(public.fx_rate_at('2025-11-19'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago semana 28 de noviembre', '2025-11-28', 1, 1610000, 'ARS',
         coalesce(public.fx_rate_at('2025-11-28'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago semana 5 de diciembre', '2025-12-05', 1, 1890000, 'ARS',
         coalesce(public.fx_rate_at('2025-12-05'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago semana 12 de diciembre', '2025-12-12', 1, 1580000, 'ARS',
         coalesce(public.fx_rate_at('2025-12-12'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago semana 19 de diciembre', '2025-12-18', 1, 1700000, 'ARS',
         coalesce(public.fx_rate_at('2025-12-18'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago semana 26 de diciembre', '2025-12-26', 1, 1015000, 'ARS',
         coalesce(public.fx_rate_at('2025-12-26'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago semana 2 de enero', '2026-01-02', 1, 585000, 'ARS',
         coalesce(public.fx_rate_at('2026-01-02'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago semana 9 de enero', '2026-01-09', 1, 475000, 'ARS',
         coalesce(public.fx_rate_at('2026-01-09'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago semana 16 de enero', '2026-01-16', 1, 825000, 'ARS',
         coalesce(public.fx_rate_at('2026-01-16'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago semana 30 de enero', '2026-01-30', 1, 225000, 'ARS',
         coalesce(public.fx_rate_at('2026-01-30'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago semana 6 de febrero', '2026-02-12', 1, 615000, 'ARS',
         coalesce(public.fx_rate_at('2026-02-12'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago semana 13 de febrero', '2026-02-13', 1, 380000, 'ARS',
         coalesce(public.fx_rate_at('2026-02-13'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago semana 20 de febrero', '2026-02-20', 1, 690000, 'ARS',
         coalesce(public.fx_rate_at('2026-02-20'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago semana 3 de marzo', '2026-03-06', 1, 380000, 'ARS',
         coalesce(public.fx_rate_at('2026-03-06'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago Plomero', '2025-06-06', 1, 800000, 'ARS',
         coalesce(public.fx_rate_at('2025-06-06'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago electricista', '2025-07-11', 1, 300000, 'ARS',
         coalesce(public.fx_rate_at('2025-07-11'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago electricista', '2025-07-22', 1, 350000, 'ARS',
         coalesce(public.fx_rate_at('2025-07-22'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago Plomero', '2025-08-01', 1, 900000, 'ARS',
         coalesce(public.fx_rate_at('2025-08-01'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago plomero', '2025-08-08', 1, 600000, 'ARS',
         coalesce(public.fx_rate_at('2025-08-08'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago Plomero', '2025-09-05', 1, 800000, 'ARS',
         coalesce(public.fx_rate_at('2025-09-05'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago Plomero', '2025-09-12', 1, 400000, 'ARS',
         coalesce(public.fx_rate_at('2025-09-12'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago Plomero', '2025-10-03', 1, 700000, 'ARS',
         coalesce(public.fx_rate_at('2025-10-03'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago yesero', '2025-10-17', 1, 700000, 'ARS',
         coalesce(public.fx_rate_at('2025-10-17'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago yesero', '2025-10-24', 1, 680000, 'ARS',
         coalesce(public.fx_rate_at('2025-10-24'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago Plomero', '2025-10-31', 1, 600000, 'ARS',
         coalesce(public.fx_rate_at('2025-10-31'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago electricista', '2025-10-31', 1, 600000, 'ARS',
         coalesce(public.fx_rate_at('2025-10-31'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago pintor', '2025-11-14', 1, 210000, 'ARS',
         coalesce(public.fx_rate_at('2025-11-14'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago pintor', '2025-11-19', 1, 210000, 'ARS',
         coalesce(public.fx_rate_at('2025-11-19'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago pintor', '2026-01-09', 1, 350000, 'ARS',
         coalesce(public.fx_rate_at('2026-01-09'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago pintor', '2025-12-26', 1, 210000, 'ARS',
         coalesce(public.fx_rate_at('2025-12-26'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago pintor', '2026-01-02', 1, 210000, 'ARS',
         coalesce(public.fx_rate_at('2026-01-02'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago pintor', '2026-01-16', 1, 350000, 'ARS',
         coalesce(public.fx_rate_at('2026-01-16'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago pintor', '2026-01-23', 1, 350000, 'ARS',
         coalesce(public.fx_rate_at('2026-01-23'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'herrero', '2026-01-27', 1, 2700000, 'ARS',
         coalesce(public.fx_rate_at('2026-01-27'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago pintor', '2026-02-13', 1, 280000, 'ARS',
         coalesce(public.fx_rate_at('2026-02-13'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago pintor', '2026-02-27', 1, 280000, 'ARS',
         coalesce(public.fx_rate_at('2026-02-27'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Mano de obra'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Jornales'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'Carpinterias Carli', '2025-04-11', 1, 11400000, 'ARS',
         coalesce(public.fx_rate_at('2025-04-11'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'tablero electrico', '2025-04-11', 1, 150000, 'ARS',
         coalesce(public.fx_rate_at('2025-04-11'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pilotes', '2025-04-11', 1, 900000, 'ARS',
         coalesce(public.fx_rate_at('2025-04-11'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'supermercado', '2025-04-11', 1, 65166.43, 'ARS',
         coalesce(public.fx_rate_at('2025-04-11'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'Pentacons', '2025-04-25', 1, 3508070.54, 'ARS',
         coalesce(public.fx_rate_at('2025-04-25'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'bano quimico', '2025-04-30', 1, 45000, 'ARS',
         coalesce(public.fx_rate_at('2025-04-30'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'Puertas', '2025-05-20', 1, 1399000, 'ARS',
         coalesce(public.fx_rate_at('2025-05-20'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'flete', '2025-05-20', 1, 120000, 'ARS',
         coalesce(public.fx_rate_at('2025-05-20'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'impresiones', '2025-05-30', 1, 2300, 'ARS',
         coalesce(public.fx_rate_at('2025-05-30'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'cubre cerco', '2025-06-06', 1, 135000, 'ARS',
         coalesce(public.fx_rate_at('2025-06-06'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'Ferrreteria', '2025-06-19', 1, 22600, 'ARS',
         coalesce(public.fx_rate_at('2025-06-19'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'Ferrreteria', '2025-06-19', 1, 9399.99, 'ARS',
         coalesce(public.fx_rate_at('2025-06-19'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'Ferrreteria', '2025-06-19', 1, 34500, 'ARS',
         coalesce(public.fx_rate_at('2025-06-19'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'Ferrreteria', '2025-06-19', 1, 20400, 'ARS',
         coalesce(public.fx_rate_at('2025-06-19'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'bano quimico', '2025-07-04', 1, 45000, 'ARS',
         coalesce(public.fx_rate_at('2025-07-04'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'Tosca para contrapiso', '2025-07-15', 1, 260000, 'ARS',
         coalesce(public.fx_rate_at('2025-07-15'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'asado', '2025-07-15', 1, 90000, 'ARS',
         coalesce(public.fx_rate_at('2025-07-15'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'Ferrreteria', '2025-07-18', 1, 70600, 'ARS',
         coalesce(public.fx_rate_at('2025-07-18'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, '50% de la cocina', '2025-07-22', 1, 1200000, 'ARS',
         coalesce(public.fx_rate_at('2025-07-22'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'Ferrreteria', '2025-07-22', 1, 1900, 'ARS',
         coalesce(public.fx_rate_at('2025-07-22'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'Tosca para contrapiso', '2025-07-24', 1, 130000, 'ARS',
         coalesce(public.fx_rate_at('2025-07-24'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'Cambio de colector', '2025-08-14', 1, 64600, 'ARS',
         coalesce(public.fx_rate_at('2025-08-14'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'Compra de pisos', '2025-08-14', 1, 1221120, 'ARS',
         coalesce(public.fx_rate_at('2025-08-14'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'gasista', '2025-08-21', 1, 550000, 'ARS',
         coalesce(public.fx_rate_at('2025-08-21'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'cajas preinstalacion aires', '2025-09-29', 1, 6000, 'ARS',
         coalesce(public.fx_rate_at('2025-09-29'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'cano calefaccion 400ml y otros', '2025-09-03', 1, 381000, 'ARS',
         coalesce(public.fx_rate_at('2025-09-03'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'bano quimico', '2025-09-04', 1, 50000, 'ARS',
         coalesce(public.fx_rate_at('2025-09-04'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'Precintos', '2025-09-05', 1, 16000, 'ARS',
         coalesce(public.fx_rate_at('2025-09-05'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'Sierra circular p/madera', '2025-09-11', 1, 13028, 'ARS',
         coalesce(public.fx_rate_at('2025-09-11'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'bano quimico', '2025-09-17', 1, 50000, 'ARS',
         coalesce(public.fx_rate_at('2025-09-17'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'buje - abelson', '2025-08-10', 1, 3713.3, 'ARS',
         coalesce(public.fx_rate_at('2025-08-10'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'Ferrreteria', '2025-08-13', 1, 32500, 'ARS',
         coalesce(public.fx_rate_at('2025-08-13'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'Cambio de losa radiante', '2025-08-14', 1, 64612.4, 'ARS',
         coalesce(public.fx_rate_at('2025-08-14'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago herrero 100%', '2025-08-28', 1, 3150000, 'ARS',
         coalesce(public.fx_rate_at('2025-08-28'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'Corralon de materiales', '2025-09-29', 1, 14400, 'ARS',
         coalesce(public.fx_rate_at('2025-09-29'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'electro pilarr', '2025-09-30', 1, 219244.72, 'ARS',
         coalesce(public.fx_rate_at('2025-09-30'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'gastos impresiones', '2025-08-25', 1, 6930, 'ARS',
         coalesce(public.fx_rate_at('2025-08-25'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'bano quimico', '2025-10-22', 1, 60000, 'ARS',
         coalesce(public.fx_rate_at('2025-10-22'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'herrajes', '2025-11-11', 1, 80241, 'ARS',
         coalesce(public.fx_rate_at('2025-11-11'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'bacha parrilla', '2025-11-11', 1, 88591, 'ARS',
         coalesce(public.fx_rate_at('2025-11-11'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'bacha lavadero', '2025-11-11', 1, 84854, 'ARS',
         coalesce(public.fx_rate_at('2025-11-11'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, '50% de mesadas', '2025-11-25', 1, 1130000, 'ARS',
         coalesce(public.fx_rate_at('2025-11-25'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'PINTURA GENERAL', '2025-11-26', 1, 2373213.35, 'ARS',
         coalesce(public.fx_rate_at('2025-11-26'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'Corralon de materiales', '2025-10-24', 1, 11000, 'ARS',
         coalesce(public.fx_rate_at('2025-10-24'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'materiales electricos', '2025-10-29', 1, 104870.25, 'ARS',
         coalesce(public.fx_rate_at('2025-10-29'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'materiales sanitarios restantes', '2025-10-23', 1, 295044.3, 'ARS',
         coalesce(public.fx_rate_at('2025-10-23'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'yeso', '2025-11-14', 1, 74008.62, 'ARS',
         coalesce(public.fx_rate_at('2025-11-14'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'ferreteria', '2025-10-29', 1, 13043.32, 'ARS',
         coalesce(public.fx_rate_at('2025-10-29'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'Puerta', '2025-12-04', 1, 1220000, 'ARS',
         coalesce(public.fx_rate_at('2025-12-04'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, '50% de la cocina', '2025-12-11', 1, 1200000, 'ARS',
         coalesce(public.fx_rate_at('2025-12-11'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'adicional para griferias banos', '2025-12-12', 1, 81075, 'ARS',
         coalesce(public.fx_rate_at('2025-12-12'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago final de edenor dci', '2026-01-06', 1, 280000, 'ARS',
         coalesce(public.fx_rate_at('2026-01-06'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pago 50% mesadas', '2026-01-06', 1, 434034, 'ARS',
         coalesce(public.fx_rate_at('2026-01-06'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'pintura', '2026-01-09', 1, 118000, 'ARS',
         coalesce(public.fx_rate_at('2026-01-09'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'spots', '2026-01-16', 1, 24673, 'ARS',
         coalesce(public.fx_rate_at('2026-01-16'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'flete', '2026-01-16', 1, 80000, 'ARS',
         coalesce(public.fx_rate_at('2026-01-16'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'zocalos + contramarcos', '2026-01-16', 1, 495000, 'ARS',
         coalesce(public.fx_rate_at('2026-01-16'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'gastos electricos pendientes', '2026-01-27', 1, 46500, 'ARS',
         coalesce(public.fx_rate_at('2026-01-27'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'terminacion sanitarios', '2026-01-27', 1, 409413.38, 'ARS',
         coalesce(public.fx_rate_at('2026-01-27'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'conductos', '2026-01-28', 1, 1480000, 'ARS',
         coalesce(public.fx_rate_at('2026-01-28'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'tejuelas', '2026-02-10', 1, 58391.28, 'ARS',
         coalesce(public.fx_rate_at('2026-02-10'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'bomba', '2026-02-12', 1, 90137, 'ARS',
         coalesce(public.fx_rate_at('2026-02-12'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'Microcemento', '2025-02-18', 1, 419000, 'ARS',
         coalesce(public.fx_rate_at('2025-02-18'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'Maderas pergola', '2025-02-18', 1, 175663, 'ARS',
         coalesce(public.fx_rate_at('2025-02-18'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'artefactos de luz', '2026-03-13', 1, 87000, 'ARS',
         coalesce(public.fx_rate_at('2026-03-13'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'Colocacion de artefactos de lu', '2026-03-25', 1, 150000, 'ARS',
         coalesce(public.fx_rate_at('2026-03-25'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Varios'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Gastos de obra'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'Edenor mayo', '2025-03-06', 1, 52947.35, 'ARS',
         coalesce(public.fx_rate_at('2025-03-06'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Costos indirectos'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Servicios de obra'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'Edenor julio', '2025-08-06', 1, 24336, 'ARS',
         coalesce(public.fx_rate_at('2025-08-06'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Costos indirectos'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Servicios de obra'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'Edenor agosto', '2025-09-11', 1, 24860.82, 'ARS',
         coalesce(public.fx_rate_at('2025-09-11'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Costos indirectos'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Servicios de obra'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'Edenor Septiembre', '2025-09-29', 1, 26868, 'ARS',
         coalesce(public.fx_rate_at('2025-09-29'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Costos indirectos'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Servicios de obra'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'edenor octubre', '2025-11-07', 1, 28294.69, 'ARS',
         coalesce(public.fx_rate_at('2025-11-07'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Costos indirectos'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Servicios de obra'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'edenor noviembre', '2025-12-01', 1, 42120.03, 'ARS',
         coalesce(public.fx_rate_at('2025-12-01'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Costos indirectos'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Servicios de obra'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'edenor diciembre', '2026-02-05', 1, 34369.27, 'ARS',
         coalesce(public.fx_rate_at('2026-02-05'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Costos indirectos'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Servicios de obra'
  where pr.code = 'SR084';
insert into public.expenses (project_id, category_id, description,
       expense_date, qty, unit_price, currency, fx_usd, status)
  select pr.id, s.id, 'edenor enero', '2026-03-09', 1, 9222.96, 'ARS',
         coalesce(public.fx_rate_at('2026-03-09'), 1200), 'pagado'
  from public.projects pr
  join public.cost_categories p on p.parent_id is null and p.name = 'Costos indirectos'
  join public.cost_categories s on s.parent_id = p.id and s.name = 'Servicios de obra'
  where pr.code = 'SR084';

commit;