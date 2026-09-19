-- ===========================================================================
-- Reparto de utilidades de SR084 y SR583
-- Generado el 2026-09-19 desde las dos planillas de REPARTO UTILIDAD.
-- Correr UNA SOLA VEZ, después de 0020_conciliacion.sql.
--
-- Criterio de reparto: PROPORCIONAL AL APORTE, como se definió.
-- En SR084 la planilla dividía por 236.680 (que incluye el lote) pero solo
-- repartía entre los cinco socios, y por eso quedaban 3.760 sin asignar. Acá
-- se usa la base de socios que la propia planilla declara: 208.305.
-- ===========================================================================

begin;

-- 1. Inversores -------------------------------------------------------------
insert into public.investors (name, joined_on)
  select 'Ale / Dani', date '2024-10-07'
  where not exists (select 1 from public.investors where name = 'Ale / Dani');
insert into public.investors (name, joined_on)
  select 'Miguel', date '2024-10-07'
  where not exists (select 1 from public.investors where name = 'Miguel');
insert into public.investors (name, joined_on)
  select 'Fede', date '2024-10-07'
  where not exists (select 1 from public.investors where name = 'Fede');
insert into public.investors (name, joined_on)
  select 'Gonzalo', date '2024-10-07'
  where not exists (select 1 from public.investors where name = 'Gonzalo');
insert into public.investors (name, joined_on)
  select 'Joaco', date '2024-10-07'
  where not exists (select 1 from public.investors where name = 'Joaco');

-- 2. Aportes de capital, imputados a SR084 (la primera casa del pool) --------
-- Se cargan UNA sola vez: el pool financió las dos casas, y cargarlos otra
-- vez contra SR583 los contaría doble.
insert into public.capital_movements
       (type, investor_id, project_id, movement_date, amount, currency, concept)
  select 'aporte', i.id, p.id, date '2024-10-07', 41070, 'USD', 'Compra del lote 84 · fecha de la planilla'
  from public.investors i, public.projects p
  where i.name = 'Ale / Dani' and p.code = 'SR084';
insert into public.capital_movements
       (type, investor_id, project_id, movement_date, amount, currency, concept)
  select 'aporte', i.id, p.id, date '2025-03-20', 6500, 'USD', 'fecha de la planilla'
  from public.investors i, public.projects p
  where i.name = 'Ale / Dani' and p.code = 'SR084';
insert into public.capital_movements
       (type, investor_id, project_id, movement_date, amount, currency, concept)
  select 'aporte', i.id, p.id, date '2025-03-28', 30000, 'USD', 'fecha de la planilla'
  from public.investors i, public.projects p
  where i.name = 'Ale / Dani' and p.code = 'SR084';
insert into public.capital_movements
       (type, investor_id, project_id, movement_date, amount, currency, concept)
  select 'aporte', i.id, p.id, date '2025-05-26', 15000, 'USD', 'fecha de la planilla'
  from public.investors i, public.projects p
  where i.name = 'Ale / Dani' and p.code = 'SR084';
insert into public.capital_movements
       (type, investor_id, project_id, movement_date, amount, currency, concept)
  select 'aporte', i.id, p.id, date '2025-07-05', 20000, 'USD', 'fecha de la planilla'
  from public.investors i, public.projects p
  where i.name = 'Ale / Dani' and p.code = 'SR084';
insert into public.capital_movements
       (type, investor_id, project_id, movement_date, amount, currency, concept)
  select 'aporte', i.id, p.id, date '2025-07-16', 7000, 'USD', 'Entregados a Mariu · fecha de la planilla'
  from public.investors i, public.projects p
  where i.name = 'Ale / Dani' and p.code = 'SR084';
insert into public.capital_movements
       (type, investor_id, project_id, movement_date, amount, currency, concept)
  select 'aporte', i.id, p.id, date '2025-07-30', 2625, 'USD', 'Aportes adicionales netos del lote San Ramón · fecha estimada: no consta en la planilla'
  from public.investors i, public.projects p
  where i.name = 'Ale / Dani' and p.code = 'SR084';
insert into public.capital_movements
       (type, investor_id, project_id, movement_date, amount, currency, concept)
  select 'aporte', i.id, p.id, date '2024-10-18', 18000, 'USD', 'fecha estimada: no consta en la planilla'
  from public.investors i, public.projects p
  where i.name = 'Miguel' and p.code = 'SR084';
insert into public.capital_movements
       (type, investor_id, project_id, movement_date, amount, currency, concept)
  select 'aporte', i.id, p.id, date '2024-10-18', 23110, 'USD', 'fecha estimada: no consta en la planilla'
  from public.investors i, public.projects p
  where i.name = 'Fede' and p.code = 'SR084';
