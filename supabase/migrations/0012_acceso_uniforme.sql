-- =============================================================================
-- 0012_acceso_uniforme.sql
--
-- Todos los usuarios con el mismo acceso, decidido el 2026-09-18 porque por
-- ahora los unicos usuarios son el equipo de trabajo.
--
-- IMPORTANTE: esto NO desarma la RLS. Las policies siguen intactas y siguen
-- distinguiendo roles; lo unico que cambia es que todos los usuarios tienen el
-- mismo rol, asi que todas evaluan verdadero para todos. Volver atras es
-- cambiar el rol de una fila, no reescribir la seguridad.
--
-- El dia que entre el primer inversor con usuario propio, hay que ponerle rol
-- 'investor' ANTES de que inicie sesion. Si queda en 'admin' va a ver cuanto
-- puso cada otro inversor, los precios de todos los proveedores, la caja
-- completa y el margen del negocio.
-- =============================================================================

-- Los usuarios nuevos nacen con acceso total.
alter table public.profiles
  alter column role set default 'admin';

-- Y los que ya existen quedan igualados.
update public.profiles
set role = 'admin'
where role <> 'admin';

comment on column public.profiles.role is
  'Rol global. Default admin: por ahora todos los usuarios son el equipo de '
  'trabajo. A un inversor con usuario propio hay que ponerle rol investor '
  'ANTES de su primer inicio de sesion.';
