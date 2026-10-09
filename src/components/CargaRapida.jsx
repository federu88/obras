import { useRef, useState } from 'react'
import { useAsync } from '../lib/useAsync'
import {
  listProjectRubros,
  listSuppliers,
  listItems,
  guardarComprobante,
  uploadReceiptPhoto,
  fxRateAt,
} from '../lib/queries'
import {
  COST_TYPES,
  TIPOS_CON_MANO_DE_OBRA,
  LABOR_MODALITY,
  PAYMENT_METHOD,
  leerUltimaCombinacion,
  guardarUltimaCombinacion,
} from '../lib/costos'
import { usd, ars } from '../lib/format'
import { ErrorBox } from './ui'

const hoyIso = () => new Date().toISOString().slice(0, 10)

const EXTRA_VACIO = {
  receipt_date: hoyIso(),
  supplier_id: '',
  note: '',
  item_id: '',
  number: '',
  payment_method: '',
  paid_by: 'estudio',
  worker: '',
  modality: 'jornal',
  progress: '',
  is_advance: false,
}

/**
 * Carga rápida de un gasto, pensada para el celular en la obra.
 *
 * Rubro, tipo, monto, guardar: cuatro toques. Todo lo demás es opcional y vive
 * plegado en "Más datos". Al guardar se conservan rubro, tipo, fecha y
 * proveedor, porque en una jornada se cargan varios gastos seguidos de lo
 * mismo; lo único que cambia suele ser el monto.
 *
 * Cada carga es un comprobante de una línea. Si el papel tiene varios rubros,
 * se carga desde la pestaña Gastos de la obra.
 */
