-- =============================================================================
-- 0005_project_finance.sql  ·  Fase 3 — Presupuesto, gastos, ingresos y caja
--
-- Tres reglas:
--   1. El presupuesto original no se sobrescribe. Original y forecast son
--      columnas distintas de la misma linea.
--   2. Budget, forecast y actual tienen procedencias distintas. Actual son
--      gastos reales, no presupuesto editado.
--   3. Ningun importe se convierte con una constante: monto + moneda + fx.
-- =============================================================================

create type cost_kind as enum ('directo', 'indirecto');

create type expense_status as enum (
  'estimado',    -- previsto, sin comprometer
  'comprometido',-- aprobado o comprado, no recibido  -> Committed
  'recibido',    -- recibido, impaga                  -> Actual
  'pagado',      -- recibido y pagado                 -> Actual
  'anulado'
);

create type revenue_kind as enum ('venta', 'anticipo', 'otro');

-- -----------------------------------------------------------------------------
-- cost_categories — jerarquia Categoria > Subcategoria, como en el catalogo
-- actual (Lote > Tramites, Materiales > Pilotes, Sanitario > Losa Radiante...).
-- Autorreferencial: un nivel padre y un nivel hijo, sin tabla aparte.
-- -----------------------------------------------------------------------------
create table public.cost_categories (
  id         uuid primary key default gen_random_uuid(),
  parent_id  uuid references public.cost_categories(id) on delete restrict,
  name       text not null,
  kind       cost_kind not null default 'directo',
  sort_order int not null default 0,
  is_active  boolean not null default true,
  created_at timestamptz not null default now(),
  unique (parent_id, name)
);

create index cost_categories_parent_idx on public.cost_categories (parent_id);

-- Etiqueta completa "Categoria / Subcategoria", para no reconstruirla en la UI.
create view public.cost_category_paths as
select
  c.id,
  c.parent_id,
  c.kind,
  c.sort_order,
  coalesce(p.name || ' / ', '') || c.name as path,
  p.name as parent_name,
  c.name as name
from public.cost_categories c
left join public.cost_categories p on p.id = c.parent_id;

-- -----------------------------------------------------------------------------
-- budget_lines — presupuesto por item y proyecto.
--
-- qty/price _original se congelan; _forecast es la estimacion vigente. Guardar
-- cantidad y precio por separado (y no solo el total) es lo que despues permite
-- explicar un desvio: si se desvio por cantidad o por precio.
-- -----------------------------------------------------------------------------
create table public.budget_lines (
  id              uuid primary key default gen_random_uuid(),
  project_id      uuid not null references public.projects(id) on delete cascade,
  category_id     uuid references public.cost_categories(id) on delete restrict,
  description     text not null,
  unit            text not null default 'un',

  qty_original    numeric(18,4) not null default 0 check (qty_original >= 0),
  price_original_usd numeric(18,4) not null default 0 check (price_original_usd >= 0),
  qty_forecast    numeric(18,4) check (qty_forecast is null or qty_forecast >= 0),
  price_forecast_usd numeric(18,4) check (price_forecast_usd is null or price_forecast_usd >= 0),

  total_original_usd numeric(18,2)
    generated always as (round(qty_original * price_original_usd, 2)) stored,
  total_forecast_usd numeric(18,2)
    generated always as (
      round(coalesce(qty_forecast, qty_original)
          * coalesce(price_forecast_usd, price_original_usd), 2)
    ) stored,

  notes           text,
  created_by      uuid references public.profiles(id),
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now()
);

create trigger budget_lines_set_updated_at
  before update on public.budget_lines
  for each row execute function public.set_updated_at();

create index budget_lines_project_idx  on public.budget_lines (project_id);
create index budget_lines_category_idx on public.budget_lines (category_id);

