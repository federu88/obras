-- =============================================================================
-- 0023_obra_por_encargo.sql
--
-- Obras que se construyen para un tercero.
--
-- El mismo sistema, otro modelo de negocio. Construir una casa es construir una
-- casa: el catalogo, los precios, las etapas de obra, el cronograma, los gastos
-- del dia a dia y los proveedores son identicos. Lo que cambia es la plata.
--
--   Desarrollo propio            Obra por encargo
--   ------------------------     ---------------------------------------
--   Los socios ponen capital     El cliente paga contra avance
--   Se vende la casa             El cliente se queda la casa
--   Se reparte la utilidad       El estudio cobra honorarios
--   El presupuesto es interno    El presupuesto es un compromiso
--
-- Esa ultima linea es la que manda. En desarrollo propio pasarse de presupuesto
-- se come el margen propio y no hay que explicarselo a nadie. En una obra por
-- encargo pasarse es una conversacion con el cliente, y necesita papeles: por
-- eso aparecen los adicionales, los certificados y la bitacora.
--
-- DOS PRECIOS PARA LA MISMA COSA
-- El cliente no ve cuanto costo comprar algo ni cuanto se le cobro. Entonces
-- cada gasto y cada linea de presupuesto pueden llevar, ademas del costo, el
-- precio al cliente. La diferencia es el margen del estudio, y no puede
-- aparecer en nada que salga para afuera. Las vistas que terminan en _cliente
-- son las unicas que se pueden mostrar o imprimir para el cliente.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Que clase de negocio es cada obra
-- -----------------------------------------------------------------------------
create type project_model as enum (
  'desarrollo',  -- se construye para vender y repartir la utilidad
  'encargo'      -- se construye para un tercero, que la paga contra avance
);

alter table public.projects
  add column model project_model not null default 'desarrollo';

comment on column public.projects.model is
  'desarrollo: capital de socios y reparto. encargo: contrato con un cliente.';

