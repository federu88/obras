import { useEffect, useState } from 'react'
import { useAsync } from '../lib/useAsync'
import {
  listProjectRubros,
  listSuppliers,
  guardarComprobante,
  uploadReceiptPhoto,
  fxRateAt,
} from '../lib/queries'
import { COST_TYPES, PAYMENT_METHOD } from '../lib/costos'
import { Drawer, Field, ErrorBox } from './ui'

const hoyIso = () => new Date().toISOString().slice(0, 10)
const lineaVacia = () => ({ key: crypto.randomUUID(), project_rubro_id: '', cost_type: 'materiales', amount: '', note: '' })

const fmt = new Intl.NumberFormat('es-AR', { minimumFractionDigits: 2, maximumFractionDigits: 2 })

/**
 * Alta de un comprobante con varias líneas.
 *
 * Un papel puede repartirse entre rubros: la factura del corralón trae hierro
 * para la estructura y ladrillos para la mampostería. Cada línea es un gasto
 * con su rubro y su tipo; el comprobante solo los agrupa. Las líneas no
 * pueden pasarse del total, y lo que falte asignar se muestra mientras se
 * carga, no después.
 */
export default function ComprobanteForm({ projectId, encargo = false, onClose, onSaved }) {
  const rubros = useAsync(() => listProjectRubros(projectId), [projectId])
  const suppliers = useAsync(listSuppliers)

  const [form, setForm] = useState({
    receipt_date: hoyIso(),
    supplier_id: '',
    number: '',
    payment_method: '',
    currency: 'ARS',
    fx_usd: '',
    total: '',
    paid_by: 'estudio',
    status: 'pagado',
  })
  const [lineas, setLineas] = useState([lineaVacia()])
  const [foto, setFoto] = useState(null)
  const [saving, setSaving] = useState(false)
  const [error, setError] = useState(null)

  const set = (k) => (e) => setForm((f) => ({ ...f, [k]: e.target.value }))
  const setLinea = (key, k) => (e) =>
    setLineas((ls) => ls.map((l) => (l.key === key ? { ...l, [k]: e.target.value } : l)))

  /* Se sugiere la cotización de la fecha sin pisar la que ya se escribió. */
  useEffect(() => {
    if (form.currency !== 'ARS' || !form.receipt_date) return
    let cancelado = false
    fxRateAt(form.receipt_date)
      .then((r) => {
        if (!cancelado && r) setForm((f) => (f.fx_usd ? f : { ...f, fx_usd: String(r) }))
      })
      .catch(() => {})
    return () => { cancelado = true }
  }, [form.currency, form.receipt_date])

  const activos = (rubros.data ?? []).filter((r) => r.is_active)
  const suma = lineas.reduce((a, l) => a + Number(l.amount || 0), 0)
  const total = form.total === '' ? suma : Number(form.total)
  const diferencia = Math.round((total - suma) * 100) / 100

  async function submit() {
    setSaving(true)
    setError(null)
    try {
      if (diferencia < 0) throw new Error(`Las líneas se pasan del total por ${fmt.format(-diferencia)}.`)
      if (lineas.some((l) => !l.project_rubro_id)) throw new Error('Cada línea necesita un rubro.')

      const proveedor = (suppliers.data ?? []).find((s) => s.id === form.supplier_id)
      const receiptId = await guardarComprobante(
        {
          project_id: projectId,
          receipt_date: form.receipt_date,
          total,
          currency: form.currency,
          fx_usd: form.currency === 'ARS' ? Number(form.fx_usd) : null,
          supplier_id: form.supplier_id || null,
          supplier_name: proveedor?.name ?? null,
          number: form.number || null,
          payment_method: form.payment_method || null,
          status: form.status,
          paid_by: encargo ? form.paid_by : 'estudio',
        },
        lineas.map((l) => ({
          project_rubro_id: l.project_rubro_id,
          cost_type: l.cost_type,
          amount: Number(l.amount),
          note: l.note || null,
        }))
      )

      if (foto) {
        try {
          await uploadReceiptPhoto(projectId, receiptId, foto)
        } catch (err) {
          /* El comprobante ya quedó: se avisa y se puede subir la foto después. */
          onSaved?.()
          throw new Error(`El comprobante se guardó, pero la foto no se pudo subir: ${err.message}`)
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
    <Drawer title="Nuevo comprobante" submitLabel="Guardar comprobante" onClose={onClose} onSubmit={submit} submitting={saving}>
      {error && <ErrorBox message={error} />}

      <Field label="Fecha">
        <input type="date" required value={form.receipt_date} onChange={set('receipt_date')} />
      </Field>

      <Field label="Proveedor">
        <select value={form.supplier_id} onChange={set('supplier_id')}>
          <option value="">—</option>
          {(suppliers.data ?? []).map((s) => (
            <option key={s.id} value={s.id}>{s.name}</option>
          ))}
        </select>
      </Field>

      <Field label="N° de comprobante">
        <input value={form.number} onChange={set('number')} />
      </Field>

      <Field label="Medio de pago">
        <select value={form.payment_method} onChange={set('payment_method')}>
          <option value="">—</option>
          {Object.entries(PAYMENT_METHOD).map(([k, l]) => <option key={k} value={k}>{l}</option>)}
        </select>
      </Field>

      <Field label="Moneda">
        <select value={form.currency} onChange={set('currency')}>
          <option value="ARS">ARS</option>
          <option value="USD">USD</option>
        </select>
      </Field>

      {form.currency === 'ARS' && (
        <Field label="Cotización (ARS por USD)" hint="Sugerida por la fecha. Cambiala si se pagó a otro cambio.">
          <input type="number" step="0.0001" min="0.0001" required value={form.fx_usd} onChange={set('fx_usd')} />
        </Field>
      )}

      <Field label="Total del comprobante" hint="Vacío = la suma de las líneas.">
        <input type="number" step="0.01" min="0.01" value={form.total} onChange={set('total')} placeholder={suma ? fmt.format(suma) : ''} />
      </Field>

      <Field label="Estado">
        <select value={form.status} onChange={set('status')}>
          <option value="pagado">Pagado</option>
          <option value="recibido">Recibido, sin pagar</option>
        </select>
      </Field>

      {encargo && (
        <Field label="Lo pagó">
          <select value={form.paid_by} onChange={set('paid_by')}>
            <option value="estudio">El estudio</option>
            <option value="cliente">El cliente, directo</option>
          </select>
        </Field>
      )}

      <Field label="Foto del comprobante">
        <input type="file" accept="image/*,application/pdf" capture="environment" onChange={(e) => setFoto(e.target.files?.[0] ?? null)} />
      </Field>

      <div style={{ display: 'grid', gap: 10 }}>
        <h3 style={{ margin: 0, fontSize: '0.9375rem' }}>Líneas</h3>
        {lineas.map((l, i) => (
          <div key={l.key} className="card campos" style={{ display: 'grid', gap: 8, padding: 12 }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
              <strong style={{ fontSize: '0.8125rem' }}>Línea {i + 1}</strong>
              {lineas.length > 1 && (
                <button type="button" className="icon-btn" onClick={() => setLineas((ls) => ls.filter((x) => x.key !== l.key))}>
                  Quitar
                </button>
              )}
            </div>
            <select required value={l.project_rubro_id} onChange={setLinea(l.key, 'project_rubro_id')} aria-label="Rubro">
              <option value="">Rubro…</option>
              {activos.map((r) => <option key={r.id} value={r.id}>{r.name}</option>)}
            </select>
            <select value={l.cost_type} onChange={setLinea(l.key, 'cost_type')} aria-label="Tipo de costo">
              {Object.entries(COST_TYPES).map(([k, label]) => <option key={k} value={k}>{label}</option>)}
            </select>
            <input type="number" required step="0.01" min="0.01" placeholder="Monto" value={l.amount} onChange={setLinea(l.key, 'amount')} aria-label="Monto" />
            <input placeholder="Concepto (opcional)" value={l.note} onChange={setLinea(l.key, 'note')} aria-label="Concepto" />
          </div>
        ))}
        <button type="button" className="btn" onClick={() => setLineas((ls) => [...ls, lineaVacia()])}>
          + Otra línea
        </button>

        {suma > 0 && (
          <div className={`notice${diferencia < 0 ? ' notice-error' : diferencia > 0 ? ' notice-warning' : ''}`}>
            Las líneas suman <strong>{fmt.format(suma)} {form.currency}</strong>
            {diferencia === 0 && ' y cuadran con el total.'}
            {diferencia > 0 && <> · falta asignar <strong>{fmt.format(diferencia)}</strong>. Se puede guardar igual.</>}
            {diferencia < 0 && <> · se pasan del total por <strong>{fmt.format(-diferencia)}</strong>.</>}
          </div>
        )}
      </div>
    </Drawer>
  )
}
