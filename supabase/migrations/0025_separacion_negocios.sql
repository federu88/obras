-- =============================================================================
-- 0025_separacion_negocios.sql
--
-- Separar los dos negocios: el del pool de socios y el del estudio.
--
-- Son dos cosas distintas y no tienen por que verse entre si. Un inversor pone
-- plata en las casas que se construyen para vender; lo que el estudio gana
-- construyendole a un tercero no es asunto suyo, y al reves tampoco.
--
-- LA SEPARACION ES DE ACCESO, NO DE PANTALLA
-- Tener dos dashboards no protege nada: la API esta igual de disponible y una
-- consulta directa devuelve todo lo que la RLS permita. Por eso la regla vive
-- en has_project_access(), que es por donde pasan projects, expenses, revenues,
-- budget_lines, tasks, certificates, documents y todo lo demas. Cambiarla en un
-- solo lugar alcanza para todo el sistema; si estuviera repetida en cada tabla,
-- el dia que se agregue una tabla nueva alguien se va a olvidar.
--
-- Y no depende de la higiene de project_members: aunque a un inversor lo
-- agreguen por error como miembro de una obra por encargo, no la ve igual.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Quien es "el estudio". Las obras por encargo son suyas.
--
-- Viewer queda afuera a proposito: es un rol de mirar, y el margen del estudio
-- no es algo que haya que mirar de paso. Si manana hace falta un viewer del
-- lado del estudio, se agrega un rol, no se ensancha este.
-- -----------------------------------------------------------------------------
create or replace function public.can_see_encargo()
returns boolean
language sql
stable
security definer
set search_path = public
as $fn$
  select coalesce(public.current_app_role() in ('admin', 'manager'), false)
$fn$;

grant execute on function public.can_see_encargo() to authenticated;

