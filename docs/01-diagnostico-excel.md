# Diagnóstico de las planillas de origen

Análisis del 2026-09-18 sobre las tres planillas en uso. Este documento existe para
que las decisiones del modelo de datos sean rastreables: cada corrección responde a
un problema concreto encontrado acá.

## Las tres fuentes

No son versiones de lo mismo. Son tres capas que hoy no se comunican.

| Archivo | Rol | Contenido |
|---|---|---|
| `Construccion Casa_V0.xlsx` | Modelo / plantilla | Catálogo de 225 items, presupuesto vs real por item, Gantt con días hábiles y feriados, curva de avance |
| `Gastos SR84 y 583_Presupuesto1.4.xlsx` | Ejecución real | Caja ARS (9.988.670) y USD (124.100), gastos diarios, jornales, expensas, gestoría de dos lotes |
| `Resultados Construccion casa.xlsx` | Business case | 5 inversores, 2 casas, resultado objetivo USD 49.600 |

## El business case

```
Por casa:  Venta            180.000
           Construcción    -140.000
           Inmobiliaria 4%   -7.200
           Arquitecto        -8.000
           Escritura         (sin definir)
           ─────────────────────────
           Resultado         24.800     → 13,8 % sobre venta
Dos casas: 49.600
```

Los cinco inversores figuran con concepto "Inversión" y **monto en blanco**. Hoy no
existe registro de cuánto aportó cada uno. Esa es la razón de fondo por la que no se
puede responder "¿cuánto tiene cada inversor?", y el primer problema que resuelve
este sistema.

## Problemas detectados

Ordenados por gravedad. Los cuatro primeros afectan números, no comodidad.

1. **Presupuesto en USD mal calculado.** En la hoja `Cashflow`,
   `Total USD Presupuesto = Importe Unitario × Cantidad` usa el importe **nominal**
   (ARS en 224 de 225 items), mientras que `Total USD Real` sí convierte. Budget vs
   Actual compara pesos contra dólares.
   → *Corrección:* todo importe se guarda como `monto` + `moneda` + `fx_usd`, y el
   valor en dólares es derivado, nunca tipeado.

2. **Tipo de cambio fijo en 1400** en todas las filas, mientras la caja real registra
   cada operación a su cotización (1185, 1165, 1100, 1095, 1050, 1200, 1205…).
   → *Corrección:* tabla `fx_rates` con fecha y fuente, y función `fx_rate_at()`.

3. **La hoja `Resultados` no es de construcción.** Es un P&L de *Crewing Services*
   con los buques HYSY 721 y Victory G, heredado de otro modelo, lleno de `#REF!`.
   Las hojas `Resumen Projecto`, `P&L -->`, `Caja` y `Catalogo Historico` están
   vacías. El modelo nunca tuvo P&L funcional.
   → *Corrección:* el P&L es una vista calculada, no una hoja mantenida a mano.

4. **Fechas corruptas.** Conviven fechas reales con texto (`28/11/2024`, `16/1/2025`)
   y hay inversión día/mes: "Expensas mes diciembre" figura como 2024-02-12, "mes
   abril" como 2025-10-04. Toda serie temporal derivada es falsa.
   → *Corrección:* tipo `date` en Postgres. La ambigüedad deja de ser posible.

5. **Catálogo sin precios.** 225 items con `Precio Unitario` = 0 salvo el lote
   (USD 41.068,85).

6. **Unidades inservibles.** Los 225 items tienen unidad `"Uni"`. Sin m², kg o m³ no
   hay cálculo de consumo ni comparación real de precios entre proveedores.

7. **Proveedores sin normalizar.** 15 valores, de los cuales `"TBD"` son 90 (40 %).
   Teléfonos dentro del nombre (`Juan -+54 9 230 450-4450`), genéricos (`Corralon`).

8. **Importes negativos en costos reales** (−41.110, −200.000). Notas de crédito o
   errores de signo: sin definir.

9. **Columna CAC vacía.** Había intención de indexar por Cámara Argentina de la
   Construcción; quedó sin implementar.

10. **Avance ponderado por días, no por costo:**
    `% = días hábiles de la actividad / total de días hábiles`. Criterio válido, pero
    el avance físico no dice nada del avance económico.
    → *Corrección:* se mantiene, y se agrega avance económico como métrica separada.

11. **Personas y conceptos mezclados.** La lista "Sub-Categoría" contiene inversores
    (Federico, Daniel, Gonzalo, Miguel, Joaco, M Eugenia) junto a conceptos de costo
    (Lote, Cuota 1, Acopio Corralón, Eléctrica).
    → *Corrección:* capital y costos son dimensiones distintas.

12. **Dos obras en un solo juego de planillas.** Los lotes 84 y 583 comparten caja,
    jornales y gestoría, separados por una columna `lote` a menudo vacía.

13. **Préstamos al personal mezclados con costo** (Roberto 300.000, Lautaro 100.000,
    pipi 200.000). Un adelanto es un activo a recuperar, no un gasto.

## Lo que se conserva

- USD como moneda funcional.
- La conversión por operación de cambio real, con su cotización y fecha.
- La jerarquía Categoría → Subcategoría → Item, con código derivado
  (`Tram-1`, `Pilo-2`, `Viga-13`).
- Presupuesto vs real a nivel de item, no de rubro.
- Gantt con días hábiles y el calendario de feriados argentinos 2025–2026.
- Curva de avance planificada vs real.
- La estructura del P&L: venta − construcción − 4 % inmobiliaria − honorarios −
  escritura.
