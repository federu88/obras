import { useEffect, useState } from 'react'
import { useAsync } from '../lib/useAsync'
import {
  listCostCategories,
  listSuppliers,
  listItemsPlain,
  listBudgetLines,
  fxRateAt,
} from '../lib/queries'
import { usd } from '../lib/format'
import { Drawer, Field, ErrorBox } from './ui'

/**
 * Formulario de gasto, compartido entre alta y edición.
 *
 * En etapa de diseño todo tiene que poder corregirse: los datos importados
 * traen fechas dudosas, categorías aproximadas y conceptos sin proveedor.
 */

export const EXPENSE_STATUS = {
  estimado: 'Estimado — no es costo todavía',
  comprometido: 'Comprometido — reservado, sin recibir',
  recibido: 'Recibido — ya es costo',
  pagado: 'Pagado — costo y plata afuera',
  anulado: 'Anulado',
}

export const PURCHASE_STAGE = {
  '': 'No es una compra',
  solicitada: 'Solicitada',
  cotizada: 'Cotizada',
  aprobada: 'Aprobada',
  comprada: 'Comprada',
  recibida: 'Recibida',
  pagada: 'Pagada',
}

const VACIO = {
  expense_date: new Date().toISOString().slice(0, 10),
  description: '',
  category_id: '',
  item_id: '',
  supplier_id: '',
  supplier_name: '',
  budget_line_id: '',
  status: 'pagado',
  purchase_stage: '',
  qty: '1',
  unit_price: '',
  currency: 'ARS',
  fx_usd: '',
  due_date: '',
  paid_date: '',
}

function desdeGasto(g) {
  if (!g) return VACIO
  const f = { ...VACIO }
  for (const k of Object.keys(VACIO)) {
    const v = g[k]
    f[k] = v == null ? '' : String(v)
  }
  // Las relaciones vienen anidadas cuando el listado las expande.
  f.category_id = g.category_id ?? g.category?.id ?? ''
  f.supplier_id = g.supplier_id ?? g.supplier?.id ?? ''
  f.item_id = g.item_id ?? g.item?.id ?? ''
  f.status = g.status ?? 'pagado'
  f.purchase_stage = g.purchase_stage ?? ''
  return f
}

