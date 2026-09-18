/**
 * Formateo y cálculo monetario — fuente única.
 *
 * Regla del proyecto: ningún componente define su propia fórmula ni su propio
 * formato. El modelo en Excel terminó con "Total USD Presupuesto" calculado
 * sobre importes nominales en pesos y "Total USD Real" sí convertido; ese bug
 * nace de tener la misma cuenta escrita en dos lados.
 */

const USD = new Intl.NumberFormat('es-AR', {
  style: 'currency',
  currency: 'USD',
  maximumFractionDigits: 0,
})

const ARS = new Intl.NumberFormat('es-AR', {
  style: 'currency',
  currency: 'ARS',
  maximumFractionDigits: 0,
})

const PCT = new Intl.NumberFormat('es-AR', {
  style: 'percent',
  minimumFractionDigits: 1,
  maximumFractionDigits: 1,
})

const DATE = new Intl.DateTimeFormat('es-AR', {
  day: '2-digit',
  month: '2-digit',
  year: 'numeric',
})

/** Importe en dólares. La moneda funcional del negocio. */
export function usd(value) {
  if (value == null || Number.isNaN(Number(value))) return '—'
  return USD.format(Number(value))
}

/** Importe en pesos. Moneda transaccional, nunca unidad de medida. */
export function ars(value) {
  if (value == null || Number.isNaN(Number(value))) return '—'
  return ARS.format(Number(value))
}

/** Porcentaje. Espera la fracción (0.138), no el número (13,8). */
export function pct(value) {
  if (value == null || Number.isNaN(Number(value))) return '—'
  return PCT.format(Number(value))
}

/**
 * Fecha. Siempre ISO hacia adentro, dd/mm/aaaa hacia afuera.
 * Las planillas actuales mezclan fechas reales con texto ("28/11/2024") y
 * tienen día y mes invertidos en varias filas; acá la ambigüedad no existe.
 */
export function date(value) {
  if (!value) return '—'
  const d = value instanceof Date ? value : new Date(value)
  return Number.isNaN(d.getTime()) ? '—' : DATE.format(d)
}

/**
 * Convierte un importe a dólares.
 * @param {number} amount   importe en su moneda original
 * @param {'ARS'|'USD'} currency
 * @param {number} fxRate   pesos por dólar aplicable a la fecha del movimiento
 */
export function toUsd(amount, currency, fxRate) {
  if (amount == null) return null
  if (currency === 'USD') return Number(amount)
  if (!fxRate) return null
  return Number(amount) / Number(fxRate)
}

/**
 * Desvío contra una referencia. Devuelve absoluto y relativo juntos para que
 * ninguna pantalla los calcule por separado.
 */
export function variance(actual, baseline) {
  if (actual == null || baseline == null) return { abs: null, rel: null }
  const abs = Number(actual) - Number(baseline)
  const rel = Number(baseline) === 0 ? null : abs / Number(baseline)
  return { abs, rel }
}
