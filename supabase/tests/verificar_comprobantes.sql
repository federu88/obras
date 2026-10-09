-- =============================================================================
-- verificar_comprobantes.sql
--
-- Verificacion de 0030 y 0031: guardar_comprobante, los controles de total,
-- los reportes y la RLS. El proyecto no tiene tests automaticos; esto es lo
-- que hace las veces.
--
-- Se corre entero en el SQL Editor de Supabase (o con psql) DESPUES de aplicar
-- las migraciones. Arma sus propios datos dentro de una transaccion y la
-- deshace al final: no deja nada en la base. Si algo falla, corta con el
-- mensaje de que fue; si todo esta bien, termina con "verificación OK".
-- =============================================================================

begin;

-- --- Datos de prueba (como postgres) -----------------------------------------
insert into auth.users (id, email) values
  ('0e570000-0000-0000-0000-0000000000a1', 'verif-admin@boceto.test'),
  ('0e570000-0000-0000-0000-0000000000b2', 'verif-inversor@boceto.test');

-- El segundo usuario es un inversor sin acceso a la obra de prueba.
update public.profiles set role = 'admin'
where id = '0e570000-0000-0000-0000-0000000000a1';
update public.profiles set role = 'investor'
where id = '0e570000-0000-0000-0000-0000000000b2';

insert into public.projects (id, code, name, status) values
  ('0e570000-0000-0000-0000-000000000001', 'VERIF-A', 'Obra de verificación A', 'en_construccion'),
  ('0e570000-0000-0000-0000-000000000002', 'VERIF-B', 'Obra de verificación B', 'en_construccion');

-- --- Como el administrador ---------------------------------------------------
set local role authenticated;
set local request.jwt.claim.sub = '0e570000-0000-0000-0000-0000000000a1';

do $$
declare
  a        constant uuid := '0e570000-0000-0000-0000-000000000001';
  b        constant uuid := '0e570000-0000-0000-0000-000000000002';
  estr     uuid;
  mamp     uuid;
  rubro_b  uuid;
  rec      uuid;
  linea    uuid;
  q        text;
  motivo   text;
