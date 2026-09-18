import { useMemo, useState } from 'react'
import { useAsync } from '../lib/useAsync'
import { listItems, listTasks, createBudgetLines } from '../lib/queries'
import { usd } from '../lib/format'
import { Drawer, Field, ErrorBox } from './ui'

/**
 * Carga masiva del presupuesto desde el catálogo.
 *
 * El arquitecto no arma un presupuesto de a una línea por vez: recorre el
 * catálogo, marca lo que va a necesitar y le pone cantidad y fecha. Por eso
 * esto es una lista con checkboxes y no un formulario repetido.
 *
 * El precio sale del historial del item — última compra, después última
 * cotización, después promedio. Si el item nunca se compró ni se cotizó, entra
 * en cero y hay que ponerlo a mano: es preferible un cero visible a un precio
 * inventado.
 */

const TIPOS = { insumo: 'Insumos', servicio: 'Servicios', honorario: 'Honorarios' }

function precioReferencia(it) {
  const v =
    it.ultimo_precio_comprado_usd ??
    it.ultimo_precio_cotizado_usd ??
    it.precio_promedio_usd
  return v == null ? 0 : Number(v)
}

export default function PlanificadorDrawer({ projectId, onClose, onSaved }) {
  const items = useAsync(listItems)
  const tasks = useAsync(() => listTasks(projectId), [projectId])

  const [busqueda, setBusqueda] = useState('')
  const [tipo, setTipo] = useState('')
  const [elegidos, setElegidos] = useState({}) // item_id -> { qty, fecha, task_id }
  const [guardando, setGuardando] = useState(false)
  const [error, setError] = useState(null)

  const hayTipos = (items.data ?? []).some((i) => i.kind)

  const visibles = useMemo(() => {
    const q = busqueda.trim().toLowerCase()
    return (items.data ?? []).filter((i) => {
      if (tipo && hayTipos && i.kind !== tipo) return false
      if (!q) return true
      return (
        String(i.code).toLowerCase().includes(q) ||
        String(i.description).toLowerCase().includes(q) ||
        String(i.categoria ?? '').toLowerCase().includes(q)
      )
    })
  }, [items.data, busqueda, tipo, hayTipos])

  const marcados = Object.entries(elegidos)
  const total = marcados.reduce((a, [id, v]) => {
    const it = (items.data ?? []).find((x) => x.item_id === id)
    return a + Number(v.qty || 0) * precioReferencia(it ?? {})
  }, 0)

  function alternar(it) {
    setElegidos((e) => {
      if (e[it.item_id]) {
        const { [it.item_id]: _, ...resto } = e
        return resto
      }
      return { ...e, [it.item_id]: { qty: '1', fecha: '', task_id: '' } }
    })
  }

  const editar = (id, campo) => (ev) =>
    setElegidos((e) => ({ ...e, [id]: { ...e[id], [campo]: ev.target.value } }))

  async function guardar() {
    setGuardando(true)
    setError(null)
    try {
      const filas = marcados.map(([id, v]) => {
        const it = (items.data ?? []).find((x) => x.item_id === id)
        return {
          project_id: projectId,
          item_id: id,
          category_id: it?.category_id ?? null,
          description: it?.description ?? '',
          unit: it?.unit ?? 'un',
          qty_original: Number(v.qty || 1),
          price_original_usd: precioReferencia(it ?? {}),
          planned_date: v.fecha || null,
          task_id: v.task_id || null,
        }
      })
      if (!filas.length) throw new Error('No hay ningún item marcado.')
      await createBudgetLines(filas)
      onSaved?.()
      onClose()
    } catch (err) {
      setError(err.message)
    } finally {
      setGuardando(false)
    }
  }

  return (
    <Drawer
      title="Planificar desde el catálogo"
      submitLabel={marcados.length ? `Agregar ${marcados.length} al presupuesto` : 'Agregar'}
      onClose={onClose}
      onSubmit={guardar}
      submitting={guardando}
    >
      {error && <ErrorBox message={error} />}

      <div className="notice">
        Marcá lo que vas a necesitar y poné cantidad y fecha prevista. La fecha es lo
        que hace que el presupuesto proyecte necesidad de caja antes de que se gaste.
      </div>

      <Field label="Buscar">
        <input
          placeholder="Código, descripción o categoría"
          value={busqueda}
          onChange={(e) => setBusqueda(e.target.value)}
        />
      </Field>

      {hayTipos && (
        <Field label="Tipo">
          <select value={tipo} onChange={(e) => setTipo(e.target.value)}>
            <option value="">Todos</option>
            {Object.entries(TIPOS).map(([k, l]) => (
              <option key={k} value={k}>{l}</option>
            ))}
          </select>
        </Field>
      )}

      {marcados.length > 0 && (
        <div className="notice notice-warning">
          {marcados.length} item(s) · estimado <strong>{usd(total)}</strong> según el
          historial de precios
        </div>
      )}

      <div
        style={{
          border: '1px solid var(--border)',
          borderRadius: 'var(--radius-sm)',
          maxHeight: 360,
          overflowY: 'auto',
        }}
      >
        {items.loading && <div className="state">Cargando catálogo…</div>}
        {!items.loading && visibles.length === 0 && (
          <div className="state">Ningún item coincide.</div>
        )}

        {visibles.map((it) => {
          const sel = elegidos[it.item_id]
          const ref = precioReferencia(it)
          return (
            <div
              key={it.item_id}
              style={{
                borderBottom: '1px solid var(--border)',
                padding: '8px 10px',
                background: sel ? 'var(--accent-soft)' : undefined,
              }}
            >
              <label style={{ display: 'flex', gap: 8, alignItems: 'flex-start', cursor: 'pointer' }}>
                <input
                  type="checkbox"
                  checked={Boolean(sel)}
                  onChange={() => alternar(it)}
                  style={{ marginTop: 3 }}
                />
                <span style={{ flex: 1, fontSize: '0.875rem' }}>
                  <strong>{it.code}</strong> {it.description}
                  <span style={{ color: 'var(--text-muted)' }}>
                    {' '}· {it.unit}
                    {ref > 0 ? ` · ref ${usd(ref)}` : ' · sin precio de referencia'}
                  </span>
                </span>
              </label>

              {sel && (
                <div
                  style={{
                    display: 'grid',
                    gap: 6,
                    gridTemplateColumns: '80px 1fr 1fr',
                    marginTop: 6,
                    marginLeft: 24,
                  }}
                >
                  <input
                    type="number"
                    step="0.01"
                    min="0.01"
                    value={sel.qty}
                    onChange={editar(it.item_id, 'qty')}
                    title="Cantidad"
                    style={{ padding: '5px 7px', fontSize: '0.8125rem' }}
                  />
                  <input
                    type="date"
                    value={sel.fecha}
                    onChange={editar(it.item_id, 'fecha')}
                    title="Cuándo se usa"
                    style={{ padding: '5px 7px', fontSize: '0.8125rem' }}
                  />
                  <select
                    value={sel.task_id}
                    onChange={editar(it.item_id, 'task_id')}
                    title="Actividad del cronograma"
                    style={{ padding: '5px 7px', fontSize: '0.8125rem' }}
                  >
                    <option value="">Sin actividad</option>
                    {(tasks.data ?? []).map((t) => (
                      <option key={t.task_id} value={t.task_id}>{t.name}</option>
                    ))}
                  </select>
                </div>
              )}
            </div>
          )
        })}
      </div>
    </Drawer>
  )
}
