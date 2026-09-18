import { useState } from 'react'
import { useAsync } from '../../lib/useAsync'
import {
  listBudgetLines,
  createBudgetLine,
  deleteBudgetLine,
  listCostCategories,
  listItemsPlain,
} from '../../lib/queries'
import { usd, pct, variance } from '../../lib/format'
import { useAuth } from '../../context/AuthContext'
import { Table, Loading, ErrorBox, Drawer, Field } from '../../components/ui'

const EMPTY = {
  category_id: '',
  item_id: '',
  description: '',
  unit: 'un',
  qty_original: '',
  price_original_usd: '',
}

function Var({ actual, baseline }) {
  const { abs, rel } = variance(actual, baseline)
  if (abs == null || !baseline) return <span style={{ color: 'var(--text-muted)' }}>—</span>
  if (abs === 0) return <span style={{ color: 'var(--text-muted)' }}>0</span>
  const over = abs > 0
  return (
    <span className={over ? 'var-neg' : 'var-pos'}>
      {over ? '+' : ''}{usd(abs)}{rel != null && ` (${over ? '+' : ''}${pct(rel)})`}
    </span>
  )
}

export default function Presupuesto({ projectId, onChange }) {
  const { canManage } = useAuth()
  const [open, setOpen] = useState(false)
  const [form, setForm] = useState(EMPTY)
  const [saving, setSaving] = useState(false)
  const [formError, setFormError] = useState(null)

  const lines = useAsync(() => listBudgetLines(projectId), [projectId])
  const categories = useAsync(listCostCategories)
  const items = useAsync(listItemsPlain)

  const set = (k) => (e) => setForm((f) => ({ ...f, [k]: e.target.value }))

  async function save() {
    setSaving(true)
    setFormError(null)
    try {
      await createBudgetLine({
        project_id: projectId,
        category_id: form.category_id || null,
        item_id: form.item_id || null,
        description: form.description,
        unit: form.unit || 'un',
        qty_original: Number(form.qty_original || 0),
        price_original_usd: Number(form.price_original_usd || 0),
      })
      setForm(EMPTY)
      setOpen(false)
      lines.reload()
      onChange?.()
    } catch (err) {
      setFormError(err.message)
    } finally {
      setSaving(false)
    }
  }

  async function remove(id) {
    await deleteBudgetLine(id)
    lines.reload()
    onChange?.()
  }

  const rows = lines.data ?? []
  const totals = rows.reduce(
    (a, r) => ({
      original: a.original + Number(r.total_original_usd ?? 0),
      forecast: a.forecast + Number(r.total_forecast_usd ?? 0),
      actual: a.actual + Number(r.actual_usd ?? 0),
      committed: a.committed + Number(r.committed_usd ?? 0),
    }),
    { original: 0, forecast: 0, actual: 0, committed: 0 }
  )

  const columns = [
    { key: 'cat', label: 'Categoría' },
    { key: 'desc', label: 'Item' },
    { key: 'qty', label: 'Cant.', num: true },
    { key: 'price', label: 'Precio un.', num: true },
    { key: 'budget', label: 'Budget', num: true },
    { key: 'forecast', label: 'Forecast', num: true },
    { key: 'actual', label: 'Actual', num: true },
    { key: 'var', label: 'Desvío', num: true },
    { key: 'act', label: '' },
  ]

  return (
    <div style={{ display: 'grid', gap: 16 }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', gap: 12, flexWrap: 'wrap' }}>
        <p style={{ margin: 0, color: 'var(--text-muted)', fontSize: '0.9375rem' }}>
          El budget original queda congelado. El forecast es la estimación de hoy.
        </p>
        {canManage && (
          <button className="btn btn-primary" onClick={() => setOpen(true)}>
            + Línea de presupuesto
          </button>
        )}
      </div>

      {lines.error && <ErrorBox message={lines.error} />}

      {lines.loading ? (
        <Loading />
      ) : (
        <>
          <Table
            columns={columns}
            rows={rows}
            empty="Todavía no hay líneas de presupuesto."
            renderRow={(r) => (
              <tr key={r.budget_line_id}>
                <td style={{ color: 'var(--text-muted)' }}>{r.categoria ?? '—'}</td>
                <td>{r.description}</td>
                <td className="num">{r.qty_original} {r.unit}</td>
                <td className="num">{usd(r.price_original_usd)}</td>
                <td className="num">{usd(r.total_original_usd)}</td>
                <td className="num">{usd(r.total_forecast_usd)}</td>
                <td className="num">{usd(r.actual_usd)}</td>
                <td className="num"><Var actual={r.actual_usd} baseline={r.total_original_usd} /></td>
                <td>
                  {canManage && (
                    <button className="icon-btn" onClick={() => remove(r.budget_line_id)}>
                      Borrar
                    </button>
                  )}
                </td>
              </tr>
            )}
          />

          {rows.length > 0 && (
            <div className="card">
              <table className="data">
                <tbody>
                  <tr>
                    <td style={{ fontWeight: 600 }}>Total budget</td>
                    <td className="num" style={{ fontWeight: 600 }}>{usd(totals.original)}</td>
                  </tr>
                  <tr>
                    <td>Total forecast</td>
                    <td className="num">{usd(totals.forecast)}</td>
                  </tr>
                  <tr>
                    <td>Total actual</td>
                    <td className="num">{usd(totals.actual)}</td>
                  </tr>
                  <tr>
                    <td>Comprometido</td>
                    <td className="num">{usd(totals.committed)}</td>
                  </tr>
                  <tr>
                    <td>Desvío actual vs budget</td>
                    <td className="num"><Var actual={totals.actual} baseline={totals.original} /></td>
                  </tr>
                </tbody>
              </table>
            </div>
          )}
        </>
      )}

      {open && (
        <Drawer
          title="Nueva línea de presupuesto"
          onClose={() => setOpen(false)}
          onSubmit={save}
          submitting={saving}
        >
          {formError && <ErrorBox message={formError} />}

          <Field label="Categoría">
            <select value={form.category_id} onChange={set('category_id')}>
              <option value="">Sin categoría</option>
              {(categories.data ?? [])
                .filter((c) => c.parent_id)
                .map((c) => (
                  <option key={c.id} value={c.id}>{c.path}</option>
                ))}
            </select>
          </Field>

          <Field
            label="Item del catálogo"
            hint="Vincularlo es lo que permite comparar el precio presupuestado contra las cotizaciones."
          >
            <select
              value={form.item_id}
              onChange={(e) => {
                const item_id = e.target.value
                const it = (items.data ?? []).find((i) => i.id === item_id)
                setForm((f) => ({
                  ...f,
                  item_id,
                  description: f.description || it?.description || '',
                  unit: it?.unit || f.unit,
                }))
              }}
            >
              <option value="">Sin vincular</option>
              {(items.data ?? []).map((i) => (
                <option key={i.id} value={i.id}>{i.code} · {i.description}</option>
              ))}
            </select>
          </Field>

          <Field label="Descripción" hint="Ej: Porcelanato interior">
            <input required value={form.description} onChange={set('description')} />
          </Field>

          <Field label="Unidad" hint="m2, kg, bolsa, un… No dejar todo en 'un': sin unidad real no se pueden comparar precios.">
            <input value={form.unit} onChange={set('unit')} />
          </Field>

          <Field label="Cantidad">
            <input type="number" step="0.0001" min="0" required value={form.qty_original} onChange={set('qty_original')} />
          </Field>

          <Field label="Precio unitario (USD)">
            <input type="number" step="0.0001" min="0" required value={form.price_original_usd} onChange={set('price_original_usd')} />
          </Field>
        </Drawer>
      )}
    </div>
  )
}
