import { useEffect, useState } from 'react'
import { useAsync } from '../lib/useAsync'
import {
  listProjectRubros,
  listSuppliers,
  listItemsPlain,
  listBudgetLines,
  fxRateAt,
} from '../lib/queries'
import { usd } from '../lib/format'
import { COST_TYPES } from '../lib/costos'
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
  project_rubro_id: '',
  cost_type: 'materiales',
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
  /* Solo aplican a obra por encargo. */
  paid_by: 'estudio',
  client_amount: '',
}

function desdeGasto(g) {
  if (!g) return VACIO
  const f = { ...VACIO }
  for (const k of Object.keys(VACIO)) {
    const v = g[k]
    f[k] = v == null ? '' : String(v)
  }
  // Las relaciones vienen anidadas cuando el listado las expande.
  f.project_rubro_id = g.project_rubro_id ?? g.rubro?.id ?? ''
  f.cost_type = g.cost_type ?? 'materiales'
  f.supplier_id = g.supplier_id ?? g.supplier?.id ?? ''
  f.item_id = g.item_id ?? g.item?.id ?? ''
  f.status = g.status ?? 'pagado'
  f.purchase_stage = g.purchase_stage ?? ''
  f.paid_by = g.paid_by ?? 'estudio'
  return f
}

export default function GastoForm({ gasto, projectId, encargo = false, onClose, onSave }) {
  const [form, setForm] = useState(() => desdeGasto(gasto))
  const [saving, setSaving] = useState(false)
  const [error, setError] = useState(null)

  const rubros = useAsync(
    () => (projectId ? listProjectRubros(projectId) : Promise.resolve([])),
    [projectId]
  )
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
  const aUsd = (v) =>
    form.currency === 'USD' ? v : form.fx_usd ? v / Number(form.fx_usd) : null
  const totalUsd = aUsd(total)

  /* El margen se muestra mientras se carga para que el numero se elija a
     conciencia, no al cerrar el mes. */
  const clienteUsd = form.client_amount === '' ? null : aUsd(Number(form.client_amount))
  const margen = clienteUsd != null && totalUsd != null ? clienteUsd - totalUsd : null

  async function submit() {
    setSaving(true)
    setError(null)
    try {
      await onSave({
        expense_date: form.expense_date,
        description: form.description,
        /* Sin rubro elegido, la base lo clasifica por la categoría del ítem
           o lo deja en "Sin clasificar". */
        project_rubro_id: form.project_rubro_id || null,
        cost_type: form.cost_type,
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
        /* En desarrollo propio no hay cliente a quien repicarle nada: se
           mandan los valores neutros para no dejar datos que engañen. */
        paid_by: encargo ? form.paid_by : 'estudio',
        client_amount: encargo && form.client_amount !== '' ? Number(form.client_amount) : null,
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

      <Field label="Rubro">
        <select value={form.project_rubro_id} onChange={set('project_rubro_id')}>
          <option value="">Sin clasificar</option>
          {(rubros.data ?? [])
            .filter((r) => r.is_active || r.id === form.project_rubro_id)
            .map((r) => (
              <option key={r.id} value={r.id}>{r.name}</option>
            ))}
        </select>
      </Field>

      <Field label="Tipo de costo">
        <select value={form.cost_type} onChange={set('cost_type')}>
          {Object.entries(COST_TYPES).map(([k, label]) => (
            <option key={k} value={k}>{label}</option>
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

      {gasto?.receipt_id && (
        <div className="notice">
          Es una línea de un comprobante: la moneda y la cotización son las del
          comprobante. Si cambian, se cambian ahí.
        </div>
      )}

      <Field label="Moneda">
        <select value={form.currency} onChange={set('currency')} disabled={Boolean(gasto?.receipt_id)}>
          <option value="ARS">ARS</option>
          <option value="USD">USD</option>
        </select>
      </Field>

      {form.currency === 'ARS' && (
        <Field label="Cotización (ARS por USD)" hint="Sugerida por la fecha. Cambiala si pagaste a otro cambio.">
          <input type="number" step="0.0001" min="0.0001" required value={form.fx_usd} onChange={set('fx_usd')} disabled={Boolean(gasto?.receipt_id)} />
        </Field>
      )}

      {totalUsd != null && (
        <div className="notice">
          Total: <strong>{usd(totalUsd)}</strong>
          {margen != null && (
            <> · se le cobra al cliente <strong>{usd(clienteUsd)}</strong>,
            margen <strong className={margen < 0 ? 'var-neg' : 'var-pos'}>{usd(margen)}</strong></>
          )}
        </div>
      )}

      {/* Los dos precios. Solo tienen sentido cuando hay un cliente del otro
          lado: en desarrollo propio el costo ES el número, no hay a quién
          repicarle nada. */}
      {encargo && (
        <>
          <Field
            label="Quién lo pagó"
            hint="Los dos son costo de la obra, pero solo lo que pone el estudio es plata del estudio."
          >
            <select value={form.paid_by} onChange={set('paid_by')}>
              <option value="estudio">El estudio</option>
              <option value="cliente">El cliente, directo al proveedor</option>
            </select>
          </Field>

          <Field
            label="Se le cobra al cliente"
            hint="En la misma moneda del gasto. Vacío si no se le repica. El cliente nunca ve este número junto al costo."
          >
            <input
              type="number"
              step="0.01"
              min="0"
              value={form.client_amount}
              onChange={set('client_amount')}
            />
          </Field>
        </>
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