-- -----------------------------------------------------------------------------
-- expenses — costo real. Es la fuente de Actual y de Committed.
-- -----------------------------------------------------------------------------
create table public.expenses (
  id             uuid primary key default gen_random_uuid(),
  project_id     uuid not null references public.projects(id) on delete restrict,
  category_id    uuid references public.cost_categories(id) on delete restrict,
  budget_line_id uuid references public.budget_lines(id) on delete set null,

  description    text not null,
  supplier_name  text,              -- se normaliza contra suppliers en Fase 4
  status         expense_status not null default 'recibido',

  expense_date   date not null,
  due_date       date,
  paid_date      date,

  qty            numeric(18,4) not null default 1 check (qty > 0),
  unit_price     numeric(18,4) not null check (unit_price >= 0),
  currency       currency not null,
  fx_usd         numeric(18,4) check (fx_usd is null or fx_usd > 0),
  amount_usd     numeric(18,2) generated always as (
                   case when currency = 'USD' then round(qty * unit_price, 2)
                        else round(qty * unit_price / fx_usd, 2) end
                 ) stored,

  is_demo        boolean not null default false,
  created_by     uuid references public.profiles(id),
  created_at     timestamptz not null default now(),
  updated_at     timestamptz not null default now(),

  constraint expenses_fx_required
    check (currency = 'USD' or fx_usd is not null)
);

create trigger expenses_set_updated_at
  before update on public.expenses
  for each row execute function public.set_updated_at();

create trigger expenses_audit
  after insert or update or delete on public.expenses
  for each row execute function public.log_audit();

create index expenses_project_idx  on public.expenses (project_id);
create index expenses_date_idx     on public.expenses (expense_date desc);
create index expenses_status_idx   on public.expenses (status);

-- -----------------------------------------------------------------------------
-- revenues — ingresos del proyecto.
-- -----------------------------------------------------------------------------
create table public.revenues (
  id           uuid primary key default gen_random_uuid(),
  project_id   uuid not null references public.projects(id) on delete restrict,
  kind         revenue_kind not null default 'venta',
  description  text,
  revenue_date date not null,
  amount       numeric(18,2) not null check (amount > 0),
  currency     currency not null,
  fx_usd       numeric(18,4) check (fx_usd is null or fx_usd > 0),
  amount_usd   numeric(18,2) generated always as (
                 case when currency = 'USD' then amount
                      else round(amount / fx_usd, 2) end
               ) stored,
  is_demo      boolean not null default false,
  created_by   uuid references public.profiles(id),
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now(),

  constraint revenues_fx_required
    check (currency = 'USD' or fx_usd is not null)
);

create trigger revenues_set_updated_at
  before update on public.revenues
  for each row execute function public.set_updated_at();

create trigger revenues_audit
  after insert or update or delete on public.revenues
  for each row execute function public.log_audit();

create index revenues_project_idx on public.revenues (project_id);

-- -----------------------------------------------------------------------------
-- cash_accounts — caja.
--
-- project_id nulo = caja comun del negocio, que es como opera hoy la planilla
-- de los lotes 84 y 583. Con proyecto asignado = caja propia de esa obra.
-- El mismo esquema sirve para las dos formas de trabajar.
-- -----------------------------------------------------------------------------
create table public.cash_accounts (
  id          uuid primary key default gen_random_uuid(),
  name        text not null,
  currency    currency not null,
  project_id  uuid references public.projects(id) on delete restrict,
  is_active   boolean not null default true,
  created_at  timestamptz not null default now(),
  unique (name, currency)
);

-- cash_movements — cada entrada o salida de plata.
-- project_id es la IMPUTACION por obra, independiente de en que cuenta esta.
-- Asi una caja comun puede repartir sus movimientos entre varias casas.
create table public.cash_movements (
  id              uuid primary key default gen_random_uuid(),
  account_id      uuid not null references public.cash_accounts(id) on delete restrict,
  project_id      uuid references public.projects(id) on delete restrict,
  movement_date   date not null,
  concept         text not null,
  amount          numeric(18,2) not null check (amount <> 0),  -- signo = sentido
  fx_usd          numeric(18,4) check (fx_usd is null or fx_usd > 0),
  -- Referencias opcionales al hecho que origino el movimiento.
  expense_id      uuid references public.expenses(id) on delete set null,
  revenue_id      uuid references public.revenues(id) on delete set null,
  capital_movement_id uuid references public.capital_movements(id) on delete set null,
  is_demo         boolean not null default false,
  created_by      uuid references public.profiles(id),
  created_at      timestamptz not null default now()
);

create index cash_movements_account_idx on public.cash_movements (account_id);
create index cash_movements_project_idx on public.cash_movements (project_id);
create index cash_movements_date_idx    on public.cash_movements (movement_date desc);

