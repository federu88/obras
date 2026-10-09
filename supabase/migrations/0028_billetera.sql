-- =============================================================================
-- 0028_billetera.sql
--
-- La billetera de cada obra: los dolares que entregan los inversores (o el
-- cliente, en una obra por encargo), los pesos que salen de cambiarlos, y lo
-- que se gasto con esa plata. Al final, la conciliacion en las dos monedas.
--
-- La billetera NO se carga: se deriva de lo que ya esta registrado.
--   Entradas  desarrollo -> aportes menos retiros (capital_movements)
--             encargo    -> cobros al cliente (revenues)
--   Cambios   fx_operations, ahora imputadas a una obra
--   Salidas   gastos pagados (expenses), cada uno en su moneda
-- Lo unico nuevo que se tipea es el arqueo: cuanta plata hay de verdad. La
-- diferencia contra lo que deberia haber es lo que falta rendir.
--
-- Se concilia en cada moneda por separado, sin convertir: los pesos se
-- obtuvieron a la cotizacion de cada cambio, y pasarlos a dolares a otra
-- cotizacion inventaria una diferencia que no existe.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- El cambio pasa a pertenecer a una obra.
-- Las cuentas quedan opcionales: un cambio cargado desde la billetera de la
-- obra no necesita pasar por las cajas de tesoreria.
-- -----------------------------------------------------------------------------
alter table public.fx_operations
  add column project_id uuid references public.projects(id) on delete restrict;

create index fx_operations_project_idx on public.fx_operations (project_id);

-- Los cambios viejos ya tenian la obra en sus movimientos de caja.
update public.fx_operations f
set project_id = (
  select m.project_id
  from public.cash_movements m
  where m.account_id    = f.usd_account_id
    and m.movement_date = f.operation_date
    and m.amount        = -f.usd_amount
    and m.project_id is not null
  limit 1
)
where f.project_id is null;

-- La funcion de Caja ya recibia la obra; ahora tambien la guarda en el cambio.
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
    (operation_date, usd_amount, ars_per_usd, usd_account_id, ars_account_id,
     project_id, note, created_by)
  values (p_fecha, p_usd, p_cotizacion, p_cuenta_usd, p_cuenta_ars,
          p_project_id, p_nota, auth.uid())
  returning id into v_op;

  insert into public.cash_movements
    (account_id, project_id, movement_date, concept, amount, fx_usd, created_by)
  values (
    p_cuenta_usd, p_project_id, p_fecha,
    coalesce(p_nota, 'Cambio de ' || p_usd || ' USD a ' || p_cotizacion),
    -p_usd, p_cotizacion, auth.uid()
  );

  insert into public.cash_movements
    (account_id, project_id, movement_date, concept, amount, fx_usd, created_by)
  values (
    p_cuenta_ars, p_project_id, p_fecha,
    coalesce(p_nota, 'Cambio de ' || p_usd || ' USD a ' || p_cotizacion),
    v_ars, p_cotizacion, auth.uid()
  );

  insert into public.fx_rates (rate_date, source, ars_per_usd, note, created_by)
  values (p_fecha, 'operacion', p_cotizacion, 'Operación de cambio', auth.uid())
  on conflict (rate_date, source) do nothing;

  return v_op;
end;
$fn$;

-- -----------------------------------------------------------------------------
-- wallet_counts — el arqueo: cuanta plata hay de verdad en la billetera.
--
-- Como las referencias de la conciliacion, un arqueo no se corrige: se carga
-- otro con fecha posterior. Vale el mas reciente de cada moneda.
-- -----------------------------------------------------------------------------
create table public.wallet_counts (
  id          uuid primary key default gen_random_uuid(),
  project_id  uuid not null references public.projects(id) on delete cascade,
  count_date  date not null default current_date,
  currency    currency not null,
  amount      numeric(18,2) not null check (amount >= 0),
  note        text,
  created_by  uuid references public.profiles(id),
  created_at  timestamptz not null default now()
);

