import { useMemo, useState } from 'react'
import { useAsync } from '../../lib/useAsync'
import {
  listBudgetLines,
  createBudgetLine,
  deleteBudgetLine,
  deleteBudgetLines,
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

const MES = new Intl.DateTimeFormat('es-AR', { month: 'short', year: 'numeric' })

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
  const [seleccion, setSeleccion] = useState(() => new Set())
  const [borrando, setBorrando] = useState(false)
  const [borrarError, setBorrarError] = useState(null)

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

  async function remove(r) {
    const aviso =
      `¿Borrar la línea "${r.description}" del presupuesto? No se puede deshacer.` +
      (Number(r.actual_usd || 0) > 0
        ? '\n\nTiene gastos cargados: esos gastos no se borran, pero quedan sin línea de presupuesto asignada.'
        : '')
    if (!window.confirm(aviso)) return

    setBorrarError(null)
    try {
      await deleteBudgetLine(r.budget_line_id)
      setSeleccion((s) => {
        const n = new Set(s)
        n.delete(r.budget_line_id)
        return n
      })
      lines.reload()
      onChange?.()
    } catch (err) {
      setBorrarError(err.message)
    }
  }

  const rows = lines.data ?? []

  /* La seleccion se cruza con las filas actuales: si una linea desaparece
     (otra pestaña, un reload) no queda seleccionada en el aire. */
  const elegidas = rows.filter((r) => seleccion.has(r.budget_line_id))
  const todas = rows.length > 0 && elegidas.length === rows.length

  function alternarLinea(id) {
    setSeleccion((s) => {
      const n = new Set(s)
      if (n.has(id)) n.delete(id)
      else n.add(id)
      return n
    })
  }

  function alternarTodas() {
    setSeleccion(todas ? new Set() : new Set(rows.map((r) => r.budget_line_id)))
  }

  async function borrarSeleccionadas() {
    if (!elegidas.length) return
    const conGastos = elegidas.filter((r) => Number(r.actual_usd || 0) > 0)
    const aviso =
      `¿Borrar ${elegidas.length === 1 ? '1 línea' : `${elegidas.length} líneas`} del presupuesto? ` +
      'No se puede deshacer.' +
      (conGastos.length
        ? `\n\n${conGastos.length === 1 ? '1 tiene' : `${conGastos.length} tienen`} gastos cargados: ` +
          'esos gastos no se borran, pero quedan sin línea de presupuesto asignada.'
        : '')
    if (!window.confirm(aviso)) return

    setBorrando(true)
    setBorrarError(null)
    try {
      await deleteBudgetLines(elegidas.map((r) => r.budget_line_id))
      setSeleccion(new Set())
      lines.reload()
      onChange?.()
    } catch (err) {
      setBorrarError(err.message)
    } finally {
      setBorrando(false)
    }
  }

  /* Una linea sin fecha prevista es plata que se va a gastar y que el cashflow
     no ve venir. No es un error de carga que se note solo: hay que decirlo. */
  const sinFecha = rows.filter((r) => !r.planned_date)
  const montoSinFecha = sinFecha.reduce((a, r) => a + Number(r.total_forecast_usd || 0), 0)

  /* Lo previsto mes a mes, con lo que ya se ejecuto descontado. Es la misma
     cuenta que hace la vista de cashflow, mostrada donde se carga el dato para
     que el efecto de poner una fecha se vea al instante. */
  const porMes = useMemo(() => {
    const m = new Map()
    for (const r of rows) {
      if (!r.planned_date) continue
      const mes = String(r.planned_date).slice(0, 7)
      const pendiente = Number(r.pendiente_usd || 0)
      if (pendiente <= 0) continue
      m.set(mes, (m.get(mes) ?? 0) + pendiente)
    }
    return [...m.entries()].sort(([a], [b]) => a.localeCompare(b))
  }, [rows])
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
    ...(canManage
      ? [
          {
            key: 'sel',
            sort: false,
            label: (
              <input
                type="checkbox"
                aria-label="Seleccionar todas las líneas"
                checked={todas}
                ref={(el) => { if (el) el.indeterminate = elegidas.length > 0 && !todas }}
                onChange={alternarTodas}
              />
            ),
          },
        ]
      : []),
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

      {sinFecha.length > 0 && (
        <div className="notice notice-warning">
          <strong>
            {sinFecha.length === 1
              ? '1 línea sin fecha prevista'
              : `${sinFecha.length} líneas sin fecha prevista`}
            , por {usd(montoSinFecha)}.
          </strong>{' '}
          Esa plata se va a gastar, pero el cashflow no la ve venir: no aparece en la
          necesidad de caja de ningún mes. Editá la línea y poné la fecha, o asignale una
          actividad del cronograma.
        </div>
      )}

      {porMes.length > 0 && (
        <section style={{ display: 'grid', gap: 8 }}>
          <h2>Lo que falta gastar, mes a mes</h2>
          <div className="mes-grid">
            {porMes.map(([mes, monto]) => (
              <div className="card" key={mes} style={{ padding: '10px 14px' }}>
                <div className="kpi-label">{MES.format(new Date(`${mes}-01T00:00:00`))}</div>
                <div className="num" style={{ fontSize: '1.0625rem', fontWeight: 600 }}>
                  {usd(monto)}
                </div>
              </div>
            ))}
          </div>
          <p style={{ margin: 0, color: 'var(--text-muted)', fontSize: '0.8125rem' }}>
            Solo lo pendiente: lo que ya se ejecutó no se cuenta dos veces. Es lo mismo
            que alimenta Finanzas › Cashflow, pero acá al lado de donde se carga la fecha.
          </p>
        </section>
      )}

      {lines.error && <ErrorBox message={lines.error} />}

      {lines.loading ? (
        <Loading />
      ) : (
        <>
          {canManage && rows.length > 0 && (
            <div
              style={{
                display: 'flex',
                alignItems: 'center',
                gap: 8,
                flexWrap: 'wrap',
                padding: '8px 12px',
                border: '1px solid var(--border)',
                borderRadius: 8,
                background: elegidas.length ? 'var(--accent-soft)' : undefined,
              }}
            >
              {elegidas.length === 0 ? (
                <button className="btn" onClick={alternarTodas}>
                  Seleccionar todas ({rows.length})
                </button>
              ) : (
                <>
                  <strong>
                    {elegidas.length === 1 ? '1 línea seleccionada' : `${elegidas.length} líneas seleccionadas`}
                  </strong>
                  <span style={{ color: 'var(--text-muted)' }}>
                    · {usd(elegidas.reduce((a, r) => a + Number(r.total_original_usd || 0), 0))} de budget
                  </span>
                  <span style={{ flex: 1 }} />
                  {!todas && (
                    <button className="btn" onClick={alternarTodas}>
                      Seleccionar todas ({rows.length})
                    </button>
                  )}
                  <button className="btn" onClick={() => setSeleccion(new Set())} disabled={borrando}>
                    Quitar selección
                  </button>
                  <button className="btn btn-primary" onClick={borrarSeleccionadas} disabled={borrando}>
                    {borrando ? 'Borrando…' : 'Borrar seleccionadas'}
                  </button>
                </>
              )}
            </div>
          )}

          {borrarError && <ErrorBox message={borrarError} />}

          <Table
            columns={columns}
            rows={rows}
            empty="Todavía no hay líneas de presupuesto."
            renderRow={(r) => (
              <tr
                key={r.budget_line_id}
                style={seleccion.has(r.budget_line_id) ? { background: 'var(--accent-soft)' } : undefined}
              >
                {canManage && (
                  <td>
                    <input
                      type="checkbox"
                      aria-label={`Seleccionar ${r.description}`}
                      checked={seleccion.has(r.budget_line_id)}
                      onChange={() => alternarLinea(r.budget_line_id)}
                    />
                  </td>
                )}
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
                      <button className="icon-btn" onClick={() => remove(r)}>
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