insert into public.capital_movements
       (type, investor_id, project_id, movement_date, amount, currency, concept)
  select 'aporte', i.id, p.id, date '2025-07-30', 15000, 'USD', 'Aporte adicional · fecha estimada: no consta en la planilla'
  from public.investors i, public.projects p
  where i.name = 'Fede' and p.code = 'SR084';
insert into public.capital_movements
       (type, investor_id, project_id, movement_date, amount, currency, concept)
  select 'aporte', i.id, p.id, date '2024-10-18', 10000, 'USD', 'fecha estimada: no consta en la planilla'
  from public.investors i, public.projects p
  where i.name = 'Gonzalo' and p.code = 'SR084';
insert into public.capital_movements
       (type, investor_id, project_id, movement_date, amount, currency, concept)
  select 'aporte', i.id, p.id, date '2024-10-18', 11000, 'USD', 'fecha estimada: no consta en la planilla'
  from public.investors i, public.projects p
  where i.name = 'Joaco' and p.code = 'SR084';
insert into public.capital_movements
       (type, investor_id, project_id, movement_date, amount, currency, concept)
  select 'aporte', i.id, p.id, date '2025-07-30', 9000, 'USD', 'Aporte adicional · fecha estimada: no consta en la planilla'
  from public.investors i, public.projects p
  where i.name = 'Joaco' and p.code = 'SR084';

-- 3. Venta de cada casa -----------------------------------------------------
insert into public.revenues (project_id, kind, description, revenue_date, amount, currency)
  select p.id, 'venta', 'Venta según REPARTO UTILIDAD CASAS SR084.xlsx', date '2025-07-30', 185000, 'USD'
  from public.projects p where p.code = 'SR084';
insert into public.revenues (project_id, kind, description, revenue_date, amount, currency)
  select p.id, 'venta', 'Venta según REPARTO UTILIDAD CASAS SR583.xlsx', date '2026-01-15', 185000, 'USD'
  from public.projects p where p.code = 'SR583';

-- 4. Reinversión de SR084 en SR583 ------------------------------------------
-- Va como transferencia entre proyectos porque es plata del pool, no de un
-- inversor en particular.
insert into public.capital_movements
       (type, from_project_id, project_id, movement_date, amount, currency, concept)
  select 'transferencia', o.id, d.id, date '2025-07-30', 28375, 'USD', 'Recuperado de la venta de SR084 y puesto en SR583 (el lote San Ramón del cuadro)'
  from public.projects o, public.projects d
  where o.code = 'SR084' and d.code = 'SR583';

-- 5. Utilidad asignada a cada inversor --------------------------------------
-- SR084 · base de socios 208,305 · utilidad 31,362.61
insert into public.capital_movements
       (type, investor_id, project_id, movement_date, amount, currency, concept)
  select 'profit_asignado', i.id, p.id, date '2025-07-30', 18397.8, 'USD', 'Participación 58.66% sobre aporte de 122,195'
  from public.investors i, public.projects p
  where i.name = 'Ale / Dani' and p.code = 'SR084';
insert into public.capital_movements
       (type, investor_id, project_id, movement_date, amount, currency, concept)
  select 'profit_asignado', i.id, p.id, date '2025-07-30', 2710.1, 'USD', 'Participación 8.64% sobre aporte de 18,000'
  from public.investors i, public.projects p
  where i.name = 'Miguel' and p.code = 'SR084';
insert into public.capital_movements
       (type, investor_id, project_id, movement_date, amount, currency, concept)
  select 'profit_asignado', i.id, p.id, date '2025-07-30', 5737.88, 'USD', 'Participación 18.30% sobre aporte de 38,110'
  from public.investors i, public.projects p
  where i.name = 'Fede' and p.code = 'SR084';
insert into public.capital_movements
       (type, investor_id, project_id, movement_date, amount, currency, concept)
  select 'profit_asignado', i.id, p.id, date '2025-07-30', 1505.61, 'USD', 'Participación 4.80% sobre aporte de 10,000'
  from public.investors i, public.projects p
  where i.name = 'Gonzalo' and p.code = 'SR084';
insert into public.capital_movements
       (type, investor_id, project_id, movement_date, amount, currency, concept)
  select 'profit_asignado', i.id, p.id, date '2025-07-30', 3011.22, 'USD', 'Participación 9.60% sobre aporte de 20,000'
  from public.investors i, public.projects p
  where i.name = 'Joaco' and p.code = 'SR084';

