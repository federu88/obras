-- =============================================================================
-- 0002_rls.sql  ·  Fase 1 — Row Level Security
--
-- Regla de la casa: NINGUNA tabla lleva `using (true)`. Cada policy nombra
-- explicitamente quien ve que. Los inversores solo alcanzan los proyectos
-- donde son miembros.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Helpers. Son SECURITY DEFINER a proposito: leen profiles / project_members
-- salteando RLS y asi evitan la recursion infinita que se produce cuando una
-- policy sobre una tabla necesita consultar esa misma tabla.
-- -----------------------------------------------------------------------------
create or replace function public.current_app_role()
returns app_role
language sql
stable
security definer
set search_path = public
as $fn$
  select role
  from public.profiles
  where id = auth.uid() and is_active
$fn$;

create or replace function public.is_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $fn$
  select coalesce(public.current_app_role() = 'admin', false)
$fn$;

-- Puede escribir datos operativos (proyectos, presupuestos, compras...).
create or replace function public.can_manage()
returns boolean
language sql
stable
security definer
set search_path = public
as $fn$
  select coalesce(public.current_app_role() in ('admin', 'manager'), false)
$fn$;

-- Lectura global: admin, manager y viewer ven todo el negocio.
-- El rol investor NO: solo alcanza sus proyectos.
create or replace function public.can_read_all()
returns boolean
language sql
stable
security definer
set search_path = public
as $fn$
  select coalesce(public.current_app_role() in ('admin', 'manager', 'viewer'), false)
$fn$;

-- Acceso a UN proyecto: lectura global, o membresia explicita.
create or replace function public.has_project_access(p_project uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $fn$
  select public.can_read_all()
      or exists (
        select 1 from public.project_members
        where project_id = p_project and user_id = auth.uid()
      )
$fn$;

-- -----------------------------------------------------------------------------
-- Activacion
-- -----------------------------------------------------------------------------
alter table public.profiles        enable row level security;
alter table public.projects        enable row level security;
alter table public.project_members enable row level security;
alter table public.fx_rates        enable row level security;
alter table public.audit_log       enable row level security;

-- -----------------------------------------------------------------------------
-- profiles
-- -----------------------------------------------------------------------------
create policy profiles_select_own on public.profiles
  for select to authenticated
  using (id = auth.uid() or public.can_read_all());

-- El usuario edita su propio perfil, pero NO su rol: eso se controla en
-- profiles_no_self_promotion.
create policy profiles_update_own on public.profiles
  for update to authenticated
  using (id = auth.uid())
  with check (id = auth.uid());

create policy profiles_admin_all on public.profiles
  for all to authenticated
  using (public.is_admin())
  with check (public.is_admin());

-- Impide que alguien se cambie el rol a si mismo editando su perfil.
create or replace function public.prevent_self_role_change()
returns trigger
language plpgsql
security definer
set search_path = public
as $fn$
begin
  if new.role is distinct from old.role and not public.is_admin() then
    raise exception 'Solo un admin puede cambiar el rol de un usuario';
  end if;
  return new;
end;
$fn$;

create trigger profiles_no_self_promotion
  before update on public.profiles
  for each row execute function public.prevent_self_role_change();

-- -----------------------------------------------------------------------------
-- projects
-- -----------------------------------------------------------------------------
create policy projects_select on public.projects
  for select to authenticated
  using (public.has_project_access(id));

create policy projects_write on public.projects
  for all to authenticated
  using (public.can_manage())
  with check (public.can_manage());

-- -----------------------------------------------------------------------------
-- project_members
-- -----------------------------------------------------------------------------
create policy project_members_select on public.project_members
  for select to authenticated
  using (user_id = auth.uid() or public.can_read_all());

create policy project_members_write on public.project_members
  for all to authenticated
  using (public.can_manage())
  with check (public.can_manage());

-- -----------------------------------------------------------------------------
-- fx_rates — todos los autenticados leen (hace falta para mostrar importes),
-- solo manager/admin escriben.
-- -----------------------------------------------------------------------------
create policy fx_rates_select on public.fx_rates
  for select to authenticated
  using (true);

create policy fx_rates_write on public.fx_rates
  for all to authenticated
  using (public.can_manage())
  with check (public.can_manage());

-- -----------------------------------------------------------------------------
-- audit_log — solo admin lee. Nadie escribe directo: lo hace el trigger,
-- que es SECURITY DEFINER y por eso no necesita policy de insert.
-- -----------------------------------------------------------------------------
create policy audit_log_select on public.audit_log
  for select to authenticated
  using (public.is_admin());

-- -----------------------------------------------------------------------------
-- Privilegios. Sin `grant all`: cada rol recibe lo minimo.
-- La RLS filtra filas; los grants limitan operaciones.
-- -----------------------------------------------------------------------------
revoke all on all tables in schema public from anon, authenticated;

grant select on public.profiles, public.projects, public.project_members,
                public.fx_rates, public.audit_log to authenticated;

grant insert, update on public.profiles to authenticated;
grant insert, update, delete on public.projects, public.project_members,
                                 public.fx_rates to authenticated;

-- Las tablas nuevas NO heredan permisos abiertos: cada migracion futura
-- debe otorgarlos explicitamente. Esto es lo contrario de lo que hace hoy
-- el Supabase de Integra con su `alter default privileges`.
alter default privileges in schema public revoke all on tables from anon, authenticated;

-- anon no tiene absolutamente nada: la app entera exige sesion.
revoke all on schema public from anon;
