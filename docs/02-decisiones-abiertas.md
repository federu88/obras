# Decisiones abiertas

Puntos sin definir al 2026-09-18. Ninguno bloquea la Fase 1. Los marcados con ⚠️
afectan el esquema de fases posteriores y conviene cerrarlos antes de esa fase.

| # | Decisión | Estado | Afecta |
|---|---|---|---|
| 1 | Cuánto aportó cada uno de los 5 inversores | Sin dato | ⚠️ Fase 2 |
| 2 | FX: ¿cotización de la operación real o MEP de referencia? | **Supuesto tomado** | Fase 3 |
| 3 | Importes negativos (−41.110, −200.000): ¿notas de crédito o error? | Sin definir | Fase 4 |
| 4 | Honorarios del arquitecto: ¿USD 8.000 fijos o un %? | **Supuesto tomado** | ⚠️ Fase 3 |
| 5 | El lote: ¿costo del proyecto o aporte de capital en especie? | Sin definir | ⚠️ Fase 2 |
| 6 | Obras 84 y 583: ¿migrar como histórico o solo referencia? | Recomendación dada | Fase 3 |
| 7 | Préstamos al personal: ¿cuenta a cobrar o fuera del sistema? | Sin definir | Fase 3 |
| 8 | Gastos de escritura y venta: monto o % | Sin dato | Fase 3 |

## Supuestos tomados para no frenar la Fase 1

Elegidos de modo que la respuesta definitiva **no obligue a migrar datos**.

**#2 — Tipo de cambio.** Cada movimiento guarda `monto`, `moneda`, `fx_usd` y fecha.
Si existe la operación de cambio real se usa esa cotización; si no, la de referencia
del día desde `fx_rates`. La estructura sirve para ambas respuestas: cambia qué fila
de `fx_rates` se elige, no el esquema.

**#4 — Honorarios del arquitecto.** Modelados como costo con categoría propia. Si
resultan ser un porcentaje sobre venta, pasa a ser un valor de configuración del
proyecto (como `broker_fee_pct`, que ya existe con default 0,04). No cambia tablas.

## Brechas resueltas

**Caja en transferencias entre proyectos** — detectado el 2026-09-18 en Fase 2,
resuelto el mismo dia en la migracion `0007_cashflow.sql`.
La vista `capital_effects` asigna `cash_delta = 0` a `reinversion` y
`transferencia`. Eso es correcto para el capital —el destino recibe, el origen
conserva su capital aportado— pero no para la caja: si el dinero sale
físicamente de la cuenta del proyecto origen, el cashflow de ese proyecto debe
bajar y el del destino subir.

El obstáculo es estructural: cada movimiento es una fila con un solo
`project_id`, así que no puede expresar −30.000 en origen y +30.000 en destino
a la vez. La salida prevista es una vista que expanda cada movimiento entre
proyectos en dos filas con signo opuesto, una por proyecto.

Se resuelve en **Fase 3**, junto con el cashflow. Antes hay que definir el
punto 7 de la tabla de arriba y si cada obra tiene caja propia o hay una caja
común, como ocurre hoy en la planilla de los lotes 84 y 583.

## Recomendaciones pendientes de confirmación

**#6 — Obras 84 y 583.** Recomiendo cargarlas como referencia y no migrar sus
movimientos. Las fechas de origen están corruptas (día/mes invertidos, fechas como
texto) y contaminarían toda serie temporal del sistema nuevo. El resultado histórico
se puede cargar como un único registro de cierre por obra.

**#5 — El lote.** Si el lote lo aportó un inversor, es capital en especie y debe
aparecer en su posición. Si se compró con la caja del proyecto, es costo. Hoy figura
como item del catálogo (`Tram-1`, USD 41.068,85), que corresponde al segundo caso,
pero conviene confirmarlo porque cambia el cálculo de participación.
