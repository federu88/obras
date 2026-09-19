-- =============================================================================
-- 0021_plantilla_obra.sql
--
-- Plantilla de etapas de obra: los pasos estandarizados para construir una
-- casa, con su duracion en dias habiles y si esperan a la etapa anterior o
-- corren en paralelo.
--
-- Sale de la hoja "Actividades" de Construccion Casa_V0.xlsx: 50 etapas en
-- 14 rubros, 230 dias habiles de trabajo encadenado.
--
-- La plantilla es UNA sola y se edita como cualquier otro catalogo. Cada obra
-- la instancia con su propia fecha de inicio: aplicarla genera las tareas del
-- cronograma con las fechas ya calculadas, salteando fines de semana y
-- feriados. Despues cada obra las edita por su cuenta sin afectar la plantilla.
-- =============================================================================

create table public.task_templates (
  id          uuid primary key default gen_random_uuid(),
  sort_order  int not null,
  category    text not null,
  name        text not null,
  planned_days int not null check (planned_days > 0),
  -- true: arranca cuando termina la anterior. false: corre en paralelo con ella.
  chained     boolean not null default true,
  notes       text,
  is_active   boolean not null default true,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

create trigger task_templates_set_updated_at
  before update on public.task_templates
  for each row execute function public.set_updated_at();

create index task_templates_orden_idx on public.task_templates (sort_order);

insert into public.task_templates (sort_order, category, name, planned_days, chained) values
  (1, 'Tareas preliminares', 'Cerco de obra', 5, true),
  (2, 'Tareas preliminares', 'Rampa', 5, true),
  (3, 'Tareas preliminares', 'Obrador', 5, true),
  (4, 'Etapa pilotes', 'Armado de hierros', 2, true),
  (5, 'Etapa pilotes', 'Pozos de pilotes', 1, true),
  (6, 'Etapa pilotes', 'Hormigonado pilotes', 1, true),
  (7, 'Encadenado de fundación', 'Armado de vigas', 3, true),
  (8, 'Encadenado de fundación', 'Zanjeo', 5, true),
  (9, 'Encadenado de fundación', 'Hormigonado de vigas', 3, true),
  (10, 'Plomero', 'Etapa I armado de Cloaca', 1, true),
  (11, 'Etapa mampostería', 'Cajón hidrofugo', 2, true),
  (12, 'Etapa mampostería', 'Revocado de cajón hidrofugo con ceresita', 2, true),
  (13, 'Etapa mampostería', 'Mampostería de paredes', 20, true),
  (14, 'Etapa mampostería', 'Hormigonado de columnas', 2, true),
  (15, 'Etapa mampostería', 'Hormigonado de vigas de encadenado', 10, true),
  (16, 'Losa', 'Posicionamiento de viguetas sobre encadenado', 2, true),
  (17, 'Losa', 'Ladrillo de telgopor', 2, true),
  (18, 'Losa', 'Malla de 6mm', 1, true),
  (19, 'Electricista', 'Caneria electrica en losa', 1, true),
  (20, 'Losa', 'Hormigonado de losa', 3, true),
  (21, 'Losa', 'Mampostería de carga', 4, true),
  (22, 'Comienzo de revoques exteriores', 'Revoque hidrofugo', 15, true),
  (23, 'Electricista', 'Distribución eléctrica interior y exterior', 5, false),
  (24, 'Plomero', 'Distribución instalación de agua fría y caliente y cloaca interior', 10, false),
  (25, 'Comienzo de revoques interiores', 'Revoque a la cal', 15, false),
  (26, 'Plomero', 'Desagües de aires y colector de losa radiante', 2, true),
  (27, 'Comienzo de contrapiso interior', 'Apisonamiento de tosca', 5, false),
  (28, 'Comienzo de contrapiso interior', 'Desapuntalamiento de losa', 1, false),
  (29, 'Comienzo de contrapiso interior', 'Contrapiso con cascote', 5, false),
  (30, 'Comienzo de contrapiso interior', 'Carpeta hidrofuga con ceresita', 3, false),
  (31, 'Comienzo de contrapiso interior', 'Recuadran los vanos para medición de carpinterías', 5, false),
  (32, 'Plomero', 'Se realiza la instalación de gas.', 2, false),
  (33, 'Comienzo de contrapiso interior', 'Contrapiso con pendiente, hidrofugo y carpeta sobre techo', 10, true),
  (34, 'Plomero', 'Losa radiante', 3, true),
  (35, 'Etapa mampostería', 'Hormigonado de losa radiante', 3, true),
  (36, 'Etapa mampostería', 'Carpeta para colocacion', 3, true),
  (37, 'Etapa terminaciones', 'Blanqueo de paredes con enduido', 5, true),
  (38, 'Etapa terminaciones', 'Colocación de pisos', 10, true),
  (39, 'Etapa terminaciones', 'Veredas exteriores y rampas', 5, true),
  (40, 'Cerramientos', 'Colocación de ventanas y puertas', 5, false),
  (41, 'Etapa terminaciones', 'Cierlorraso de yeso aplicado', 5, false),
  (42, 'Etapa terminaciones', 'Pintura en paredes', 10, false),
  (43, 'Etapa terminaciones', 'Revestimiento plástico en paredes exteriores', 5, false),
  (44, 'Etapa terminaciones', 'Membrana liquida en losa', 1, false),
  (45, 'Herreria', 'Colocacion de pergolas', 5, true),
  (46, 'Herreria', 'Colocación de pluviales', 1, true),
  (47, 'Plomero', 'Colocacion de artefactos sanitarios', 2, true),
  (48, 'Electricista', 'Colocación de artefactos eléctricos', 3, true),
  (49, 'Arquitecto', 'Puesta en marcha', 1, true),
  (50, 'Arquitecto', 'Final de obra', 5, true);

-- -----------------------------------------------------------------------------
-- aplicar_plantilla_obra — instancia la plantilla en una obra.
--
-- Encadenada: arranca el dia habil siguiente al fin de la anterior.
-- En paralelo: arranca el mismo dia que la anterior, porque no la espera.
--
-- No pisa lo que ya haya: si la obra ya tiene actividades, se agregan al final.
-- -----------------------------------------------------------------------------
create or replace function public.aplicar_plantilla_obra(
  p_project uuid,
  p_inicio  date
)
returns int
language plpgsql
security invoker
as $fn$
declare
  t             record;
  v_inicio      date := p_inicio;
  v_inicio_prev date := p_inicio;
  v_fin         date;
  v_base        int;
  v_n           int := 0;
begin
  if p_inicio is null then
    raise exception 'Hace falta una fecha de inicio para aplicar la plantilla';
  end if;

  select coalesce(max(sort_order), 0) into v_base
  from public.tasks where project_id = p_project;

  for t in
    select * from public.task_templates where is_active order by sort_order
  loop
    if v_n = 0 then
      v_inicio := p_inicio;
    elsif t.chained then
      v_inicio := public.add_workdays(v_fin, 1);
    else
      v_inicio := v_inicio_prev;
    end if;

    v_fin := public.add_workdays(v_inicio, t.planned_days - 1);

    insert into public.tasks
           (project_id, category, name, sort_order, planned_start, planned_days)
    values (p_project, t.category, t.name, v_base + t.sort_order, v_inicio, t.planned_days);

    v_inicio_prev := v_inicio;
    v_n := v_n + 1;
  end loop;

  return v_n;
end;
$fn$;

grant execute on function public.aplicar_plantilla_obra(uuid, date) to authenticated;

-- -----------------------------------------------------------------------------
-- RLS: la plantilla la lee cualquier autenticado y la edita manager o admin.
-- -----------------------------------------------------------------------------
alter table public.task_templates enable row level security;

create policy task_templates_select on public.task_templates
  for select to authenticated using (true);

create policy task_templates_write on public.task_templates
  for all to authenticated
  using (public.can_manage()) with check (public.can_manage());

grant select on public.task_templates to authenticated;
grant insert, update, delete on public.task_templates to authenticated;