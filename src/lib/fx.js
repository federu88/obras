import { supabase } from './supabase'

/**
 * Sincronización del tipo de cambio.
 *
 * El modelo en Excel escribe el FX a mano en cada fila (1400 en un archivo,
 * 1435 en otro), que es el origen de que el presupuesto en USD no cierre.
 * Acá la cotización se trae sola de una fuente pública y queda con su fecha.
 *
 * Se usa el MEP (dólar bolsa), que es la referencia que ya venías usando, y el
 * valor de VENTA: es el precio al que habrías comprado los dólares, así que es
 * el que corresponde para valuar un gasto en pesos.
 *
 * APIs públicas, gratuitas y sin credenciales:
 *   https://dolarapi.com/v1/dolares/bolsa                       (hoy)
 *   https://api.argentinadatos.com/v1/cotizaciones/dolares/bolsa/AAAA/MM/DD
 */

const HOY_URL = 'https://dolarapi.com/v1/dolares/bolsa'
const HIST_URL = 'https://api.argentinadatos.com/v1/cotizaciones/dolares/bolsa'

const iso = (d) => d.toISOString().slice(0, 10)

/** Guarda una cotización. Si ya existe la de esa fecha y fuente, la pisa. */
async function upsert(rate_date, ars_per_usd, note) {
  const { error } = await supabase
    .from('fx_rates')
    .upsert(
      { rate_date, source: 'MEP', ars_per_usd, note },
      { onConflict: 'rate_date,source' }
    )
  if (error) throw new Error(error.message)
}

/** ¿Ya tenemos la cotización de esta fecha? */
async function existe(rate_date) {
  const { data, error } = await supabase
    .from('fx_rates')
    .select('rate_date')
    .eq('rate_date', rate_date)
    .eq('source', 'MEP')
    .maybeSingle()
  if (error) throw new Error(error.message)
  return Boolean(data)
}

/**
 * Trae la cotización de hoy si todavía no está cargada.
 * Devuelve el valor guardado, o null si no hizo falta o no se pudo.
 *
 * Silencia los errores a propósito: es una comodidad de fondo, no puede
 * romper el arranque de la app. Si falla, el usuario carga el valor a mano.
 */
export async function syncHoy() {
  const hoy = iso(new Date())
  try {
    if (await existe(hoy)) return null

    const res = await fetch(HOY_URL)
    if (!res.ok) return null
    const json = await res.json()
    const valor = Number(json?.venta)
    if (!valor || Number.isNaN(valor)) return null

    await upsert(hoy, valor, 'MEP venta · dolarapi.com')
    return valor
  } catch {
    return null
  }
}

/**
 * Carga el histórico de los últimos `dias` días que falten.
 * Lo usa el botón de la pantalla de configuración.
 *
 * Va de a una fecha porque la API es por día. Saltea fines de semana: no
 * cotizan, y fx_rate_at() arrastra la última cotización disponible.
 */
export async function backfill(dias = 90, onProgress) {
  const hoy = new Date()
  let cargadas = 0
  let saltadas = 0

  for (let i = 0; i < dias; i++) {
    const d = new Date(hoy)
    d.setDate(d.getDate() - i)

    // Sábado y domingo no cotizan.
    if (d.getDay() === 0 || d.getDay() === 6) continue

    const fecha = iso(d)
    try {
      if (await existe(fecha)) {
        saltadas++
        continue
      }
      const [y, m, dd] = fecha.split('-')
      const res = await fetch(`${HIST_URL}/${y}/${m}/${dd}`)
      if (!res.ok) continue
      const json = await res.json()
      const valor = Number(json?.venta)
      if (!valor || Number.isNaN(valor)) continue

      await upsert(fecha, valor, 'MEP venta · argentinadatos.com')
      cargadas++
    } catch {
      /* una fecha que falla no interrumpe el resto */
    }
    onProgress?.({ cargadas, saltadas, revisadas: i + 1, total: dias })
  }

  return { cargadas, saltadas }
}