create index wallet_counts_idx
  on public.wallet_counts (project_id, currency, count_date desc);

comment on table public.wallet_counts is
  'Arqueo de la billetera de una obra. La diferencia contra wallet_reconciliation es lo que falta rendir.';

-- -----------------------------------------------------------------------------
-- wallet_ledger — cada movimiento de la billetera, en su moneda.
-- amount lleva signo: positivo entra, negativo sale.
-- -----------------------------------------------------------------------------
create view public.wallet_ledger as
-- Aportes y retiros de los inversores (desarrollo propio)
select
  m.project_id,
  m.movement_date                     as fecha,
  case m.type when 'aporte' then 'entrada' else 'retiro' end as tipo,
  m.currency,
  case m.type when 'aporte' then m.amount else -m.amount end as amount,
  m.fx_usd                            as cotizacion,
  coalesce(m.concept, i.name)         as concepto,
  i.name                              as quien,
  m.id                                as origen_id
from public.capital_movements m
join public.projects p on p.id = m.project_id and p.model = 'desarrollo'
left join public.investors i on i.id = m.investor_id
where m.status = 'confirmado'
  and m.type in ('aporte', 'retiro')

union all

-- Cobros al cliente (obra por encargo)
select
  r.project_id,
  r.revenue_date,
  'entrada',
  r.currency,
  r.amount,
  r.fx_usd,
  coalesce(r.description, 'Pago del cliente'),
  cl.name,
  r.id
from public.revenues r
join public.projects p on p.id = r.project_id and p.model = 'encargo'
left join public.contracts c on c.project_id = p.id
left join public.clients  cl on cl.id = c.client_id

union all

-- Cambio: salen los dolares...
select
  f.project_id, f.operation_date, 'cambio', 'USD'::currency,
  -f.usd_amount, f.ars_per_usd,
  coalesce(f.note, 'Cambio a pesos'), null, f.id
from public.fx_operations f
where f.project_id is not null

union all

-- ...y entran los pesos
select
  f.project_id, f.operation_date, 'cambio', 'ARS'::currency,
  f.ars_amount, f.ars_per_usd,
  coalesce(f.note, 'Cambio a pesos'), null, f.id
from public.fx_operations f
where f.project_id is not null

union all

-- Gastos pagados con la plata de la billetera. Lo que el cliente pago directo
-- nunca paso por la billetera, asi que no sale de ella.
select
  e.project_id,
  coalesce(e.paid_date, e.expense_date),
  'gasto',
  e.currency,
  -round(e.qty * e.unit_price, 2),
  e.fx_usd,
  e.description,
  e.supplier_name,
  e.id
from public.expenses e
where e.status = 'pagado'
  and e.paid_by = 'estudio';