begin
  -- Las obras nuevas nacen con sus rubros.
  assert (select count(*) from project_rubros where project_id = a) = 21,
    'una obra nueva tiene que recibir los 21 rubros base';

  select id into estr    from project_rubros where project_id = a and name = 'Estructura';
  select id into mamp    from project_rubros where project_id = a and name = 'Mampostería';
  select id into rubro_b from project_rubros where project_id = b and name = 'Estructura';

  -- 1. Un comprobante con dos lineas en rubros distintos, desglose y mano de obra.
  rec := guardar_comprobante(
    jsonb_build_object(
      'project_id', a, 'receipt_date', '2026-08-01', 'total', 100000,
      'currency', 'ARS', 'fx_usd', 1000, 'supplier_name', 'Corralón Verif',
      'number', 'A-0001-123', 'payment_method', 'transferencia'),
    jsonb_build_array(
      jsonb_build_object('project_rubro_id', estr, 'cost_type', 'materiales', 'amount', 60000,
        'items', jsonb_build_array(
          jsonb_build_object('description', 'Hierro del 8', 'qty', 20, 'unit', 'barra', 'unit_price', 2000),
          jsonb_build_object('description', 'Cemento', 'qty', 4, 'unit', 'bolsa', 'unit_price', 5000))),
      jsonb_build_object('project_rubro_id', mamp, 'cost_type', 'mano_de_obra', 'amount', 30000,
        'labor', jsonb_build_object('modality', 'jornal', 'worker', 'Cuadrilla Verif',
                                    'progress_pct', 0.4, 'is_advance', false))));

  assert (select count(*) from expenses where receipt_id = rec) = 2, 'tienen que quedar 2 líneas';
  assert (select sin_asignar from receipt_balance where receipt_id = rec) = 10000,
    'un comprobante de 100.000 con 90.000 asignados deja 10.000 sin asignar';
  assert (select count(*) from expense_items ei join expenses e on e.id = ei.expense_id
          where e.receipt_id = rec) = 2, 'el desglose tiene que guardar 2 ítems';
  assert (select amount_usd from expenses where receipt_id = rec and project_rubro_id = estr) = 60,
    'la línea hereda moneda y cotización: 60.000 ARS a 1.000 son 60 USD';
  assert (select status from expenses where receipt_id = rec limit 1) = 'pagado',
    'por defecto el comprobante es un gasto pagado';

  -- 2. Lo que tiene que rechazar.
  -- Cada caso dice que tiene que fallar Y por que: un error de tipeo en el
  -- test tambien "falla", y no prueba nada.
  for q, motivo in
    select * from (values
      (format($q$select guardar_comprobante('{"project_id":"%s","total":100,"currency":"USD"}',
              '[{"project_rubro_id":"%s","amount":120}]')$q$, a, estr),
       'Las líneas suman 120 y el comprobante es por 100'),
      (format($q$select guardar_comprobante('{"project_id":"%s","total":100,"currency":"USD"}',
              '[{"project_rubro_id":"%s","amount":50}]')$q$, a, rubro_b),
       'no es de esta obra'),
      (format($q$select guardar_comprobante('{"project_id":"%s","total":100,"currency":"USD"}',
              '[{"project_rubro_id":"%s","cost_type":"materiales","amount":50,
                 "labor":{"modality":"jornal","worker":"X"}}]')$q$, a, estr),
       'va solo en líneas de mano de obra'),
      (format($q$select guardar_comprobante('{"project_id":"%s","total":100,"currency":"USD"}', '[]')$q$, a),
       'al menos una línea'),
      (format($q$update receipts set total = 50000 where id = '%s'$q$, rec),
       'No pueden pasarse del total'),
      (format($q$update expenses set unit_price = 80000 where receipt_id = '%s' and project_rubro_id = '%s'$q$, rec, mamp),
       'No pueden pasarse del total'),
      (format($q$update expenses set project_rubro_id = '%s' where receipt_id = '%s' and project_rubro_id = '%s'$q$, rubro_b, rec, mamp),
       'expenses_rubro_misma_obra')
    ) as casos(q, motivo)
  loop
    begin
      execute q;
      raise exception 'NO FALLÓ y debía fallar: %', q;
    exception when others then
      if sqlerrm like 'NO FALLÓ%' then raise; end if;
      if position(motivo in sqlerrm) = 0 then
        raise exception 'Falló por otro motivo. Se esperaba "%", vino "%". Caso: %', motivo, sqlerrm, q;
      end if;
    end;
  end loop;

  -- Bajar el total sin pasarse de lo asignado si se puede.
  update receipts set total = 95000 where id = rec;
  update receipts set total = 100000 where id = rec;

  -- Si el comprobante cuadra con lo que falta, se acepta.
  update expenses set unit_price = 40000 where receipt_id = rec and project_rubro_id = mamp;
  assert (select sin_asignar from receipt_balance where receipt_id = rec) = 0, 'ahora tiene que cuadrar';

  -- 3. Cambiar la cotizacion del comprobante cambia la de sus lineas.
  update receipts set fx_usd = 1250 where id = rec;
  assert (select amount_usd from expenses where receipt_id = rec and project_rubro_id = estr) = 48,
    'con la cotización nueva la línea de 60.000 ARS vale 48 USD';

  -- 4. El desglose se reemplaza entero.
  select id into linea from expenses where receipt_id = rec and project_rubro_id = estr;
  assert guardar_items_linea(linea, '[{"description":"Hierro del 10","qty":10,"unit":"barra","unit_price":6000},
                                      {"description":"  "}]') = 1,
    'guardar_items_linea ignora las filas vacías';
  assert (select count(*) from expense_items where expense_id = linea) = 1, 'el desglose viejo se reemplaza';
  assert exists (select 1 from expense_item_suggestions where description = 'Hierro del 10' and origen = 'historial'),
    'lo escrito a mano aparece para autocompletar';

  -- 5. Avance de mano de obra por trabajador.
  perform guardar_comprobante(
    jsonb_build_object('project_id', a, 'receipt_date', '2026-08-15', 'total', 200, 'currency', 'USD'),
    jsonb_build_array(jsonb_build_object('project_rubro_id', mamp, 'cost_type', 'mano_de_obra', 'amount', 200,
      'labor', jsonb_build_object('modality', 'jornal', 'worker', 'cuadrilla verif',
                                  'progress_pct', 0.7, 'is_advance', true))));

  assert (select pagos from labor_payments where project_id = a) = 2,
    'los pagos al mismo trabajador se agrupan aunque cambie la mayúscula';
  assert (select ultimo_avance from labor_payments where project_id = a) = 0.7, 'vale el último avance';
  assert (select adelantos_usd from labor_payments where project_id = a) = 200, 'el adelanto se separa';

  -- 6. Reportes cruzados.
  assert (select actual_usd from rubro_cost_type_totals
          where project_id = a and project_rubro_id = mamp and cost_type = 'mano_de_obra') = 232,
    'mampostería / mano de obra: 40.000 ARS a 1.250 (32) + 200 USD';
  assert (select actual_usd from cost_type_totals where project_id = a and cost_type = 'materiales') = 48,
    'materiales de la obra A';
  assert (select actual_usd from rubro_totals where project_rubro_id = estr) = 48, 'total del rubro Estructura';

  -- 7. Borrar lineas: el comprobante sigue mientras le quede una, y se va con la ultima.
  rec := guardar_comprobante(
    jsonb_build_object('project_id', a, 'total', 30, 'currency', 'USD'),
    jsonb_build_array(
      jsonb_build_object('project_rubro_id', estr, 'amount', 10),
      jsonb_build_object('project_rubro_id', mamp, 'amount', 20)));
  delete from expenses where receipt_id = rec and project_rubro_id = estr;
  assert exists (select 1 from receipts where id = rec), 'con una línea viva el comprobante sigue';
  delete from expenses where receipt_id = rec;
  assert not exists (select 1 from receipts where id = rec), 'sin líneas el comprobante se borra';

  raise notice 'Administrador: OK';
end $$;

-- --- Como un inversor sin acceso a la obra -----------------------------------
set local request.jwt.claim.sub = '0e570000-0000-0000-0000-0000000000b2';

do $$
declare
  a constant uuid := '0e570000-0000-0000-0000-000000000001';
begin
  assert (select count(*) from receipts where project_id = a) = 0,
    'un usuario sin acceso no ve los comprobantes de la obra';
  assert (select count(*) from project_rubros where project_id = a) = 0,
    'ni sus rubros';
  assert (select count(*) from labor_payments where project_id = a) = 0,
    'ni los pagos de mano de obra';

  begin
    perform guardar_comprobante(
      jsonb_build_object('project_id', a, 'total', 10, 'currency', 'USD'),
      jsonb_build_array(jsonb_build_object('project_rubro_id', gen_random_uuid(), 'amount', 10)));
    raise exception 'NO FALLÓ: un usuario sin acceso pudo cargar un comprobante';
  exception when others then
    if sqlerrm like 'NO FALLÓ%' then raise; end if;
    if position('row-level security' in sqlerrm) = 0 then
      raise exception 'Falló por otro motivo que la RLS: %', sqlerrm;
    end if;
  end;

  raise notice 'Inversor sin acceso: OK';
end $$;

reset role;
select 'verificación OK' as resultado;

rollback;
