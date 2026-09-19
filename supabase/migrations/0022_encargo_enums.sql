-- =============================================================================
-- 0022_encargo_enums.sql
--
-- Valores de enum nuevos, solos en su propia migracion.
--
-- Postgres no deja USAR un valor de enum en la misma transaccion en que se lo
-- agrega. Por eso esto va separado de 0023, que si los usa. Es la misma razon
-- por la que 0013 y 0014 estan partidos.
-- =============================================================================

-- Los cobros de una obra por encargo no son "venta": son certificados de avance
-- y honorarios. Van al mismo libro de ingresos que el resto para que el
-- cashflow y el P&L los vean sin un sistema paralelo.
alter type revenue_kind add value if not exists 'certificado';
alter type revenue_kind add value if not exists 'honorario';
