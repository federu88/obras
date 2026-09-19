import { useState } from 'react'
import { useAsync } from '../../lib/useAsync'
import {
  listBudgetLines,
  createBudgetLine,
  deleteBudgetLine,
  updateBudgetLine,
  getBudgetLine,
  listCostCategories,
  listItemsPlain,
  listTasks,
} from '../../lib/queries'
import { usd, pct, date, variance } from '../../lib/format'
import { useAuth } from '../../context/AuthContext'
import { Table, Loading, ErrorBox, Drawer, Field } from '../../components/ui'
import PlanificadorDrawer from '../../components/PlanificadorDrawer'

const EMPTY = {
  category_id: '',
  item_id: '',
  description: '',
  unit: 'un',
  qty_original: '',
  price_original_usd: '',
  price_client_usd: '',
  qty_forecast: '',
  price_forecast_usd: '',
  planned_date: '',
  task_id: '',
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

export default function Presupuesto({ projectId, encargo = false, onChange }) {
  const { canManage } = useAuth()
  const [abierto, setAbierto] = useState(null)
  const [form, setForm] = useState(EMPTY)
  const [saving, setSaving] = useState(false)
  const [formError, setFormError] = useState(null)

  const lines = useAsync(() => listBudgetLines(projectId), [projectId])
  const categories = useAsync(listCostCategories)
  const items = useAsync(listItemsPlain)
  const tasks = useAsync(() => listTasks(projectId), [projectId])
  const [planificando, setPlanificando] = useState(false)

  const set = (k) => (e) => setForm((f) => ({ ...f, [k]: e.target.value }))

  async function save() {
    setSaving(true)
    setFormError(null)
    try {
      const payload = {
        category_id: form.category_id || null,
        item_id: form.item_id || null,
        description: form.description,
        unit: form.unit || 'un',
        qty_original: Number(form.qty_original || 0),
        price_original_usd: Number(form.price_original_usd || 0),
        price_client_usd:
          encargo && form.price_client_usd !== '' ? Number(form.price_client_usd) : null,
        qty_forecast: form.qty_forecast === '' ? null : Number(form.qty_forecast),
        price_forecast_usd:
          form.price_forecast_usd === '' ? null : Number(form.price_forecast_usd),
        planned_date: form.planned_date || null,
        task_id: form.task_id || null,
      }
      if (abierto === 'nuevo') await createBudgetLine({ ...payload, project_id: projectId })
      else await updateBudgetLine(abierto.budget_line_id, payload)
      setForm(EMPTY)
      setAbierto(null)
      lines.reload()
      onChange?.()
    } catch (err) {
      setFormError(err.message)
    } finally {
      setSaving(false)
    }
  }

  async function abrirEdicion(r) {
    const full = await getBudgetLine(r.budget_line_id)
    setForm({
      category_id: full.category_id ?? '',
      item_id: full.item_id ?? '',
      description: full.description ?? '',
      unit: full.unit ?? 'un',
      qty_original: full.qty_original ?? '',
      price_original_usd: full.price_original_usd ?? '',
      price_client_usd: full.price_client_usd ?? '',
      qty_forecast: full.qty_forecast ?? '',
      price_forecast_usd: full.price_forecast_usd ?? '',
      planned_date: full.planned_date ?? '',
      task_id: full.task_id ?? '',
    })
    setAbierto(r)
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
      pendiente: a.pendiente + Number(r.pendiente_usd ?? 0),
    }),
    { original: 0, forecast: 0, actual: 0, committed: 0, pendiente: 0 }
  )

  const columns = [
    { key: 'planned_date', label: 'Fecha prevista' },
    { key: 'actividad', label: 'Actividad' },
    { key: 'categoria', label: 'Categoría' },
    { key: 'description', label: 'Item' },
    { key: 'qty_original', label: 'Cant.', num: true },
    { key: 'price_original_usd', label: 'Precio un.', num: true },
    { key: 'total_original_usd', label: 'Budget', num: true },
    ...(encargo
      ? [
          { key: 'total_client_usd', label: 'Al cliente', num: true },
          { key: 'margen_presupuestado_usd', label: 'Margen', num: true },
        ]
      : []),
    { key: 'total_forecast_usd', label: 'Forecast', num: true },
    { key: 'actual_usd', label: 'Actual', num: true },
    { key: 'pendiente_usd', label: 'Pendiente', num: true },
    { key: 'var', label: 'Desvío', num: true, sort: (r) => Number(r.actual_usd) - Number(r.total_original_usd) },
    { key: 'act', label: '', sort: false },
  ]

  return (
    <div style={{ display: 'grid', gap: 16 }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', gap: 12, flexWrap: 'wrap' }}>
        <p style={{ margin: 0, color: 'var(--text-muted)', fontSize: '0.9375rem' }}>
          El budget original queda congelado; el forecast es la estimación de hoy. La
          <strong> fecha prevista</strong> es lo que hace que el plan proyecte necesidad
          de caja antes de que se gaste.
        </p>
        {canManage && (
          <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap' }}>
            <button className="btn" onClick={() => { setForm(EMPTY); setAbierto('nuevo') }}>
              + Línea suelta
            </button>
            <button className="btn btn-primary" onClick={() => setPlanificando(true)}>
              Planificar desde el catálogo
            </button>
          </div>
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
                <td className="nowrap">{date(r.planned_date)}</td>
                <td style={{ color: 'var(--text-muted)' }}>{r.actividad ?? '—'}</td>
                <td style={{ color: 'var(--text-muted)' }}>{r.categoria ?? '—'}</td>
                <td>{r.description}</td>
                <td className="num">{r.qty_original} {r.unit}</td>
                <td className="num">{usd(r.price_original_usd)}</td>
                <td className="num">{usd(r.total_original_usd)}</td>
                {encargo && (
                  <>
                    <td className="num">
                      {r.total_client_usd == null ? '—' : usd(r.total_client_usd)}
                    </td>
                    <td
                      className={`num ${
                        r.margen_presupuestado_usd < 0 ? 'var-neg' : ''
                      }`}
                    >
                      {r.margen_presupuestado_usd == null
                        ? '—'
                        : usd(r.margen_presupuestado_usd)}
                    </td>
                  </>
                )}
                <td className="num">{usd(r.total_forecast_usd)}</td>
                <td className="num">{usd(r.actual_usd)}</td>
                <td className="num">{usd(r.pendiente_usd)}</td>
                <td className="num"><Var actual={r.actual_usd} baseline={r.total_original_usd} /></td>
                <td className="nowrap">
                  {canManage && (
                    <>
                      <button className="icon-btn" onClick={() => abrirEdicion(r)}>
                        Editar
                      </button>
                      <button className="icon-btn" onClick={() => remove(r.budget_line_id)}>
                        Borrar
                      </button>
                    </>
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
                    <td>Pendiente de ejecutar</td>
                    <td className="num">{usd(totals.pendiente)}</td>
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

      {abierto && (
        <Drawer
          title={abierto === 'nuevo' ? 'Nueva línea de presupuesto' : 'Editar línea'}
          submitLabel={abierto === 'nuevo' ? 'Crear' : 'Guardar cambios'}
          onClose={() => setAbierto(null)}
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

          <Field label="Precio unitario (USD)" hint={encargo ? 'Lo que estimamos que nos va a costar.' : undefined}>
            <input type="number" step="0.0001" min="0" required value={form.price_original_usd} onChange={set('price_original_usd')} />
          </Field>

          {/* El otro precio: lo que se le presupuestó al cliente. Uno es lo que
              creemos que va a costar, el otro es lo que le dijimos que iba a
              pagar, y solo el segundo sale en un reporte para él. */}
          {encargo && (
            <Field
              label="Precio unitario al cliente (USD)"
              hint="Lo que se le cotizó. La diferencia contra el costo es el margen."
            >
              <input
                type="number"
                step="0.0001"
                min="0"
                value={form.price_client_usd}
                onChange={set('price_client_usd')}
              />
            </Field>
          )}

          <div className="notice">
            Lo de arriba es el <strong>budget original</strong> y queda congelado. Lo de
            abajo es el <strong>forecast</strong>: la estimación de hoy. Si lo dejás
            vacío, el forecast es igual al original.
          </div>

          <Field
            label="Fecha prevista"
            hint="Cuándo se va a usar o comprar. Alimenta el cashflow proyectado."
          >
            <input type="date" value={form.planned_date} onChange={set('planned_date')} />
          </Field>

          <Field label="Actividad del cronograma">
            <select value={form.task_id} onChange={set('task_id')}>
              <option value="">Sin actividad</option>
              {(tasks.data ?? []).map((t) => (
                <option key={t.task_id} value={t.task_id}>{t.name}</option>
              ))}
            </select>
          </Field>

          <Field label="Cantidad estimada hoy">
            <input type="number" step="0.0001" min="0" value={form.qty_forecast} onChange={set('qty_forecast')} />
          </Field>

          <Field label="Precio unitario estimado hoy (USD)">
            <input type="number" step="0.0001" min="0" value={form.price_forecast_usd} onChange={set('price_forecast_usd')} />
          </Field>
        </Drawer>
      )}

      {planificando && (
        <PlanificadorDrawer
          projectId={projectId}
          onClose={() => setPlanificando(false)}
          onSaved={() => {
            lines.reload()
            onChange?.()
          }}
        />
      )}
    </div>
  )
}