-- Operacion de cambio: comprar pesos con dolares. Es el mecanismo que la
-- planilla ya usa bien (cada cambio con su cotizacion y su fecha) y que el
-- presupuesto ignoraba al fijar 1400.
create table public.fx_operations (
  id             uuid primary key default gen_random_uuid(),
  operation_date date not null,
  usd_amount     numeric(18,2) not null check (usd_amount > 0),
  ars_per_usd    numeric(18,4) not null check (ars_per_usd > 0),
  ars_amount     numeric(18,2) generated always as (round(usd_amount * ars_per_usd, 2)) stored,
  usd_account_id uuid references public.cash_accounts(id) on delete restrict,
  ars_account_id uuid references public.cash_accounts(id) on delete restrict,
  note           text,
  created_by     uuid references public.profiles(id),
  created_at     timestamptz not null default now()
);

-- =============================================================================
-- VISTAS — el calculo, una sola vez.
-- =============================================================================

-- Presupuesto por proyecto: original vs forecast.
create view public.project_budget_summary as
select
  b.project_id,
  sum(b.total_original_usd) as budget_original_usd,
  sum(b.total_forecast_usd) as budget_forecast_usd,
  count(*)                  as lineas
from public.budget_lines b
group by b.project_id;

-- Costos reales y comprometidos.
--   Actual    = recibido + pagado
--   Committed = comprometido (aprobado o comprado, sin recibir)
create view public.project_costs as
select
  e.project_id,
  sum(e.amount_usd) filter (where e.status in ('recibido', 'pagado')) as actual_usd,
  sum(e.amount_usd) filter (where e.status = 'comprometido')          as committed_usd,
  sum(e.amount_usd) filter (where e.status = 'estimado')              as estimado_usd,
  sum(e.amount_usd) filter (where e.status = 'pagado')                as pagado_usd
from public.expenses e
where e.status <> 'anulado'
group by e.project_id;

-- Ingresos reales.
create view public.project_revenues as
select
  r.project_id,
  sum(r.amount_usd)                                    as revenue_usd,
  sum(r.amount_usd) filter (where r.kind = 'venta')    as venta_usd,
  sum(r.amount_usd) filter (where r.kind = 'anticipo') as anticipos_usd
from public.revenues r
group by r.project_id;

-- P&L por proyecto. Unica definicion de margen del sistema.
--
-- Forecast de costo = actual + lo que todavia no se ejecuto del forecast de
-- presupuesto. Si ya se gasto mas que el forecast, el forecast pasa a ser el
-- actual: no se puede prever gastar menos de lo ya gastado.
create view public.project_pnl as
select
  p.id                                          as project_id,
  p.code,
  p.name,
  p.status,
  coalesce(r.revenue_usd, 0)                    as revenue_usd,
  coalesce(p.target_sale_usd, 0)                as revenue_target_usd,
  coalesce(b.budget_original_usd, 0)            as budget_usd,
  coalesce(b.budget_forecast_usd, 0)            as budget_forecast_usd,
  coalesce(c.actual_usd, 0)                     as actual_cost_usd,
  coalesce(c.committed_usd, 0)                  as committed_cost_usd,
  greatest(
    coalesce(b.budget_forecast_usd, 0),
    coalesce(c.actual_usd, 0) + coalesce(c.committed_usd, 0)
  )                                             as forecast_cost_usd,
  -- Comision inmobiliaria sobre la venta, con el porcentaje del proyecto.
  round(coalesce(r.venta_usd, coalesce(p.target_sale_usd, 0)) * p.broker_fee_pct, 2)
                                                as broker_fee_usd,
  -- Resultado con lo ejecutado
  coalesce(r.revenue_usd, 0) - coalesce(c.actual_usd, 0)
                                                as gross_profit_usd,
  -- Resultado proyectado: venta esperada menos costo proyectado y comision
  coalesce(nullif(r.venta_usd, 0), coalesce(p.target_sale_usd, 0))
    - greatest(
        coalesce(b.budget_forecast_usd, 0),
        coalesce(c.actual_usd, 0) + coalesce(c.committed_usd, 0)
      )
    - round(coalesce(nullif(r.venta_usd, 0), coalesce(p.target_sale_usd, 0)) * p.broker_fee_pct, 2)
                                                as forecast_profit_usd
from public.projects p
left join public.project_budget_summary b on b.project_id = p.id
left join public.project_costs          c on c.project_id = p.id
left join public.project_revenues       r on r.project_id = p.id;