-- SR583 · base de socios 181,680 · utilidad 42,530.00
insert into public.capital_movements
       (type, investor_id, project_id, movement_date, amount, currency, concept)
  select 'profit_asignado', i.id, p.id, date '2026-01-15', 27990.49, 'USD', 'Participación 65.81% sobre aporte de 119,570'
  from public.investors i, public.projects p
  where i.name = 'Ale / Dani' and p.code = 'SR583';
insert into public.capital_movements
       (type, investor_id, project_id, movement_date, amount, currency, concept)
  select 'profit_asignado', i.id, p.id, date '2026-01-15', 4213.67, 'USD', 'Participación 9.91% sobre aporte de 18,000'
  from public.investors i, public.projects p
  where i.name = 'Miguel' and p.code = 'SR583';
insert into public.capital_movements
       (type, investor_id, project_id, movement_date, amount, currency, concept)
  select 'profit_asignado', i.id, p.id, date '2026-01-15', 5409.89, 'USD', 'Participación 12.72% sobre aporte de 23,110'
  from public.investors i, public.projects p
  where i.name = 'Fede' and p.code = 'SR583';
insert into public.capital_movements
       (type, investor_id, project_id, movement_date, amount, currency, concept)
  select 'profit_asignado', i.id, p.id, date '2026-01-15', 2340.93, 'USD', 'Participación 5.50% sobre aporte de 10,000'
  from public.investors i, public.projects p
  where i.name = 'Gonzalo' and p.code = 'SR583';
insert into public.capital_movements
       (type, investor_id, project_id, movement_date, amount, currency, concept)
  select 'profit_asignado', i.id, p.id, date '2026-01-15', 2575.02, 'USD', 'Participación 6.05% sobre aporte de 11,000'
  from public.investors i, public.projects p
  where i.name = 'Joaco' and p.code = 'SR583';

-- 6. Valores de referencia de las planillas, para la conciliación -----------
insert into public.project_references
       (project_id, concepto, valor_usd, fuente, reference_date, note)
  select p.id, 'capital_aportado', 208305, 'REPARTO UTILIDAD CASAS SR084.xlsx', date '2025-07-30', 'Aporte de socios del cuadro'
  from public.projects p where p.code = 'SR084';
insert into public.project_references
       (project_id, concepto, valor_usd, fuente, reference_date, note)
  select p.id, 'costo_total', 149012.39, 'REPARTO UTILIDAD CASAS SR084.xlsx', date '2025-07-30', 'Costo estimado casa terminada'
  from public.projects p where p.code = 'SR084';
insert into public.project_references
       (project_id, concepto, valor_usd, fuente, reference_date, note)
  select p.id, 'venta', 185000, 'REPARTO UTILIDAD CASAS SR084.xlsx', date '2025-07-30', 'Venta bruta (comisión 2.5%)'
  from public.projects p where p.code = 'SR084';
insert into public.project_references
       (project_id, concepto, valor_usd, fuente, reference_date, note)
  select p.id, 'utilidad', 31362.61, 'REPARTO UTILIDAD CASAS SR084.xlsx', date '2025-07-30', 'Utilidad total del cuadro'
  from public.projects p where p.code = 'SR084';

insert into public.project_references
       (project_id, concepto, valor_usd, fuente, reference_date, note)
  select p.id, 'capital_aportado', 181680, 'REPARTO UTILIDAD CASAS SR583.xlsx', date '2026-01-15', 'Aporte de socios del cuadro'
  from public.projects p where p.code = 'SR583';
insert into public.project_references
       (project_id, concepto, valor_usd, fuente, reference_date, note)
  select p.id, 'costo_total', 135070.0, 'REPARTO UTILIDAD CASAS SR583.xlsx', date '2026-01-15', 'Costo estimado casa terminada'
  from public.projects p where p.code = 'SR583';
insert into public.project_references
       (project_id, concepto, valor_usd, fuente, reference_date, note)
  select p.id, 'venta', 185000, 'REPARTO UTILIDAD CASAS SR583.xlsx', date '2026-01-15', 'Venta bruta (comisión 4.0%)'
  from public.projects p where p.code = 'SR583';
insert into public.project_references
       (project_id, concepto, valor_usd, fuente, reference_date, note)
  select p.id, 'utilidad', 42530.0, 'REPARTO UTILIDAD CASAS SR583.xlsx', date '2026-01-15', 'Utilidad total del cuadro'
  from public.projects p where p.code = 'SR583';

-- 7. Comisión inmobiliaria de cada casa, según su planilla ------------------
update public.projects set broker_fee_pct = 0.025, target_sale_usd = 185000
  where code = 'SR084';
update public.projects set broker_fee_pct = 0.04, target_sale_usd = 185000
  where code = 'SR583';

commit;