-- -----------------------------------------------------------------------------
-- wallet_reconciliation — una fila por obra, las dos monedas lado a lado.
--
--   USD:   recibido - cambiado - gastado = deberia haber
--   Pesos: obtenido - gastado            = deberia haber
--   Contra el ultimo arqueo de cada moneda: la diferencia es lo sin rendir.
-- -----------------------------------------------------------------------------
create view public.wallet_reconciliation as
with t as (
  select
    project_id,
    coalesce(sum(amount)  filter (where currency = 'USD' and tipo in ('entrada', 'retiro')), 0) as usd_recibido,
    coalesce(-sum(amount) filter (where currency = 'USD' and tipo = 'cambio'), 0)             as usd_cambiado,
    coalesce(-sum(amount) filter (where currency = 'USD' and tipo = 'gasto'), 0)              as usd_gastado,
    coalesce(sum(amount)  filter (where currency = 'ARS' and tipo in ('entrada', 'retiro')), 0) as ars_recibido,
    coalesce(sum(amount)  filter (where currency = 'ARS' and tipo = 'cambio'), 0)             as ars_cambiado,
    coalesce(-sum(amount) filter (where currency = 'ARS' and tipo = 'gasto'), 0)              as ars_gastado
  from public.wallet_ledger
  group by project_id
),
arqueo as (
  select distinct on (project_id, currency)
    project_id, currency, amount, count_date
  from public.wallet_counts
  order by project_id, currency, count_date desc, created_at desc
),
cambios as (
  select project_id,
         sum(usd_amount) as usd,
         sum(ars_amount) as ars
  from public.fx_operations
  where project_id is not null
  group by project_id
)
select
  p.id                                         as project_id,
  p.code,
  p.name,
  p.model,
  coalesce(t.usd_recibido, 0)                  as usd_recibido,
  coalesce(t.usd_cambiado, 0)                  as usd_cambiado,
  coalesce(t.usd_gastado, 0)                   as usd_gastado,
  coalesce(t.usd_recibido, 0) - coalesce(t.usd_cambiado, 0) - coalesce(t.usd_gastado, 0)
                                               as usd_deberia,
  au.amount                                    as usd_arqueo,
  au.count_date                                as usd_arqueo_fecha,
  coalesce(t.ars_recibido, 0)                  as ars_recibido,
  coalesce(t.ars_cambiado, 0)                  as ars_cambiado,
  coalesce(t.ars_gastado, 0)                   as ars_gastado,
  coalesce(t.ars_recibido, 0) + coalesce(t.ars_cambiado, 0) - coalesce(t.ars_gastado, 0)
                                               as ars_deberia,
  aa.amount                                    as ars_arqueo,
  aa.count_date                                as ars_arqueo_fecha,
  -- Cotizacion promedio a la que se cambiaron los dolares de esta obra.
  case when c.usd > 0 then round(c.ars / c.usd, 4) end as cotizacion_promedio
from public.projects p
left join t       on t.project_id = p.id
left join cambios c on c.project_id = p.id
left join arqueo au on au.project_id = p.id and au.currency = 'USD'
left join arqueo aa on aa.project_id = p.id and aa.currency = 'ARS';

-- -----------------------------------------------------------------------------
-- Cambio cargado desde la billetera: sin cuentas de tesoreria.
-- -----------------------------------------------------------------------------
create or replace function public.registrar_cambio_billetera(
  p_project_id  uuid,
  p_fecha       date,
  p_usd         numeric,
  p_cotizacion  numeric,
  p_nota        text default null
)
returns uuid
language plpgsql
security invoker
as $fn$
declare
  v_op uuid;
begin
  if p_project_id is null then
    raise exception 'El cambio tiene que ser de una obra';
  end if;
  if p_usd is null or p_usd <= 0 then
    raise exception 'El monto en dólares debe ser mayor a cero';
  end if;
  if p_cotizacion is null or p_cotizacion <= 0 then
    raise exception 'La cotización debe ser mayor a cero';
  end if;

  insert into public.fx_operations
    (operation_date, usd_amount, ars_per_usd, project_id, note, created_by)
  values (p_fecha, p_usd, p_cotizacion, p_project_id, p_nota, auth.uid())
  returning id into v_op;

  insert into public.fx_rates (rate_date, source, ars_per_usd, note, created_by)
  values (p_fecha, 'operacion', p_cotizacion, 'Operación de cambio', auth.uid())
  on conflict (rate_date, source) do nothing;

  return v_op;
end;
$fn$;

grant execute on function public.registrar_cambio_billetera(
  uuid, date, numeric, numeric, text
) to authenticated;

-- -----------------------------------------------------------------------------
-- RLS y permisos
-- -----------------------------------------------------------------------------
alter table public.wallet_counts enable row level security;

create policy wallet_counts_select on public.wallet_counts
  for select to authenticated using (public.has_project_access(project_id));

create policy wallet_counts_write on public.wallet_counts
  for all to authenticated
  using (public.can_manage()) with check (public.can_manage());

alter view public.wallet_ledger         set (security_invoker = on);
alter view public.wallet_reconciliation set (security_invoker = on);

grant select on
  public.wallet_counts, public.wallet_ledger, public.wallet_reconciliation
  to authenticated;

grant insert on public.wallet_counts to authenticated;