-- -----------------------------------------------------------------------------
-- clients — quien encarga la obra.
--
-- Tabla aparte de investors a proposito. Un inversor tiene un derecho
-- proporcional sobre una utilidad que va a existir algun dia; un cliente tiene
-- un contrato con un precio y una entrega. Si comparten tabla, "capital
-- invertido" significa dos cosas distintas segun la fila, y eso siempre termina
-- en un numero mal sumado.
-- -----------------------------------------------------------------------------
create table public.clients (
  id         uuid primary key default gen_random_uuid(),
  name       text not null,
  tax_id     text,                      -- CUIT / CUIL
  email      text,
  phone      text,
  address    text,
  notes      text,
  is_active  boolean not null default true,
  created_by uuid references public.profiles(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create trigger clients_set_updated_at
  before update on public.clients
  for each row execute function public.set_updated_at();

-- -----------------------------------------------------------------------------
-- contracts — el acuerdo con el cliente. Uno por obra.
--
-- La modalidad de honorarios se elige por obra porque en la practica varia.
-- Cada una calcula distinto y ninguna es "la" correcta:
--
--   porcentaje_obra  el honorario es un % del costo de obra. Ojo con el
--                    incentivo: cuanto mas cara sale, mas cobra el estudio.
--   fijo             un monto pactado por la obra entera.
--   costo_mas_fee    se traslada el costo real mas un fee por administrar.
--                    Implica mostrarle el costo al cliente.
--   precio_cerrado   un precio por la obra terminada. El margen es la
--                    diferencia contra lo que realmente costo, y es lo que el
--                    cliente nunca ve.
-- -----------------------------------------------------------------------------
create type fee_model as enum (
  'porcentaje_obra', 'fijo', 'costo_mas_fee', 'precio_cerrado'
);

create table public.contracts (
  id          uuid primary key default gen_random_uuid(),
  project_id  uuid not null unique references public.projects(id) on delete cascade,
  client_id   uuid not null references public.clients(id) on delete restrict,

  signed_on   date,
  fee_model   fee_model not null,

  -- Lo que el cliente paga por la obra. En fijo y precio_cerrado es el numero
  -- del contrato; en las otras dos modalidades es la estimacion pactada.
  amount      numeric(18,2) not null default 0 check (amount >= 0),
  currency    currency not null default 'USD',
  fx_usd      numeric(18,4) check (fx_usd is null or fx_usd > 0),
  amount_usd  numeric(18,2) generated always as (
                case when currency = 'USD' then amount
                     else round(amount / fx_usd, 2) end
              ) stored,

  fee_pct     numeric(6,4) check (fee_pct is null or (fee_pct >= 0 and fee_pct <= 1)),
  fee_amount  numeric(18,2) check (fee_amount is null or fee_amount >= 0),

  advance     numeric(18,2) not null default 0 check (advance >= 0),

  notes       text,
  created_by  uuid references public.profiles(id),
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now(),

  constraint contracts_fx_required
    check (currency = 'USD' or fx_usd is not null),
  -- Cada modalidad necesita su parametro, y sin el no se puede calcular nada.
  constraint contracts_fee_coherent check (
    (fee_model in ('porcentaje_obra', 'costo_mas_fee') and fee_pct is not null)
    or (fee_model = 'fijo' and fee_amount is not null)
    or fee_model = 'precio_cerrado'
  )
);

create trigger contracts_set_updated_at
  before update on public.contracts
  for each row execute function public.set_updated_at();

create index contracts_client_idx on public.contracts (client_id);

-- -----------------------------------------------------------------------------
-- change_orders — los adicionales.
--
-- Todo cambio de alcance mueve el precio del contrato, con fecha y aprobacion.
-- Es donde se pierde plata en las obras por encargo: sin registro, la discusion
-- de marzo se pelea en noviembre contra la memoria de cada uno.
--
-- Solo los aprobados mueven el contrato vigente. Un adicional propuesto es una
-- conversacion, no plata.
-- -----------------------------------------------------------------------------
create type change_order_status as enum ('propuesto', 'aprobado', 'rechazado');

create table public.change_orders (
  id          uuid primary key default gen_random_uuid(),
  contract_id uuid not null references public.contracts(id) on delete cascade,
  number      int,
  order_date  date not null default current_date,
  description text not null,

  amount      numeric(18,2) not null check (amount <> 0),
  currency    currency not null default 'USD',
  fx_usd      numeric(18,4) check (fx_usd is null or fx_usd > 0),
  amount_usd  numeric(18,2) generated always as (
                case when currency = 'USD' then amount
                     else round(amount / fx_usd, 2) end
              ) stored,

  status      change_order_status not null default 'propuesto',
  decided_on  date,

  notes       text,
  created_by  uuid references public.profiles(id),
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now(),

  constraint change_orders_fx_required
    check (currency = 'USD' or fx_usd is not null)
);

create trigger change_orders_set_updated_at
  before update on public.change_orders
  for each row execute function public.set_updated_at();

create index change_orders_contract_idx on public.change_orders (contract_id, order_date);

-- -----------------------------------------------------------------------------
-- certificates — certificados de avance.
--
-- El puente entre el Gantt y la plata: el avance fisico que ya calcula el
-- cronograma, aplicado al contrato, es lo que se puede cobrar este mes.
--
-- El porcentaje se carga a mano a proposito. Certificar es una negociacion, no
-- una cuenta: la pantalla muestra al lado el avance real del cronograma para
-- comparar, pero el numero que se factura lo pone una persona.
--
-- El estado es el circuito real del papel:
--   borrador -> emitido -> aprobado -> facturado -> cobrado
-- -----------------------------------------------------------------------------
create type certificate_status as enum (
  'borrador', 'emitido', 'aprobado', 'facturado', 'cobrado'
);

create table public.certificates (
  id            uuid primary key default gen_random_uuid(),
  project_id    uuid not null references public.projects(id) on delete cascade,
  number        int not null,

  period_from   date,
  period_to     date not null default current_date,
  -- Avance ACUMULADO de obra que reconoce este certificado, no el del periodo.
  progress_pct  numeric(6,4) check (progress_pct is null or (progress_pct >= 0 and progress_pct <= 1)),

  description   text,
  amount        numeric(18,2) not null check (amount > 0),
  currency      currency not null default 'USD',
  fx_usd        numeric(18,4) check (fx_usd is null or fx_usd > 0),
  amount_usd    numeric(18,2) generated always as (
                  case when currency = 'USD' then amount
                       else round(amount / fx_usd, 2) end
                ) stored,

  status        certificate_status not null default 'borrador',
  issued_on     date,
  approved_on   date,
  invoiced_on   date,
  paid_on       date,

  notes         text,
  created_by    uuid references public.profiles(id),
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now(),

  unique (project_id, number),
  constraint certificates_fx_required
    check (currency = 'USD' or fx_usd is not null),
  constraint certificates_period_coherent
    check (period_from is null or period_to >= period_from)
);

create trigger certificates_set_updated_at
  before update on public.certificates
  for each row execute function public.set_updated_at();

create index certificates_project_idx on public.certificates (project_id, number);

-- El cobro de un certificado entra al mismo libro de ingresos que todo lo
-- demas. Un sistema de cobros paralelo seria otro lugar donde el cashflow
-- puede mentir.
alter table public.revenues
  add column certificate_id uuid references public.certificates(id) on delete set null;

create index revenues_certificate_idx on public.revenues (certificate_id);

-- -----------------------------------------------------------------------------
-- Los dos precios, en los gastos y en el presupuesto
-- -----------------------------------------------------------------------------

-- Quien puso la plata de este gasto. En una obra por encargo algunas cosas las
-- paga el estudio y se las cobra al cliente, y otras las paga el cliente
-- directo. Las dos son costo de la obra, pero solo la primera es plata del
-- estudio, y confundirlas infla o desinfla el resultado del estudio.
create type expense_payer as enum ('estudio', 'cliente');

alter table public.expenses
  add column paid_by expense_payer not null default 'estudio',
  -- Lo que se le cobra al cliente por este gasto, en la misma moneda del gasto.
  -- Nulo cuando no se le repica (o cuando la obra es desarrollo propio).
  add column client_amount numeric(18,2)
    check (client_amount is null or client_amount >= 0),
  add column client_amount_usd numeric(18,2) generated always as (
        case when client_amount is null then null
             when currency = 'USD'      then client_amount
             else round(client_amount / fx_usd, 2) end
      ) stored;

comment on column public.expenses.client_amount is
  'Lo que se le cobra al cliente. La diferencia contra el costo es el margen: nunca sale en un reporte para el cliente.';

-- Precio unitario presupuestado AL CLIENTE. El presupuesto interno sigue en
-- price_original_usd: uno es lo que creemos que va a costar, el otro es lo que
-- le dijimos que iba a pagar.
alter table public.budget_lines
  add column price_client_usd numeric(18,4)
    check (price_client_usd is null or price_client_usd >= 0),
  add column total_client_usd numeric(18,2) generated always as (
        case when price_client_usd is null then null
             else round(qty_original * price_client_usd, 2) end
      ) stored;

-- -----------------------------------------------------------------------------
-- project_log — la bitacora.
--
-- Pedidos, decisiones, aprobaciones, visitas y reclamos, con fecha y autor.
-- Es lo que convierte "yo te dije" en un registro.
--
-- with_client separa la comunicacion con el cliente de la nota interna. Una
-- nota interna nunca sale en un reporte: es la misma regla que el margen.
-- -----------------------------------------------------------------------------
create type log_kind as enum (
  'pedido', 'decision', 'aprobacion', 'visita', 'reclamo', 'pago', 'otro'
);

create table public.project_log (
  id              uuid primary key default gen_random_uuid(),
  project_id      uuid not null references public.projects(id) on delete cascade,
  log_date        date not null default current_date,
  kind            log_kind not null default 'otro',
  summary         text not null,
  detail          text,
  with_client     boolean not null default true,
  certificate_id  uuid references public.certificates(id) on delete set null,
  change_order_id uuid references public.change_orders(id) on delete set null,
  author          uuid references public.profiles(id),
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now()
);

create trigger project_log_set_updated_at
  before update on public.project_log
  for each row execute function public.set_updated_at();

create index project_log_project_idx on public.project_log (project_id, log_date desc);

-- =============================================================================
-- VISTAS
-- =============================================================================

-- -----------------------------------------------------------------------------
-- contract_summary — el estado del contrato de un vistazo.
--
-- Contrato vigente = lo firmado mas los adicionales APROBADOS. Los propuestos
-- se muestran aparte porque todavia no son plata.
-- -----------------------------------------------------------------------------
create view public.contract_summary as
select
  c.id                                     as contract_id,
  c.project_id,
  p.code,
  p.name                                   as project_name,
  cl.id                                    as client_id,
  cl.name                                  as client_name,
  c.fee_model,
  c.fee_pct,
  c.fee_amount,
  c.signed_on,
  c.amount_usd                             as contrato_original_usd,
  coalesce(ad.aprobados_usd, 0)            as adicionales_aprobados_usd,
  coalesce(ad.propuestos_usd, 0)           as adicionales_propuestos_usd,
  c.amount_usd + coalesce(ad.aprobados_usd, 0) as contrato_vigente_usd,
  coalesce(ce.certificado_usd, 0)          as certificado_usd,
  coalesce(co.cobrado_usd, 0)              as cobrado_usd,
  c.amount_usd + coalesce(ad.aprobados_usd, 0) - coalesce(ce.certificado_usd, 0)
                                           as por_certificar_usd,
  coalesce(ce.certificado_usd, 0) - coalesce(co.cobrado_usd, 0)
                                           as por_cobrar_usd,
  case when c.amount_usd + coalesce(ad.aprobados_usd, 0) = 0 then null
       else round(coalesce(ce.certificado_usd, 0)
                  / (c.amount_usd + coalesce(ad.aprobados_usd, 0)), 4)
  end                                      as avance_certificado
from public.contracts c
join public.projects p  on p.id  = c.project_id
join public.clients  cl on cl.id = c.client_id
left join lateral (
  select
    sum(amount_usd) filter (where status = 'aprobado')  as aprobados_usd,
    sum(amount_usd) filter (where status = 'propuesto') as propuestos_usd
  from public.change_orders o where o.contract_id = c.id
) ad on true
left join lateral (
  select sum(amount_usd) as certificado_usd
  from public.certificates x
  where x.project_id = c.project_id and x.status <> 'borrador'
) ce on true
left join lateral (
  select sum(amount_usd) as cobrado_usd
  from public.revenues r
  where r.project_id = c.project_id
    and r.kind in ('certificado', 'anticipo', 'honorario')
) co on true;

-- -----------------------------------------------------------------------------
-- project_encargo_pnl — el resultado DEL ESTUDIO en una obra por encargo.
--
-- No confundir con project_pnl, que sigue midiendo el costo de la OBRA
-- completa, la pague quien la pague. Son dos preguntas distintas:
--
--   project_pnl          cuanto costo construir esta casa
--   project_encargo_pnl  cuanto gano el estudio construyendola
--
-- Un gasto que pago el cliente directo es costo de la obra pero no plata del
-- estudio, y meterlo en el resultado del estudio lo hunde sin motivo.
-- -----------------------------------------------------------------------------
create view public.project_encargo_pnl as
select
  p.id                                    as project_id,
  p.code,
  p.name,
  coalesce(g.costo_estudio_usd, 0)        as costo_estudio_usd,
  coalesce(g.costo_cliente_usd, 0)        as costo_cliente_usd,
  coalesce(g.costo_estudio_usd, 0) + coalesce(g.costo_cliente_usd, 0)
                                          as costo_obra_usd,
  coalesce(g.repicado_usd, 0)             as repicado_al_cliente_usd,
  coalesce(i.cobrado_usd, 0)              as cobrado_usd,
  coalesce(i.cobrado_usd, 0) - coalesce(g.costo_estudio_usd, 0)
                                          as resultado_estudio_usd,
  case when coalesce(i.cobrado_usd, 0) = 0 then null
       else round((coalesce(i.cobrado_usd, 0) - coalesce(g.costo_estudio_usd, 0))
                  / i.cobrado_usd, 4)
  end                                     as margen_pct
from public.projects p
left join lateral (
  select
    sum(amount_usd) filter (where paid_by = 'estudio') as costo_estudio_usd,
    sum(amount_usd) filter (where paid_by = 'cliente') as costo_cliente_usd,
    sum(client_amount_usd)                             as repicado_usd
  from public.expenses e where e.project_id = p.id
) g on true
left join lateral (
  select sum(amount_usd) as cobrado_usd
  from public.revenues r
  where r.project_id = p.id
    and r.kind in ('certificado', 'anticipo', 'honorario')
) i on true
where p.model = 'encargo';

-- -----------------------------------------------------------------------------
-- VISTAS PARA EL CLIENTE
--
-- Lo unico que se puede mostrar o imprimir para afuera. No traen costo, no
-- traen margen, no traen proveedor, no traen notas internas. Si algo hay que
-- agregarle a un reporte del cliente, se agrega aca y se piensa dos veces.
-- -----------------------------------------------------------------------------
create view public.project_estado_cliente as
select
  s.project_id,
  s.code,
  s.project_name,
  s.client_name,
  s.signed_on,
  s.contrato_original_usd,
  s.adicionales_aprobados_usd,
  s.contrato_vigente_usd,
  s.certificado_usd,
  s.cobrado_usd,
  s.por_certificar_usd,
  s.por_cobrar_usd,
  s.avance_certificado
from public.contract_summary s;

create view public.presupuesto_cliente as
select
  b.project_id,
  b.id           as budget_line_id,
  b.description,
  b.unit,
  b.qty_original as qty,
  b.price_client_usd,
  b.total_client_usd,
  c.name         as category
from public.budget_lines b
left join public.cost_categories c on c.id = b.category_id
where b.price_client_usd is not null;

create view public.bitacora_cliente as
select
  l.project_id,
  l.log_date,
  l.kind,
  l.summary,
  l.detail
from public.project_log l
where l.with_client;

-- =============================================================================
-- RLS
--
-- No hay rol de cliente: el cliente no entra al sistema. Lo que sale para el
-- son reportes que genera el estudio. Entonces el acceso es el mismo de
-- siempre: lectura para quien tiene acceso al proyecto, escritura para manager
-- o admin.
-- =============================================================================
alter table public.clients       enable row level security;
alter table public.contracts     enable row level security;
alter table public.change_orders enable row level security;
alter table public.certificates  enable row level security;
alter table public.project_log   enable row level security;

create policy clients_select on public.clients
  for select to authenticated using (public.can_read_all());
create policy clients_write on public.clients
  for all to authenticated
  using (public.can_manage()) with check (public.can_manage());

create policy contracts_select on public.contracts
  for select to authenticated using (public.has_project_access(project_id));
create policy contracts_write on public.contracts
  for all to authenticated
  using (public.can_manage()) with check (public.can_manage());

create policy change_orders_select on public.change_orders
  for select to authenticated
  using (exists (
    select 1 from public.contracts c
    where c.id = contract_id and public.has_project_access(c.project_id)
  ));
create policy change_orders_write on public.change_orders
  for all to authenticated
  using (public.can_manage()) with check (public.can_manage());

create policy certificates_select on public.certificates
  for select to authenticated using (public.has_project_access(project_id));
create policy certificates_write on public.certificates
  for all to authenticated
  using (public.can_manage()) with check (public.can_manage());

create policy project_log_select on public.project_log
  for select to authenticated using (public.has_project_access(project_id));
create policy project_log_write on public.project_log
  for all to authenticated
  using (public.can_manage()) with check (public.can_manage());

alter view public.contract_summary        set (security_invoker = on);
alter view public.project_encargo_pnl     set (security_invoker = on);
alter view public.project_estado_cliente  set (security_invoker = on);
alter view public.presupuesto_cliente     set (security_invoker = on);
alter view public.bitacora_cliente        set (security_invoker = on);

grant select on
  public.clients, public.contracts, public.change_orders, public.certificates,
  public.project_log, public.contract_summary, public.project_encargo_pnl,
  public.project_estado_cliente, public.presupuesto_cliente,
  public.bitacora_cliente
  to authenticated;

grant insert, update, delete on
  public.clients, public.contracts, public.change_orders, public.certificates,
  public.project_log
  to authenticated;

-- -----------------------------------------------------------------------------
-- El presupuesto, con el precio al cliente al lado del costo estimado.
--
-- Se agregan columnas al final: create or replace view solo deja APPEND, nunca
-- reordenar ni sacar. Las que ya estaban quedan tal cual.
-- -----------------------------------------------------------------------------
create or replace view public.budget_variance as
select
  b.id                          as budget_line_id,
  b.project_id,
  b.description,
  cp.path                       as categoria,
  b.unit,
  b.qty_original,
  b.price_original_usd,
  b.total_original_usd,
  b.total_forecast_usd,
  coalesce(sum(e.amount_usd) filter (where e.status in ('recibido', 'pagado')), 0)
                                as actual_usd,
  coalesce(sum(e.amount_usd) filter (where e.status = 'comprometido'), 0)
                                as committed_usd,
  b.planned_date,
  t.name                        as actividad,
  greatest(
    b.total_forecast_usd - coalesce(sum(e.amount_usd), 0), 0
  )                             as pendiente_usd,
  b.price_client_usd,
  b.total_client_usd,
  -- Lo que queda para el estudio si se ejecuta como esta presupuestado.
  case when b.total_client_usd is null then null
       else b.total_client_usd - b.total_forecast_usd
  end                           as margen_presupuestado_usd
from public.budget_lines b
left join public.cost_category_paths cp on cp.id = b.category_id
left join public.tasks t on t.id = b.task_id
left join public.expenses e on e.budget_line_id = b.id and e.status <> 'anulado'
group by b.id, b.project_id, b.description, cp.path, b.unit,
         b.qty_original, b.price_original_usd,
         b.total_original_usd, b.total_forecast_usd,
         b.planned_date, t.name, b.price_client_usd, b.total_client_usd;

alter view public.budget_variance set (security_invoker = on);
grant select on public.budget_variance to authenticated;
