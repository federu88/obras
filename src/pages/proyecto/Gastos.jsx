import { useEffect, useState } from 'react'
import { useAsync } from '../../lib/useAsync'
import {
  listExpenses,
  createExpense,
  updateExpense,
  listCostCategories,
  listBudgetLines,
  fxRateAt,
} from '../../lib/queries'
import { usd, date } from '../../lib/format'
import { useAuth } from '../../context/AuthContext'
import { Table, Loading, ErrorBox, Badge, Drawer, Field } from '../../components/ui'

/* Los estados definen qué es Actual y qué es Committed. Es la distinción que
   hoy no existe en la planilla, donde todo gasto cargado pesa igual. */
const STATUS = {
  estimado: ['Estimado', null],
  comprometido: ['Comprometido', 'warn'],
  recibido: ['Recibido', 'ok'],
  pagado: ['Pagado', 'ok'],
  anulado: ['Anulado', 'off'],
}

const EMPTY = {
  category_id: '',
  budget_line_id: '',
  description: '',
  supplier_name: '',
  status: 'recibido',
  expense_date: new Date().toISOString().slice(0, 10),
  qty: '1',
  unit_price: '',
  currency: 'ARS',
  fx_usd: '',
}

export default function Gastos({ projectId, onChange }) {
  const { canManage } = useAuth()
  const [open, setOpen] = useState(false)
  const [form, setForm] = useState(EMPTY)
  const [saving, setSaving] = useState(false)
  const [formError, setFormError] = useState(null)

  const expenses = useAsync(() => listExpenses(projectId), [projectId])
  const categories = useAsync(listCostCategories)
  const budget = useAsync(() => listBudgetLines(projectId), [projectId])

  const set = (k) => (e) => setForm((f) => ({ ...f, [k]: e.target.value }))

  useEffect(() => {
    if (form.currency !== 'ARS' || !form.expense_date) return
    let cancelled = false
    fxRateAt(form.expense_date)
      .then((r) => {
        if (!cancelled && r) setForm((f) => (f.fx_usd ? f : { ...f, fx_usd: String(r) }))
      })
      .catch(() => {})
    return () => { cancelled = true }
  }, [form.currency, form.expense_date])

  async function save() {
    setSaving(true)
    setFormError(null)
    try {
      await createExpense({
        project_id: projectId,
        category_id: form.category_id || null,
        budget_line_id: form.budget_line_id || null,
        description: form.description,
        supplier_name: form.supplier_name || null,
        status: form.status,
        expense_date: form.expense_date,
        qty: Number(form.qty || 1),
        unit_price: Number(form.unit_price),
        currency: form.currency,
        fx_usd: form.currency === 'ARS' ? Number(form.fx_usd) : null,
      })
      setForm(EMPTY)
      setOpen(false)
      expenses.reload()
      onChange?.()
    } catch (err) {
      setFormError(err.message)
    } finally {
      setSaving(false)
    }
  }

  async function anular(id) {
    await updateExpense(id, { status: 'anulado' })
    expenses.reload()
    onChange?.()
  }

  const columns = [
    { key: 'date', label: 'Fecha' },
    { key: 'desc', label: 'Concepto' },
    { key: 'cat', label: 'Categoría' },
    { key: 'sup', label: 'Proveedor' },
    { key: 'amount', label: 'Importe', num: true },
    { key: 'usd', label: 'USD', num: true },
    { key: 'status', label: 'Estado' },
    { key: 'act', label: '' },
  ]

  return (
    <div style={{ display: 'grid', gap: 16 }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', gap: 12, flexWrap: 'wrap' }}>
        <p style={{ margin: 0, color: 'var(--text-muted)', fontSize: '0.9375rem' }}>
          Recibido y pagado cuentan como <strong>Actual</strong>. Comprometido no: es plata
          reservada que todavía no es costo.
        </p>
        {canManage && (
          <button className="btn btn-primary" onClick={() => setOpen(true)}>+ Nuevo gasto</button>
        )}
      </div>

      {expenses.error && <ErrorBox message={expenses.error} />}

      {expenses.loading ? (
        <Loading />
      ) : (
        <Table
          columns={columns}
          rows={expenses.data ?? []}
          empty="Todavía no hay gastos cargados."
          renderRow={(e) => (
            <tr key={e.id} style={{ opacity: e.status === 'anulado' ? 0.5 : 1 }}>
              <td>{date(e.expense_date)}</td>
              <td>{e.description}</td>
              <td style={{ color: 'var(--text-muted)' }}>{e.category?.name ?? '—'}</td>
              <td>{e.supplier_name ?? '—'}</td>
              <td className="num">
                {new Intl.NumberFormat('es-AR').format(e.qty * e.unit_price)} {e.currency}
              </td>
              <td className="num">{usd(e.amount_usd)}</td>
              <td><Badge tone={STATUS[e.status]?.[1]}>{STATUS[e.status]?.[0] ?? e.status}</Badge></td>
              <td>
                {canManage && e.status !== 'anulado' && (
                  <button className="icon-btn" onClick={() => anular(e.id)}>Anular</button>
                )}
              </td>
            </tr>
          )}
        />
      )}

      {open && (
        <Drawer title="Nuevo gasto" onClose={() => setOpen(false)} onSubmit={save} submitting={saving}>
          {formError && <ErrorBox message={formError} />}

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

          <Field
            label="Línea de presupuesto"
            hint="Vincularlo es lo que permite medir el desvío por item."
          >
            <select value={form.budget_line_id} onChange={set('budget_line_id')}>
              <option value="">Sin vincular</option>
              {(budget.data ?? []).map((b) => (
                <option key={b.budget_line_id} value={b.budget_line_id}>{b.description}</option>
              ))}
            </select>
          </Field>

          <Field label="Proveedor">
            <input value={form.supplier_name} onChange={set('supplier_name')} />
          </Field>

          <Field label="Estado">
            <select value={form.status} onChange={set('status')}>
              {Object.entries(STATUS)
                .filter(([k]) => k !== 'anulado')
                .map(([k, [label]]) => <option key={k} value={k}>{label}</option>)}
            </select>
          </Field>

          <Field label="Fecha">
            <input type="date" required value={form.expense_date} onChange={set('expense_date')} />
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
            <Field label="Cotización (ARS por USD)" hint="Sugerida según la fecha del gasto.">
              <input type="number" step="0.0001" min="0.0001" required value={form.fx_usd} onChange={set('fx_usd')} />
            </Field>
          )}
        </Drawer>
      )}
    </div>
  )
}