-- -----------------------------------------------------------------------------
-- has_project_access — ahora mira tambien de que negocio es la obra.
--
-- Dos condiciones, y hacen falta las dos:
--   1. el negocio: una obra por encargo solo la ve el estudio
--   2. el alcance: acceso global, o ser miembro de esa obra
--
-- Sigue siendo SECURITY DEFINER para poder leer projects y project_members sin
-- disparar la RLS que ella misma resuelve. Si no, la policy de projects se
-- llamaria a si misma.
-- -----------------------------------------------------------------------------
create or replace function public.has_project_access(p_project uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $fn$
  select exists (
    select 1
    from public.projects p
    where p.id = p_project
      and (p.model <> 'encargo' or public.can_see_encargo())
      and (
        public.can_read_all()
        or exists (
          select 1 from public.project_members m
          where m.project_id = p.id and m.user_id = auth.uid()
        )
      )
  )
$fn$;

comment on function public.has_project_access(uuid) is
  'Unico lugar donde se decide quien ve una obra. Un id inexistente o nulo da '
  'falso, y una obra por encargo solo la ve el estudio.';

-- -----------------------------------------------------------------------------
-- Las tablas del encargo, ademas, se cierran por su cuenta.
--
-- Redundante con has_project_access() y esta bien que lo sea: son las tablas
-- donde esta el margen. Una regla de mas no molesta; una de menos se nota tarde.
-- -----------------------------------------------------------------------------
drop policy if exists clients_select on public.clients;
create policy clients_select on public.clients
  for select to authenticated
  using (public.can_see_encargo());

drop policy if exists contracts_select on public.contracts;
create policy contracts_select on public.contracts
  for select to authenticated
  using (public.can_see_encargo() and public.has_project_access(project_id));

-- =============================================================================
-- VISTAS
-- =============================================================================

-- -----------------------------------------------------------------------------
-- business_summary — de ahora en mas, SOLO el desarrollo propio.
--
-- Es un cambio de significado, no un agregado. Antes sumaba todas las obras;
-- desde aca cuenta unicamente las que se construyen para vender. Mezclarlas
-- nunca tuvo sentido: capital aportado, profit pendiente y profit reinvertido
-- son conceptos del pool de socios, y una obra por encargo no tiene nada de
-- eso. El resultado del estudio vive en encargo_summary.
--
-- Los movimientos de capital sin proyecto cuentan como desarrollo: el capital
-- ES del pool, no del estudio.
-- -----------------------------------------------------------------------------
create or replace view public.business_summary as
with capital as (
  select
    coalesce(sum(m.amount_usd) filter (where m.type = 'aporte'), 0)             as aportado,
    coalesce(sum(m.amount_usd) filter (where m.type = 'retiro'), 0)             as retirado,
    coalesce(sum(m.amount_usd) filter (where m.type = 'profit_asignado'), 0)    as profit_asignado,
    coalesce(sum(m.amount_usd) filter (where m.type = 'profit_distribuido'), 0) as profit_distribuido,
    coalesce(sum(m.amount_usd) filter (where m.type = 'reinversion'), 0)        as reinvertido
  from public.capital_movements m
  left join public.projects p on p.id = m.project_id
  where m.status = 'confirmado'
    and coalesce(p.model, 'desarrollo') = 'desarrollo'
),
caja as (
  select coalesce(sum(c.amount_usd), 0) as realizada
  from public.cash_flows c
  left join public.projects p on p.id = c.project_id
  where c.scope = 'realizado'
    and coalesce(p.model, 'desarrollo') = 'desarrollo'
),
costos as (
  select
    coalesce(sum(e.amount_usd) filter (where e.status in ('recibido', 'pagado')), 0) as actual,
    coalesce(sum(e.amount_usd) filter (where e.status = 'comprometido'), 0)          as comprometido
  from public.expenses e
  join public.projects p on p.id = e.project_id
  where e.status <> 'anulado' and p.model = 'desarrollo'
),
ingresos as (
  select coalesce(sum(r.amount_usd), 0) as total
  from public.revenues r
  join public.projects p on p.id = r.project_id
  where p.model = 'desarrollo'
),
proyectos as (
  select
    count(*) filter (where status in ('aprobado', 'en_construccion'))     as activos,
    count(*) filter (where status in ('terminado', 'vendido', 'cerrado')) as terminados,
    count(*)                                                              as total
  from public.projects
  where model = 'desarrollo'
),
pnl as (
  select coalesce(sum(n.forecast_profit_usd), 0) as profit_proyectado
  from public.project_pnl n
  join public.projects p on p.id = n.project_id
  where p.model = 'desarrollo'
)
select
  capital.aportado                                    as capital_aportado_usd,
  capital.retirado                                    as capital_retirado_usd,
  capital.aportado - capital.retirado + capital.reinvertido
                                                      as capital_invertido_usd,
  capital.profit_asignado - capital.profit_distribuido - capital.reinvertido
                                                      as profit_pendiente_usd,
  capital.profit_distribuido                          as profit_realizado_usd,
  capital.reinvertido                                 as profit_reinvertido_usd,
  caja.realizada                                      as caja_usd,
  costos.comprometido                                 as comprometido_usd,
  caja.realizada - costos.comprometido                as capital_disponible_usd,
  costos.actual                                       as costo_actual_usd,
  ingresos.total                                      as ingresos_usd,
  ingresos.total - costos.actual                      as resultado_acumulado_usd,
  pnl.profit_proyectado                               as profit_proyectado_usd,
  proyectos.activos                                   as proyectos_activos,
  proyectos.terminados                                as proyectos_terminados,
  proyectos.total                                     as proyectos_total
from capital, caja, costos, ingresos, proyectos, pnl;

-- -----------------------------------------------------------------------------
-- encargo_summary — el negocio del estudio, en una fila.
--
-- No son los mismos indicadores con otro filtro: son otros indicadores. Aca no
-- hay capital aportado ni profit a repartir. Hay contratos, avance certificado
-- y plata que el estudio adelanto y todavia no cobro.
-- -----------------------------------------------------------------------------
create view public.encargo_summary as
with obras as (
  select count(*)                                                       as total,
         count(*) filter (where status in ('aprobado', 'en_construccion')) as activas
  from public.projects where model = 'encargo'
),
contratos as (
  select
    coalesce(sum(contrato_vigente_usd), 0)        as vigente,
    coalesce(sum(certificado_usd), 0)             as certificado,
    coalesce(sum(cobrado_usd), 0)                 as cobrado,
    coalesce(sum(por_certificar_usd), 0)          as por_certificar,
    coalesce(sum(por_cobrar_usd), 0)              as por_cobrar,
    coalesce(sum(adicionales_propuestos_usd), 0)  as adicionales_pendientes
  from public.contract_summary
),
resultado as (
  select
    coalesce(sum(costo_estudio_usd), 0)     as puso_estudio,
    coalesce(sum(costo_cliente_usd), 0)     as puso_cliente,
    coalesce(sum(costo_obra_usd), 0)        as costo_obra,
    coalesce(sum(resultado_estudio_usd), 0) as resultado
  from public.project_encargo_pnl
)
select
  obras.total                    as obras_total,
  obras.activas                  as obras_activas,
  contratos.vigente              as contrato_vigente_usd,
  contratos.certificado          as certificado_usd,
  contratos.cobrado              as cobrado_usd,
  contratos.por_certificar       as por_certificar_usd,
  contratos.por_cobrar           as por_cobrar_usd,
  contratos.adicionales_pendientes as adicionales_pendientes_usd,
  resultado.puso_estudio         as puso_estudio_usd,
  resultado.puso_cliente         as puso_cliente_usd,
  resultado.costo_obra           as costo_obra_usd,
  resultado.resultado            as resultado_estudio_usd,
  case when contratos.cobrado = 0 then null
       else round(resultado.resultado / contratos.cobrado, 4)
  end                            as margen_pct,
  -- Plata del estudio metida en obra que el cliente todavia no devolvio.
  resultado.puso_estudio - contratos.cobrado as adelantado_usd
from obras, contratos, resultado;

-- -----------------------------------------------------------------------------
-- project_health — se le agrega el modelo, para poder mirar un negocio a la vez.
-- Columna al final: create or replace view solo deja append.
-- -----------------------------------------------------------------------------
create or replace view public.project_health as
select
  p.project_id,
  p.code,
  p.name,
  p.status,
  p.budget_usd,
  p.actual_cost_usd,
  p.forecast_cost_usd,
  p.committed_cost_usd,
  p.revenue_usd,
  p.forecast_profit_usd,
  case when p.budget_usd > 0
       then round((p.forecast_cost_usd - p.budget_usd) / p.budget_usd, 4)
  end                                    as desvio_costo_rel,
  pr.avance_planificado,
  pr.avance_real,
  pr.demoradas,
  pr.fin_plan,
  pr.fin_proyectado,
  (p.budget_usd > 0 and p.forecast_cost_usd > p.budget_usd * 1.05)
                                         as problema_costo,
  (coalesce(pr.avance_real, 0) < coalesce(pr.avance_planificado, 0) - 0.05
   or coalesce(pr.demoradas, 0) > 0)     as problema_plazo,
  pj.model
from public.project_pnl p
left join public.project_progress pr on pr.project_id = p.project_id
join public.projects pj on pj.id = p.project_id;

-- -----------------------------------------------------------------------------
-- encargo_health — una fila por obra por encargo, con lo que hay que mirar.
--
-- El aviso importante es el ultimo: obra ejecutada sin certificar es plata que
-- el estudio puso y todavia no puede pedir.
-- -----------------------------------------------------------------------------
create view public.encargo_health as
select
  s.project_id,
  s.code,
  s.project_name                as name,
  s.client_name,
  s.contrato_vigente_usd,
  s.certificado_usd,
  s.cobrado_usd,
  s.por_cobrar_usd,
  s.adicionales_propuestos_usd,
  s.avance_certificado,
  pr.avance_real,
  e.costo_estudio_usd,
  e.resultado_estudio_usd,
  -- Avance fisico que ya se hizo y todavia no se certifico.
  case when pr.avance_real is null or s.avance_certificado is null then null
       else round(pr.avance_real - s.avance_certificado, 4)
  end                           as sin_certificar_rel,
  (coalesce(pr.avance_real, 0) - coalesce(s.avance_certificado, 0) > 0.05)
                                as problema_certificacion,
  (s.adicionales_propuestos_usd > 0)
                                as adicionales_sin_decidir
from public.contract_summary s
left join public.project_progress pr on pr.project_id = s.project_id
left join public.project_encargo_pnl e on e.project_id = s.project_id;

-- -----------------------------------------------------------------------------
-- RLS de las vistas nuevas
-- -----------------------------------------------------------------------------
alter view public.business_summary set (security_invoker = on);
alter view public.project_health   set (security_invoker = on);
alter view public.encargo_summary  set (security_invoker = on);
alter view public.encargo_health   set (security_invoker = on);

grant select on
  public.business_summary, public.project_health,
  public.encargo_summary, public.encargo_health
  to authenticated;