-- Desvio por linea de presupuesto: budget vs forecast vs actual.
create view public.budget_variance as
select
  b.id                       as budget_line_id,
  b.project_id,
  b.description,
  cp.path                    as categoria,
  b.unit,
  b.qty_original,
  b.price_original_usd,
  b.total_original_usd,
  b.total_forecast_usd,
  coalesce(sum(e.amount_usd) filter (where e.status in ('recibido', 'pagado')), 0)
                             as actual_usd,
  coalesce(sum(e.amount_usd) filter (where e.status = 'comprometido'), 0)
                             as committed_usd
from public.budget_lines b
left join public.cost_category_paths cp on cp.id = b.category_id
left join public.expenses e on e.budget_line_id = b.id and e.status <> 'anulado'
group by b.id, b.project_id, b.description, cp.path, b.unit,
         b.qty_original, b.price_original_usd,
         b.total_original_usd, b.total_forecast_usd;

-- Saldo por cuenta de caja, en su propia moneda.
create view public.cash_balances as
select
  a.id        as account_id,
  a.name,
  a.currency,
  a.project_id,
  coalesce(sum(m.amount), 0) as balance
from public.cash_accounts a
left join public.cash_movements m on m.account_id = a.id
where a.is_active
group by a.id, a.name, a.currency, a.project_id;

-- =============================================================================
-- RLS
-- =============================================================================
alter table public.cost_categories enable row level security;
alter table public.budget_lines    enable row level security;
alter table public.expenses        enable row level security;
alter table public.revenues        enable row level security;
alter table public.cash_accounts   enable row level security;
alter table public.cash_movements  enable row level security;
alter table public.fx_operations   enable row level security;

-- Las categorias son catalogo: las lee cualquier autenticado.
create policy cost_categories_select on public.cost_categories
  for select to authenticated using (true);
create policy cost_categories_write on public.cost_categories
  for all to authenticated using (public.can_manage()) with check (public.can_manage());

-- Presupuesto, gastos e ingresos: solo quien tiene acceso al proyecto.
create policy budget_lines_select on public.budget_lines
  for select to authenticated using (public.has_project_access(project_id));
create policy budget_lines_write on public.budget_lines
  for all to authenticated using (public.can_manage()) with check (public.can_manage());

create policy expenses_select on public.expenses
  for select to authenticated using (public.has_project_access(project_id));
create policy expenses_write on public.expenses
  for all to authenticated using (public.can_manage()) with check (public.can_manage());

create policy revenues_select on public.revenues
  for select to authenticated using (public.has_project_access(project_id));
create policy revenues_write on public.revenues
  for all to authenticated using (public.can_manage()) with check (public.can_manage());

-- La caja es informacion del negocio: un inversor no ve la tesoreria completa.
create policy cash_accounts_select on public.cash_accounts
  for select to authenticated using (public.can_read_all());
create policy cash_accounts_write on public.cash_accounts
  for all to authenticated using (public.can_manage()) with check (public.can_manage());

create policy cash_movements_select on public.cash_movements
  for select to authenticated using (public.can_read_all());
create policy cash_movements_write on public.cash_movements
  for all to authenticated using (public.can_manage()) with check (public.can_manage());

create policy fx_operations_select on public.fx_operations
  for select to authenticated using (public.can_read_all());
create policy fx_operations_write on public.fx_operations
  for all to authenticated using (public.can_manage()) with check (public.can_manage());

-- -----------------------------------------------------------------------------
-- Vistas con la RLS del que consulta, no la del dueño.
-- -----------------------------------------------------------------------------
alter view public.cost_category_paths      set (security_invoker = on);
alter view public.project_budget_summary   set (security_invoker = on);
alter view public.project_costs            set (security_invoker = on);
alter view public.project_revenues         set (security_invoker = on);
alter view public.project_pnl              set (security_invoker = on);
alter view public.budget_variance          set (security_invoker = on);
alter view public.cash_balances            set (security_invoker = on);

-- -----------------------------------------------------------------------------
-- Privilegios explicitos.
-- -----------------------------------------------------------------------------
grant select on
  public.cost_categories, public.budget_lines, public.expenses, public.revenues,
  public.cash_accounts, public.cash_movements, public.fx_operations,
  public.cost_category_paths, public.project_budget_summary, public.project_costs,
  public.project_revenues, public.project_pnl, public.budget_variance,
  public.cash_balances
  to authenticated;

grant insert, update, delete on
  public.cost_categories, public.budget_lines, public.cash_accounts,
  public.cash_movements, public.fx_operations
  to authenticated;

-- Gastos e ingresos no se borran: se anulan o se corrigen.
grant insert, update on public.expenses, public.revenues to authenticated;
