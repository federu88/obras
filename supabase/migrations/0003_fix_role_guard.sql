-- =============================================================================
-- 0003_fix_role_guard.sql
--
-- Corrige prevent_self_role_change() de la migracion 0002.
--
-- La version original bloqueaba cualquier cambio de rol hecho por alguien que
-- no fuera admin, incluido el bootstrap: el SQL Editor y las migraciones
-- corren sin usuario autenticado, asi que auth.uid() es null, is_admin() da
-- false y el trigger saltaba. Con eso el PRIMER admin no se podia crear.
--
-- El guard existe para proteger la superficie de la API, no el acceso
-- privilegiado a la base. Si no hay auth.uid(), el cambio viene del SQL
-- Editor, de una migracion o de service_role, que ya son contextos de
-- confianza y ademas saltean RLS por definicion.
-- =============================================================================

create or replace function public.prevent_self_role_change()
returns trigger
language plpgsql
security definer
set search_path = public
as $fn$
begin
  if new.role is distinct from old.role
     and auth.uid() is not null
     and not public.is_admin()
  then
    raise exception 'Solo un admin puede cambiar el rol de un usuario';
  end if;
  return new;
end;
$fn$;
