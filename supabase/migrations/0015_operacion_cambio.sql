-- =============================================================================
-- 0015_operacion_cambio.sql
--
-- Una operacion de cambio mueve DOS cajas: salen dolares y entran pesos. Si la
-- app hiciera los tres inserts por separado, cualquier corte a mitad de camino
-- dejaria la tesoreria descuadrada. Va como una sola funcion, atomica.
--
-- La cotizacion de la operacion se guarda como fuente 'operacion', separada de
-- la 'MEP' de referencia: son cosas distintas y la planilla tambien las tiene
-- separadas (la hoja Dolar por un lado, los cambios de la caja por otro).
-- =============================================================================

create or replace function public.registrar_operacion_cambio(
  p_fecha        date,
  p_usd          numeric,
  p_cotizacion   numeric,
  p_cuenta_usd   uuid,
  p_cuenta_ars   uuid,
  p_project_id   uuid default null,
  p_nota         text default null
)
returns uuid
language plpgsql
security invoker
as $fn$
declare
  v_op  uuid;
  v_ars numeric;
begin
  if p_usd is null or p_usd <= 0 then
    raise exception 'El monto en dólares debe ser mayor a cero';
  end if;
  if p_cotizacion is null or p_cotizacion <= 0 then
    raise exception 'La cotización debe ser mayor a cero';
  end if;
  if p_cuenta_usd = p_cuenta_ars then
    raise exception 'Las cuentas de origen y destino no pueden ser la misma';
  end if;

  v_ars := round(p_usd * p_cotizacion, 2);

  insert into public.fx_operations
    (operation_date, usd_amount, ars_per_usd, usd_account_id, ars_account_id, note, created_by)
  values (p_fecha, p_usd, p_cotizacion, p_cuenta_usd, p_cuenta_ars, p_nota, auth.uid())
  returning id into v_op;

  -- Salen los dólares
  insert into public.cash_movements
    (account_id, project_id, movement_date, concept, amount, fx_usd, created_by)
  values (
    p_cuenta_usd, p_project_id, p_fecha,
    coalesce(p_nota, 'Cambio de ' || p_usd || ' USD a ' || p_cotizacion),
    -p_usd, p_cotizacion, auth.uid()
  );

  -- Entran los pesos
  insert into public.cash_movements
    (account_id, project_id, movement_date, concept, amount, fx_usd, created_by)
  values (
    p_cuenta_ars, p_project_id, p_fecha,
    coalesce(p_nota, 'Cambio de ' || p_usd || ' USD a ' || p_cotizacion),
    v_ars, p_cotizacion, auth.uid()
  );

  -- Queda registrada la cotizacion efectivamente pagada.
  insert into public.fx_rates (rate_date, source, ars_per_usd, note, created_by)
  values (p_fecha, 'operacion', p_cotizacion, 'Operación de cambio', auth.uid())
  on conflict (rate_date, source) do nothing;

  return v_op;
end;
$fn$;

grant execute on function public.registrar_operacion_cambio(
  date, numeric, numeric, uuid, uuid, uuid, text
) to authenticated;

-- -----------------------------------------------------------------------------
-- Vista de apoyo para la pantalla de obra: el gasto del mes por proyecto.
-- -----------------------------------------------------------------------------
create view public.gasto_mensual as
select
  e.project_id,
  date_trunc('month', e.expense_date)::date as month,
  count(*)                                   as cantidad,
  sum(e.amount_usd)                          as total_usd
from public.expenses e
where e.status <> 'anulado'
group by e.project_id, date_trunc('month', e.expense_date);

alter view public.gasto_mensual set (security_invoker = on);
grant select on public.gasto_mensual to authenticated;