export default function CargaRapida({ projectId, encargo = false, onSaved }) {
  const rubros = useAsync(
    () => (projectId ? listProjectRubros(projectId) : Promise.resolve([])),
    [projectId]
  )
  const suppliers = useAsync(listSuppliers)
  const items = useAsync(listItems)

  /* Arranca con la última combinación usada en esta obra. El padre monta un
     componente nuevo por obra (key), así que esto se lee una vez por obra. */
  const [rubroId, setRubroId] = useState(() => leerUltimaCombinacion(projectId).rubroId ?? '')
  const [tipo, setTipo] = useState(() => leerUltimaCombinacion(projectId).tipo ?? 'materiales')
  const [monto, setMonto] = useState('')
  const [currency, setCurrency] = useState('ARS')
  const [extra, setExtra] = useState(EXTRA_VACIO)
  const [foto, setFoto] = useState(null)
  const [masDatos, setMasDatos] = useState(false)
  /* Precio de referencia del ítem elegido: se marca hasta que lo pisen. */
  const [sugerido, setSugerido] = useState(null)
  const [guardando, setGuardando] = useState(false)
  const [error, setError] = useState(null)
  const [ultimo, setUltimo] = useState(null)
  const montoRef = useRef(null)
  const fotoRef = useRef(null)

  const activos = (rubros.data ?? []).filter((r) => r.is_active)

  /* Si el rubro recordado ya no existe o se ocultó, cuenta como no elegido. */
  const rubroElegido = activos.some((r) => r.id === rubroId) ? rubroId : ''

  const setE = (k) => (e) =>
    setExtra((f) => ({ ...f, [k]: e.target.type === 'checkbox' ? e.target.checked : e.target.value }))

  const conManoDeObra = TIPOS_CON_MANO_DE_OBRA.includes(tipo)

  async function elegirItem(itemId) {
    const it = (items.data ?? []).find((i) => i.item_id === itemId)
    if (!it) {
      setSugerido(null)
      setExtra((f) => ({ ...f, item_id: '' }))
      return
    }
    /* Lo último que se pagó vale más que un promedio o una cotización. */
    const ref =
      it.ultimo_precio_comprado_usd != null
        ? { usd: Number(it.ultimo_precio_comprado_usd), origen: 'última compra' }
        : it.ultimo_precio_cotizado_usd != null
          ? { usd: Number(it.ultimo_precio_cotizado_usd), origen: 'última cotización' }
          : it.precio_promedio_usd != null
            ? { usd: Number(it.precio_promedio_usd), origen: 'promedio histórico' }
            : null

    let valor = ''
    if (ref) {
      if (currency === 'USD') valor = String(Math.round(ref.usd * 100) / 100)
      else {
        const fx = await fxRateAt(extra.receipt_date)
        if (fx) valor = String(Math.round(ref.usd * Number(fx)))
      }
    }
    setSugerido(ref && valor ? ref : null)
    if (valor) setMonto(valor)
    setExtra((f) => ({ ...f, item_id: itemId, note: f.note || it.description }))
  }

  async function guardar(e) {
    e.preventDefault()
    if (!rubroElegido) return setError('Elegí un rubro.')
    setGuardando(true)
    setError(null)
    try {
      const fx = currency === 'ARS' ? await fxRateAt(extra.receipt_date) : null
      if (currency === 'ARS' && !fx) {
        throw new Error(
          'No hay cotización cargada para esa fecha ni anterior. Cargá una en Finanzas → Dólar.'
        )
      }

      const importe = Number(monto)
      const item = (items.data ?? []).find((i) => i.item_id === extra.item_id)
      const proveedor = (suppliers.data ?? []).find((s) => s.id === extra.supplier_id)

      const linea = {
        project_rubro_id: rubroElegido,
        cost_type: tipo,
        amount: importe,
        note: extra.note || null,
        /* Un ítem del catálogo queda como desglose de una unidad: así entra
           al historial de precios sin pedirle a nadie que desglose. */
        items: item
          ? [{ item_id: item.item_id, description: item.description, qty: 1, unit: item.unit ?? 'un', unit_price: importe }]
          : [],
        labor:
          conManoDeObra && extra.worker.trim()
            ? {
                modality: extra.modality,
                worker: extra.worker.trim(),
                progress_pct: extra.progress === '' ? null : Number(extra.progress) / 100,
                is_advance: extra.is_advance,
              }
            : null,
      }

      const receiptId = await guardarComprobante(
        {
          project_id: projectId,
          receipt_date: extra.receipt_date,
          total: importe,
          currency,
          fx_usd: fx,
          supplier_id: extra.supplier_id || null,
          supplier_name: proveedor?.name ?? null,
          number: extra.number || null,
          payment_method: extra.payment_method || null,
          paid_by: encargo ? extra.paid_by : 'estudio',
        },
        [linea]
      )

      /* La foto va después porque su ruta lleva el id del comprobante. Si
         falla, el gasto ya quedó: se avisa, no se pierde la carga. */
      let avisoFoto = null
      if (foto) {
        try {
          await uploadReceiptPhoto(projectId, receiptId, foto)
        } catch (err) {
          avisoFoto = `El gasto se guardó, pero la foto no se pudo subir: ${err.message}`
        }
      }

      guardarUltimaCombinacion(projectId, { rubroId: rubroElegido, tipo })
      const rubro = activos.find((r) => r.id === rubroElegido)
      setUltimo({
        texto: `${currency === 'USD' ? usd(importe) : ars(importe)} en ${rubro?.name} · ${COST_TYPES[tipo]}`,
        avisoFoto,
      })
      setMonto('')
      setSugerido(null)
      setFoto(null)
      if (fotoRef.current) fotoRef.current.value = ''
      setExtra((f) => ({ ...EXTRA_VACIO, receipt_date: f.receipt_date, supplier_id: f.supplier_id, paid_by: f.paid_by, worker: f.worker, modality: f.modality }))
      montoRef.current?.focus()
      onSaved?.()
    } catch (err) {
      setError(err.message)
    } finally {
      setGuardando(false)
    }
  }

  return (
    <form className="card" onSubmit={guardar} style={{ display: 'grid', gap: 16 }}>
      <h2 style={{ fontSize: '1rem', margin: 0 }}>Cargar gasto</h2>

      {error && <ErrorBox message={error} />}
      {ultimo && (
        <div className={`notice${ultimo.avisoFoto ? ' notice-warning' : ''}`}>
          Guardado: <strong>{ultimo.texto}</strong>.{ultimo.avisoFoto && <> {ultimo.avisoFoto}</>}
        </div>
      )}

      <div className="field">
        <label>Rubro</label>
        {rubros.loading ? (
          <span style={{ color: 'var(--text-muted)' }}>Cargando rubros…</span>
        ) : (
          <div className="chips" role="group" aria-label="Rubro">
            {activos.map((r) => (
              <button
                key={r.id}
                type="button"
                className="chip"
                aria-pressed={r.id === rubroElegido}
                onClick={() => setRubroId(r.id)}
              >
                {r.name}
              </button>
            ))}
          </div>
        )}
      </div>

      <div className="field">
        <label>Tipo de costo</label>
        <div className="chips" role="group" aria-label="Tipo de costo">
          {Object.entries(COST_TYPES).map(([k, label]) => (
            <button key={k} type="button" className="chip" aria-pressed={k === tipo} onClick={() => setTipo(k)}>
              {label}
            </button>
          ))}
        </div>
      </div>

      <div className="field">
        <label htmlFor="carga-monto">
          Monto
          {sugerido && (
            <span style={{ color: 'var(--warning)', fontWeight: 600 }}>
              {' '}· sugerido por {sugerido.origen}
            </span>
          )}
        </label>
        <div style={{ display: 'flex', gap: 8, alignItems: 'stretch' }}>
          <input
            id="carga-monto"
            ref={montoRef}
            className="monto-grande"
            type="number"
            inputMode="decimal"
            step="0.01"
            min="0.01"
            required
            placeholder="0"
            value={monto}
            onChange={(e) => { setSugerido(null); setMonto(e.target.value) }}
            style={sugerido ? { borderColor: 'var(--warning)', background: 'var(--warning-soft)' } : undefined}
          />
          <div className="chips" role="group" aria-label="Moneda" style={{ flexWrap: 'nowrap' }}>
            {['ARS', 'USD'].map((m) => (
              <button key={m} type="button" className="chip" aria-pressed={m === currency} onClick={() => setCurrency(m)}>
                {m}
              </button>
            ))}
          </div>
        </div>
      </div>

      <button
        type="button"
        className="icon-btn"
        onClick={() => setMasDatos((v) => !v)}
        aria-expanded={masDatos}
        style={{ justifySelf: 'start', padding: 0 }}
      >
        {masDatos ? '− Menos datos' : '+ Más datos: fecha, proveedor, foto…'}
      </button>

      {masDatos && (
        <div style={{ display: 'grid', gap: 12, gridTemplateColumns: 'repeat(auto-fit, minmax(180px, 1fr))' }}>
          <div className="field">
            <label>Fecha</label>
            <input type="date" required value={extra.receipt_date} onChange={setE('receipt_date')} />
          </div>
          <div className="field">
            <label>Proveedor</label>
            <select value={extra.supplier_id} onChange={setE('supplier_id')}>
              <option value="">—</option>
              {(suppliers.data ?? []).map((s) => (
                <option key={s.id} value={s.id}>{s.name}</option>
              ))}
            </select>
          </div>
          <div className="field">
            <label>Ítem del catálogo</label>
            <select value={extra.item_id} onChange={(e) => elegirItem(e.target.value)}>
              <option value="">Sin ítem</option>
              {(items.data ?? []).map((i) => (
                <option key={i.item_id} value={i.item_id}>{i.code} · {i.description}</option>
              ))}
            </select>
          </div>
          <div className="field">
            <label>Concepto</label>
            <input value={extra.note} onChange={setE('note')} placeholder="Ej: Hierro del 8 · 20 barras" />
          </div>
          <div className="field">
            <label>N° de comprobante</label>
            <input value={extra.number} onChange={setE('number')} />
          </div>
          <div className="field">
            <label>Medio de pago</label>
            <select value={extra.payment_method} onChange={setE('payment_method')}>
              <option value="">—</option>
              {Object.entries(PAYMENT_METHOD).map(([k, l]) => <option key={k} value={k}>{l}</option>)}
            </select>
          </div>
          {encargo && (
            <div className="field">
              <label>Lo pagó</label>
              <select value={extra.paid_by} onChange={setE('paid_by')}>
                <option value="estudio">El estudio</option>
                <option value="cliente">El cliente, directo</option>
              </select>
            </div>
          )}
          <div className="field">
            <label>Foto del comprobante</label>
            <input
              ref={fotoRef}
              type="file"
              accept="image/*,application/pdf"
              capture="environment"
              onChange={(e) => setFoto(e.target.files?.[0] ?? null)}
            />
          </div>

          {conManoDeObra && (
            <>
              <div className="field">
                <label>Trabajador o cuadrilla</label>
                <input value={extra.worker} onChange={setE('worker')} placeholder="Opcional" />
              </div>
              <div className="field">
                <label>Modalidad</label>
                <select value={extra.modality} onChange={setE('modality')}>
                  {Object.entries(LABOR_MODALITY).map(([k, l]) => <option key={k} value={k}>{l}</option>)}
                </select>
              </div>
              <div className="field">
                <label>Avance acumulado (%)</label>
                <input type="number" min="0" max="100" step="1" value={extra.progress} onChange={setE('progress')} />
              </div>
              <label style={{ display: 'flex', gap: 8, alignItems: 'center', alignSelf: 'end', paddingBottom: 10 }}>
                <input type="checkbox" checked={extra.is_advance} onChange={setE('is_advance')} />
                Es un adelanto
              </label>
            </>
          )}
        </div>
      )}

      <button
        className="btn btn-primary"
        type="submit"
        disabled={guardando || !projectId || !rubroElegido}
        style={{ minHeight: 48, fontSize: '1rem' }}
      >
        {guardando ? 'Guardando…' : 'Guardar gasto'}
      </button>
    </form>
  )
}
