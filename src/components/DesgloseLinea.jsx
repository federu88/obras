import { useEffect, useState } from 'react'
import { useAsync } from '../lib/useAsync'
import {
  listExpenseItems,
  listItemSuggestions,
  guardarItemsLinea,
  getLaborDetail,
  saveLaborDetail,
  deleteLaborDetail,
} from '../lib/queries'
import { COST_TYPES, TIPOS_CON_MANO_DE_OBRA, LABOR_MODALITY } from '../lib/costos'
import { Drawer, Field, ErrorBox } from './ui'

const fmt = new Intl.NumberFormat('es-AR', { minimumFractionDigits: 2, maximumFractionDigits: 2 })
const filaVacia = () => ({ key: crypto.randomUUID(), item_id: '', description: '', qty: '1', unit: 'un', unit_price: '' })

/**
 * Desglose de una línea de gasto, editable cuando se quiera.
 *
 * Es opcional: una línea vale por su monto, y el desglose explica de qué está
 * hecho. Por eso no tiene que sumar exacto; si no coincide, se avisa.
 *
 * El autocompletado mezcla el catálogo (que trae el ítem enlazado, con su
 * historial de precios) con todo lo que ya se escribió a mano.
 */
export default function DesgloseLinea({ linea, onClose, onSaved }) {
  const sugerencias = useAsync(listItemSuggestions)
  const [filas, setFilas] = useState(null)
  const [labor, setLabor] = useState(null)
  const [saving, setSaving] = useState(false)
  const [error, setError] = useState(null)

  const conManoDeObra = TIPOS_CON_MANO_DE_OBRA.includes(linea.cost_type)
  const monto = Number(linea.qty) * Number(linea.unit_price)

  useEffect(() => {
    let cancelado = false
    Promise.all([listExpenseItems(linea.id), conManoDeObra ? getLaborDetail(linea.id) : null])
      .then(([items, lab]) => {
        if (cancelado) return
        setFilas(
          items.length
            ? items.map((it) => ({
                key: it.id,
                item_id: it.item_id ?? '',
                description: it.description,
                qty: String(it.qty),
                unit: it.unit,
                unit_price: String(it.unit_price),
              }))
            : [filaVacia()]
        )
        setLabor(
          lab
            ? { ...lab, progress: lab.progress_pct == null ? '' : String(Math.round(lab.progress_pct * 100)) }
            : { modality: 'jornal', worker: '', progress: '', is_advance: false }
        )
      })
      .catch((err) => !cancelado && setError(err.message))
    return () => { cancelado = true }
  }, [linea.id, conManoDeObra])

  const opciones = sugerencias.data ?? []

  function setFila(key, k, valor) {
    setFilas((fs) =>
      fs.map((f) => {
        if (f.key !== key) return f
        const nueva = { ...f, [k]: valor }
        if (k === 'description') {
          /* Si lo escrito coincide con una sugerencia, se enlaza el ítem del
             catálogo y se completa la unidad (y el último precio, si hay). */
          const s = opciones.find((o) => o.description.toLowerCase() === valor.toLowerCase())
          nueva.item_id = s?.item_id ?? ''
          if (s) {
            nueva.unit = s.unit ?? nueva.unit
            if (!f.unit_price && s.ultimo_precio != null && s.moneda === linea.currency) {
              nueva.unit_price = String(s.ultimo_precio)
            }
          }
        }
        return nueva
      })
    )
  }

  const sumaItems = (filas ?? []).reduce((a, f) => a + Number(f.qty || 0) * Number(f.unit_price || 0), 0)
  const hayItems = (filas ?? []).some((f) => f.description.trim())

  async function submit() {
    setSaving(true)
    setError(null)
    try {
      await guardarItemsLinea(
        linea.id,
        filas
          .filter((f) => f.description.trim())
          .map((f) => ({
            item_id: f.item_id || null,
            description: f.description.trim(),
            qty: f.qty,
            unit: f.unit,
            unit_price: f.unit_price,
          }))
      )
      if (conManoDeObra) {
        if (labor.worker.trim()) {
          await saveLaborDetail({
            expense_id: linea.id,
            modality: labor.modality,
            worker: labor.worker.trim(),
            progress_pct: labor.progress === '' ? null : Number(labor.progress) / 100,
            is_advance: labor.is_advance,
          })
        } else {
          await deleteLaborDetail(linea.id)
        }
      }
      onSaved?.()
      onClose()
    } catch (err) {
      setError(err.message)
    } finally {
      setSaving(false)
    }
  }

  return (
    <Drawer title="Desglose de la línea" submitLabel="Guardar desglose" onClose={onClose} onSubmit={submit} submitting={saving}>
      {error && <ErrorBox message={error} />}

      <div className="notice">
        <strong>{linea.rubro?.name ?? 'Sin rubro'} · {COST_TYPES[linea.cost_type] ?? linea.cost_type}</strong>
        {' — '}{linea.description} · {fmt.format(monto)} {linea.currency}
      </div>

      {filas == null ? (
        <p style={{ color: 'var(--text-muted)' }}>Cargando…</p>
      ) : (
        <>
          <datalist id="sugerencias-items">
            {opciones.map((o, i) => (
              <option key={`${o.origen}-${o.item_id ?? i}`} value={o.description}>
                {o.origen === 'catalogo' ? 'Catálogo' : `Usado ${o.usos} ${o.usos === 1 ? 'vez' : 'veces'}`} · {o.unit}
              </option>
            ))}
          </datalist>

          {filas.map((f) => (
            <div key={f.key} className="card campos" style={{ display: 'grid', gap: 8, padding: 12 }}>
              <div style={{ display: 'flex', gap: 8, alignItems: 'center' }}>
                <input
                  list="sugerencias-items"
                  placeholder="Descripción"
                  value={f.description}
                  onChange={(e) => setFila(f.key, 'description', e.target.value)}
                  style={{ flex: 1 }}
                  aria-label="Descripción"
                />
                {f.item_id && <span className="badge badge-ok" title="Enlazado al catálogo">catálogo</span>}
                <button type="button" className="icon-btn" onClick={() => setFilas((fs) => (fs.length > 1 ? fs.filter((x) => x.key !== f.key) : [filaVacia()]))}>
                  Quitar
                </button>
              </div>
              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1.4fr', gap: 8 }}>
                <input type="number" step="0.0001" min="0.0001" placeholder="Cant." value={f.qty} onChange={(e) => setFila(f.key, 'qty', e.target.value)} aria-label="Cantidad" />
                <input placeholder="Unidad" value={f.unit} onChange={(e) => setFila(f.key, 'unit', e.target.value)} aria-label="Unidad" />
                <input type="number" step="0.01" min="0" placeholder="Precio unit." value={f.unit_price} onChange={(e) => setFila(f.key, 'unit_price', e.target.value)} aria-label="Precio unitario" />
              </div>
            </div>
          ))}
          <button type="button" className="btn" onClick={() => setFilas((fs) => [...fs, filaVacia()])}>
            + Otro ítem
          </button>

          {hayItems && Math.abs(sumaItems - monto) >= 0.01 && (
            <div className="notice notice-warning">
              Los ítems suman {fmt.format(sumaItems)} y la línea es de {fmt.format(monto)}. El
              desglose explica la línea, no la cambia: si el monto está mal, se corrige en la línea.
            </div>
          )}

          {conManoDeObra && labor && (
            <>
              <h3 style={{ margin: '8px 0 0', fontSize: '0.9375rem' }}>Mano de obra</h3>
              <Field label="Trabajador o cuadrilla" hint="Vacío = sin detalle de mano de obra.">
                <input value={labor.worker} onChange={(e) => setLabor((l) => ({ ...l, worker: e.target.value }))} />
              </Field>
              <Field label="Modalidad">
                <select value={labor.modality} onChange={(e) => setLabor((l) => ({ ...l, modality: e.target.value }))}>
                  {Object.entries(LABOR_MODALITY).map(([k, l]) => <option key={k} value={k}>{l}</option>)}
                </select>
              </Field>
              <Field label="Avance acumulado (%)">
                <input type="number" min="0" max="100" step="1" value={labor.progress} onChange={(e) => setLabor((l) => ({ ...l, progress: e.target.value }))} />
              </Field>
              <label style={{ display: 'flex', gap: 8, alignItems: 'center' }}>
                <input type="checkbox" checked={labor.is_advance} onChange={(e) => setLabor((l) => ({ ...l, is_advance: e.target.checked }))} />
                Es un adelanto
              </label>
            </>
          )}
        </>
      )}
    </Drawer>
  )
}
