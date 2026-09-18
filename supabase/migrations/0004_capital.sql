-- =============================================================================
-- 0004_capital.sql  ·  Fase 2 — Inversores y movimientos de capital
--
-- Decision central: UN libro mayor de capital, no una tabla por operacion.
-- El tipo del movimiento define su efecto. Asi "cuanto tiene cada inversor"
-- es una suma sobre una tabla y no una conciliacion entre modulos.
-- =============================================================================

create type capital_movement_type as enum (
  'aporte',              -- el inversor pone plata en un proyecto
  'retiro',              -- el inversor saca plata
  'profit_asignado',     -- resultado que le corresponde (no mueve caja)
  'profit_distribuido',  -- profit efectivamente pagado (sale caja)
  'reinversion',         -- profit que pasa a otro proyecto sin salir de caja
  'transferencia'        -- capital que rota entre proyectos, sin inversor
);

create type movement_status as enum ('confirmado', 'anulado');

-- -----------------------------------------------------------------------------
-- investors
--
-- Separado de profiles a proposito: un inversor puede existir sin login, y una
-- participacion puede estar a nombre de una pareja ("Dani y Ale", "Joaco y
-- Mariu" en el business case actual). user_id vincula al perfil cuando esa
-- persona ademas entra a la app.
-- -----------------------------------------------------------------------------
create table public.investors (
  id          uuid primary key default gen_random_uuid(),
  name        text not null,
  email       text,
  phone       text,
  user_id     uuid unique references public.profiles(id) on delete set null,
  is_active   boolean not null default true,
  joined_on   date,
  notes       text,
  is_demo     boolean not null default false,
  created_by  uuid references public.profiles(id),
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

create trigger investors_set_updated_at
  before update on public.investors
  for each row execute function public.set_updated_at();

create index investors_user_idx on public.investors (user_id);

-- -----------------------------------------------------------------------------
-- capital_movements — el libro mayor.
--
-- amount se guarda SIEMPRE positivo. El signo lo define el tipo, no el dato:
-- un monto negativo cargado a mano es justo el error que aparece hoy en la
-- planilla (importes de -41.110 y -200.000 sin explicacion).
--
-- amount_usd es columna generada. Nadie tipea el valor en dolares: se deriva
-- de monto + moneda + cotizacion. Ese es el bug que rompe el presupuesto
-- actual, donde el total "USD" del budget son en realidad pesos.
-- -----------------------------------------------------------------------------
create table public.capital_movements (
  id              uuid primary key default gen_random_uuid(),
  type            capital_movement_type not null,
  status          movement_status not null default 'confirmado',

  investor_id     uuid references public.investors(id) on delete restrict,
  project_id      uuid references public.projects(id) on delete restrict,
  from_project_id uuid references public.projects(id) on delete restrict,

  movement_date   date not null,
  amount          numeric(18,2) not null check (amount > 0),
  currency        currency not null,
  fx_usd          numeric(18,4) check (fx_usd is null or fx_usd > 0),
  amount_usd      numeric(18,2) generated always as (
                    case when currency = 'USD' then amount
                         else round(amount / fx_usd, 2) end
                  ) stored,

  concept         text,
  is_demo         boolean not null default false,
  created_by      uuid references public.profiles(id),
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now(),

  -- Si el movimiento es en pesos, la cotizacion es obligatoria. Sin esto
  -- volvemos a tener importes que nadie sabe a cuanto se convirtieron.
  constraint capital_fx_required
    check (currency = 'USD' or fx_usd is not null),

  -- Los movimientos con inversor lo exigen; la transferencia pura no.
  constraint capital_investor_required
    check (type = 'transferencia' or investor_id is not null),

  -- Reinversion y transferencia mueven capital ENTRE proyectos: necesitan
  -- origen y destino, y distintos.
  constraint capital_transfer_shape
    check (
      case when type in ('reinversion', 'transferencia')
           then from_project_id is not null
                and project_id is not null
                and from_project_id <> project_id
           else from_project_id is null
      end
    ),

  -- El resto de los tipos siempre apuntan a un proyecto.
  constraint capital_project_required
    check (project_id is not null)
);

create trigger capital_movements_set_updated_at
  before update on public.capital_movements
  for each row execute function public.set_updated_at();

create trigger capital_movements_audit
  after insert or update or delete on public.capital_movements
  for each row execute function public.log_audit();

create index capital_investor_idx on public.capital_movements (investor_id);
create index capital_project_idx  on public.capital_movements (project_id);
create index capital_date_idx     on public.capital_movements (movement_date desc);

-- -----------------------------------------------------------------------------
-- Los registros financieros no se borran: se anulan.
-- -----------------------------------------------------------------------------
create or replace function public.forbid_capital_delete()
returns trigger
language plpgsql
as $fn$
begin
  raise exception
    'Los movimientos de capital no se eliminan. Cambiar status a "anulado".';
end;
$fn$;

create trigger capital_movements_no_delete
  before delete on public.capital_movements
  for each row execute function public.forbid_capital_delete();

-- =============================================================================
-- VISTAS — el calculo vive aca, una sola vez.
-- Ninguna pantalla reimplementa estas cuentas.
-- =============================================================================

-- Efecto de cada movimiento sobre capital y profit, en USD.
-- Es la unica definicion de signo del sistema.
create view public.capital_effects as
select
  m.id,
  m.movement_date,
  m.investor_id,
  m.project_id,
  m.from_project_id,
  m.type,
  m.amount_usd,
  -- Capital invertido por el inversor
  case m.type
    when 'aporte'      then  m.amount_usd
    when 'retiro'      then -m.amount_usd
    when 'reinversion' then  m.amount_usd   -- el profit pasa a ser capital
    else 0
  end as capital_delta,
  -- Profit que le fue asignado y todavia no cobro ni reinvirtio
  case m.type
    when 'profit_asignado'    then  m.amount_usd
    when 'profit_distribuido' then -m.amount_usd
    when 'reinversion'        then -m.amount_usd
    else 0
  end as profit_pendiente_delta,
  -- Profit efectivamente cobrado
  case m.type when 'profit_distribuido' then m.amount_usd else 0 end
    as profit_cobrado_delta,
  -- Movimiento de caja: solo aporte, retiro y distribucion mueven plata
  case m.type
    when 'aporte'             then  m.amount_usd
    when 'retiro'             then -m.amount_usd
    when 'profit_distribuido' then -m.amount_usd
    else 0
  end as cash_delta
from public.capital_movements m
where m.status = 'confirmado';

-- Posicion de cada inversor en cada proyecto.
create view public.investor_positions as
select
  e.investor_id,
  e.project_id,
  sum(e.capital_delta)          as capital_invertido_usd,
  sum(e.profit_pendiente_delta) as profit_pendiente_usd,
  sum(e.profit_cobrado_delta)   as profit_cobrado_usd,
  max(e.movement_date)          as ultimo_movimiento
from public.capital_effects e
where e.investor_id is not null
group by e.investor_id, e.project_id;

-- Resumen por inversor, consolidado.
create view public.investor_summary as
select
  i.id                                  as investor_id,
  i.name,
  i.is_active,
  coalesce(sum(p.capital_invertido_usd), 0) as capital_invertido_usd,
  coalesce(sum(p.profit_pendiente_usd), 0)  as profit_pendiente_usd,
  coalesce(sum(p.profit_cobrado_usd), 0)    as profit_cobrado_usd,
  count(distinct p.project_id) filter (where p.capital_invertido_usd > 0)
                                            as proyectos_activos
from public.investors i
left join public.investor_positions p on p.investor_id = i.id
group by i.id, i.name, i.is_active;

-- Capital que entro a cada proyecto.
create view public.project_capital as
select
  pr.id                          as project_id,
  pr.code,
  pr.name,
  coalesce(sum(e.capital_delta), 0) as capital_aportado_usd,
  coalesce(sum(e.cash_delta), 0)    as cash_neto_usd
from public.projects pr
left join public.capital_effects e on e.project_id = pr.id
group by pr.id, pr.code, pr.name;

-- =============================================================================
-- RLS
-- =============================================================================
alter table public.investors         enable row level security;
alter table public.capital_movements enable row level security;

-- Un inversor ve su propia ficha; lectura global para admin/manager/viewer.
create policy investors_select on public.investors
  for select to authenticated
  using (public.can_read_all() or user_id = auth.uid());

create policy investors_write on public.investors
  for all to authenticated
  using (public.can_manage())
  with check (public.can_manage());

-- Un inversor ve solo SUS movimientos. No ve los de los demas.
create policy capital_select on public.capital_movements
  for select to authenticated
  using (
    public.can_read_all()
    or investor_id in (
      select id from public.investors where user_id = auth.uid()
    )
  );

create policy capital_write on public.capital_movements
  for all to authenticated
  using (public.can_manage())
  with check (public.can_manage());

-- -----------------------------------------------------------------------------
-- Privilegios explicitos. Nada de grants por default.
-- Las vistas se crean con security_invoker para que apliquen la RLS del que
-- consulta, no la del dueño de la vista.
-- -----------------------------------------------------------------------------
alter view public.capital_effects     set (security_invoker = on);
alter view public.investor_positions  set (security_invoker = on);
alter view public.investor_summary    set (security_invoker = on);
alter view public.project_capital     set (security_invoker = on);

grant select on public.investors, public.capital_movements,
                public.capital_effects, public.investor_positions,
                public.investor_summary, public.project_capital
  to authenticated;

grant insert, update, delete on public.investors to authenticated;
grant insert, update on public.capital_movements to authenticated;
