import { useMemo, useState } from 'react'
import './ui.css'

export function PageHead({ title, subtitle, action }) {
  return (
    <div className="page-head">
      <div>
        <h1>{title}</h1>
        {subtitle && <p>{subtitle}</p>}
      </div>
      {action}
    </div>
  )
}

/**
 * Tabla ordenable.
 *
 * Una columna es ordenable si define `sort` (una función que devuelve el valor
 * a comparar) o si su `key` coincide con un campo de la fila. Las que no,
 * quedan sin ordenar en vez de ordenar por algo equivocado.
 *
 * Primer clic en una numérica ordena de mayor a menor, que es lo que se busca
 * casi siempre: ver los importes más grandes. En las de texto arranca A→Z.
 */
export function Table({ columns, rows, empty = 'Todavía no hay registros.', renderRow }) {
  const [orden, setOrden] = useState(null) // { key, desc }

  const valorDe = (col, row) => {
    if (typeof col.sort === 'function') return col.sort(row)
    if (col.sort === false) return undefined
    return row?.[col.key]
  }

  const ordenables = useMemo(() => {
    const set = new Set()
    if (!rows?.length) return set
    for (const c of columns) {
      if (c.sort === false) continue
      if (typeof c.sort === 'function') { set.add(c.key); continue }
      if (rows.some((r) => r?.[c.key] != null)) set.add(c.key)
    }
    return set
  }, [columns, rows])

  const filas = useMemo(() => {
    if (!orden || !rows?.length) return rows ?? []
    const col = columns.find((c) => c.key === orden.key)
    if (!col) return rows

    const copia = [...rows]
    copia.sort((a, b) => {
      const va = valorDe(col, a)
      const vb = valorDe(col, b)
      // Los vacíos siempre al final, ordene como ordene.
      if (va == null && vb == null) return 0
      if (va == null) return 1
      if (vb == null) return -1

      const na = Number(va)
      const nb = Number(vb)
      const cmp =
        !Number.isNaN(na) && !Number.isNaN(nb) && va !== '' && vb !== ''
          ? na - nb
          : String(va).localeCompare(String(vb), 'es', { numeric: true })
      return orden.desc ? -cmp : cmp
    })
    return copia
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [rows, orden, columns])

  if (!rows?.length) return <div className="table-wrap"><div className="state">{empty}</div></div>

  function alternar(c) {
    if (!ordenables.has(c.key)) return
    setOrden((o) =>
      o?.key === c.key
        ? { key: c.key, desc: !o.desc }
        : { key: c.key, desc: Boolean(c.num) } // numéricas arrancan de mayor a menor
    )
  }

  return (
    <div className="table-wrap">
      <table className="data">
        <thead>
          <tr>
            {columns.map((c) => {
              const puede = ordenables.has(c.key)
              const activo = orden?.key === c.key
              return (
                <th
                  key={c.key}
                  className={[c.num ? 'num' : '', puede ? 'sortable' : '', activo ? 'sorted' : '']
                    .filter(Boolean)
                    .join(' ')}
                  onClick={() => alternar(c)}
                  title={puede ? 'Ordenar' : undefined}
                >
                  {c.label}
                  {activo && <span className="sort-arrow">{orden.desc ? '↓' : '↑'}</span>}
                </th>
              )
            })}
          </tr>
        </thead>
        <tbody>{filas.map(renderRow)}</tbody>
      </table>
    </div>
  )
}

export function Loading() {
  return <div className="table-wrap"><div className="state">Cargando…</div></div>
}

export function ErrorBox({ message }) {
  return <div className="notice notice-error">{message}</div>
}

export function Badge({ children, tone }) {
  const cls = tone ? `badge badge-${tone}` : 'badge'
  return <span className={cls}>{children}</span>
}

export function Kpi({ label, value, hint }) {
  return (
    <div className="card">
      <div className="kpi-label">{label}</div>
      <div
        className="kpi-value"
        style={{ color: value == null ? 'var(--text-muted)' : 'var(--text)' }}
      >
        {value ?? '—'}
      </div>
      {hint && <div className="kpi-hint">{hint}</div>}
    </div>
  )
}

/** Panel lateral para altas y ediciones. */
/**
 * Panel lateral de alta y edición.
 *
 * `onDelete` agrega una baja al pie. La confirmación la pide el propio botón en
 * vez de un `confirm()` del navegador: el segundo click es deliberado, y el
 * primero se deshace apretando en cualquier otro lado del panel.
 */
export function Drawer({
  title,
  onClose,
  onSubmit,
  submitting,
  children,
  submitLabel = 'Guardar',
  onDelete,
  deleteLabel = 'Eliminar',
}) {
  const [confirmando, setConfirmando] = useState(false)

  return (
    <>
      <div className="drawer-scrim" onClick={onClose} />
      <form
        className="drawer"
        onSubmit={(e) => {
          e.preventDefault()
          onSubmit()
        }}
      >
        <div className="drawer-head">
          <h2>{title}</h2>
          <button type="button" className="icon-btn" onClick={onClose} aria-label="Cerrar">
            ×
          </button>
        </div>
        <div className="drawer-body" onClick={() => confirmando && setConfirmando(false)}>
          {children}
        </div>
        <div className="drawer-foot">
          {onDelete && (
            <button
              type="button"
              className="btn btn-danger"
              disabled={submitting}
              style={{ marginRight: 'auto' }}
              onClick={() => (confirmando ? onDelete() : setConfirmando(true))}
            >
              {confirmando ? 'Confirmar: no se puede deshacer' : deleteLabel}
            </button>
          )}
          <button type="button" className="btn" onClick={onClose}>
            Cancelar
          </button>
          <button type="submit" className="btn btn-primary" disabled={submitting}>
            {submitting ? 'Guardando…' : submitLabel}
          </button>
        </div>
      </form>
    </>
  )
}

export function Field({ label, hint, children }) {
  return (
    <div className="field">
      <label>{label}</label>
      {children}
      {hint && (
        <span style={{ fontSize: '0.75rem', color: 'var(--text-muted)' }}>{hint}</span>
      )}
    </div>
  )
}