export default function GastoForm({ gasto, projectId, onClose, onSave }) {
  const [form, setForm] = useState(() => desdeGasto(gasto))
  const [saving, setSaving] = useState(false)
  const [error, setError] = useState(null)

  const categories = useAsync(listCostCategories)
  const suppliers = useAsync(listSuppliers)
  const items = useAsync(listItemsPlain)
  const budget = useAsync(
    () => (projectId ? listBudgetLines(projectId) : Promise.resolve([])),
    [projectId]
  )

  const set = (k) => (e) => setForm((f) => ({ ...f, [k]: e.target.value }))
  const editando = Boolean(gasto)

  /* Sugerimos la cotización de la fecha, pero sin pisar la que ya tenga
     cargada: si el gasto se pagó a un cambio real distinto, ese vale más. */
  useEffect(() => {
    if (form.currency !== 'ARS' || !form.expense_date) return
    let cancelado = false
    fxRateAt(form.expense_date)
      .then((r) => {
        if (!cancelado && r) setForm((f) => (f.fx_usd ? f : { ...f, fx_usd: String(r) }))
      })
      .catch(() => {})
    return () => { cancelado = true }
  }, [form.currency, form.expense_date])

  const total = Number(form.qty || 0) * Number(form.unit_price || 0)
  const totalUsd =
    form.currency === 'USD'
      ? total
      : form.fx_usd
        ? total / Number(form.fx_usd)
        : null

  async function submit() {
    setSaving(true)
    setError(null)
    try {
      await onSave({
        expense_date: form.expense_date,
        description: form.description,
        category_id: form.category_id || null,
        item_id: form.item_id || null,
        supplier_id: form.supplier_id || null,
        supplier_name: form.supplier_name || null,
        budget_line_id: form.budget_line_id || null,
        status: form.status,
        purchase_stage: form.purchase_stage || null,
        qty: Number(form.qty || 1),
        unit_price: Number(form.unit_price),
        currency: form.currency,
        fx_usd: form.currency === 'ARS' ? Number(form.fx_usd) : null,
        due_date: form.due_date || null,
        paid_date: form.paid_date || null,
      })
      onClose()
    } catch (err) {
      setError(err.message)
    } finally {
      setSaving(false)
    }
  }

  return (
    <Drawer
      title={editando ? 'Editar gasto' : 'Nuevo gasto'}
      onClose={onClose}
      onSubmit={submit}
      submitting={saving}
      submitLabel={editando ? 'Guardar cambios' : 'Crear'}
    >
      {error && <ErrorBox message={error} />}

      <Field label="Fecha">
        <input type="date" required value={form.expense_date} onChange={set('expense_date')} />
      </Field>

      <Field label="Concepto">
        <input required value={form.description} onChange={set('description')} />
      </Field>

      <Field label="Categoría">
        <select value={form.category_id} onChange={set('category_id')}>
          <option value="">Sin categoría</option>
          {(categories.data ?? []).filter((c) => c.parent_id).map((c) => (
            <option key={c.id} value={c.id}>{c.path}</option>
          ))}
        </select>
      </Field>

      <Field label="Proveedor">
        <select value={form.supplier_id} onChange={set('supplier_id')}>
          <option value="">—</option>
          {(suppliers.data ?? []).map((s) => (
            <option key={s.id} value={s.id}>{s.name}</option>
          ))}
        </select>
      </Field>

      <Field label="Cantidad">
        <input type="number" step="0.0001" min="0.0001" required value={form.qty} onChange={set('qty')} />
      </Field>

      <Field label="Precio unitario">
        <input type="number" step="0.0001" min="0" required value={form.unit_price} onChange={set('unit_price')} />
      </Field>

      <Field label="Moneda">
        <select value={form.currency} onChange={set('currency')}>
          <option value="ARS">ARS</option>
          <option value="USD">USD</option>
        </select>
      </Field>

      {form.currency === 'ARS' && (
        <Field label="Cotización (ARS por USD)" hint="Sugerida por la fecha. Cambiala si pagaste a otro cambio.">
          <input type="number" step="0.0001" min="0.0001" required value={form.fx_usd} onChange={set('fx_usd')} />
        </Field>
      )}

      {totalUsd != null && (
        <div className="notice">
          Total: <strong>{usd(totalUsd)}</strong>
        </div>
      )}

      <Field label="Estado financiero" hint="Define qué cuenta como costo y qué está solo comprometido.">
        <select value={form.status} onChange={set('status')}>
          {Object.entries(EXPENSE_STATUS).map(([k, l]) => (
            <option key={k} value={k}>{l}</option>
          ))}
        </select>
      </Field>

      <Field
        label="Estado de compra"
        hint="Si lo usás, el estado financiero se recalcula solo a partir de acá."
      >
        <select value={form.purchase_stage} onChange={set('purchase_stage')}>
          {Object.entries(PURCHASE_STAGE).map(([k, l]) => (
            <option key={k} value={k}>{l}</option>
          ))}
        </select>
      </Field>

      <Field label="Item del catálogo">
        <select value={form.item_id} onChange={set('item_id')}>
          <option value="">Sin vincular</option>
          {(items.data ?? []).map((i) => (
            <option key={i.id} value={i.id}>{i.code} · {i.description}</option>
          ))}
        </select>
      </Field>

      <Field label="Línea de presupuesto" hint="Vincularla es lo que permite medir el desvío por item.">
        <select value={form.budget_line_id} onChange={set('budget_line_id')}>
          <option value="">Sin vincular</option>
          {(budget.data ?? []).map((b) => (
            <option key={b.budget_line_id} value={b.budget_line_id}>{b.description}</option>
          ))}
        </select>
      </Field>

      <Field label="Vencimiento">
        <input type="date" value={form.due_date} onChange={set('due_date')} />
      </Field>

      <Field label="Fecha de pago">
        <input type="date" value={form.paid_date} onChange={set('paid_date')} />
      </Field>
    </Drawer>
  )
}
