-- Los gastos se pueden borrar, no solo anular.
--
-- 0005 los dejaba sin delete a proposito ("se anulan o se corrigen"). Ahora la
-- pantalla de Gastos permite borrarlos, uno o varios a la vez. La politica
-- expenses_write ya es "for all" con can_manage(), asi que solo falta el
-- privilegio: un rol sin can_manage() sigue sin poder borrar.
--
-- Lo que queda: el trigger expenses_audit registra el borrado con la fila
-- completa, y los movimientos de caja y documentos que apuntaban al gasto
-- quedan sin gasto (on delete set null), no se borran.

grant delete on public.expenses to authenticated;
