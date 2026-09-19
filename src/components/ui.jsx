import { useCallback, useEffect, useMemo, useState } from 'react'
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
 * Tarjeta de alta y edicion.
 *
 * NO se cierra al hacer click afuera. Suena a detalle y no lo es: cargar una
 * obra son quince campos, y perderlos por un click al costado de la ventana es
 * el tipo de error que hace que la gente deje de usar la herramienta. Para
 * salir hay que decirlo: Cancelar, la cruz, o Escape.
 *
 * Y si ya se escribio algo, Cancelar pide confirmacion. Un click de mas cuando
 * hay algo que perder; ninguno cuando no lo hay.
 *
 * `onDelete` agrega la baja al pie, con la misma confirmacion en el propio
 * boton.
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
  const [confirmandoBaja, setConfirmandoBaja] = useState(false)
  const [confirmandoSalida, setConfirmandoSalida] = useState(false)
  /* Alcanza con saber que alguien toco algo: no hace falta comparar contra el
     valor original para decidir si vale la pena preguntar. */
  const [tocado, setTocado] = useState(false)

  const intentarCerrar = useCallback(() => {
    if (!tocado) return onClose()
    setConfirmandoSalida(true)
  }, [tocado, onClose])

  useEffect(() => {
    const onKey = (e) => {
      if (e.key !== 'Escape') return
      e.stopPropagation()
      intentarCerrar()
    }
    window.addEventListener('keydown', onKey)
    return () => window.removeEventListener('keydown', onKey)
  }, [intentarCerrar])

  return (
    <>
      {/* Sin onClick: el fondo oscurece, no cierra. */}
      <div className="drawer-scrim" />
      <form
        className="drawer"
        onInput={() => setTocado(true)}
        onChange={() => setTocado(true)}
        onSubmit={(e) => {
          e.preventDefault()
          onSubmit()
        }}
      >
        <div className="drawer-head">
          <h2>{title}</h2>
          <button type="button" className="icon-btn" onClick={intentarCerrar} aria-label="Cerrar">
            ×
          </button>
        </div>

        <div
          className="drawer-body"
          onClick={() => {
            if (confirmandoBaja) setConfirmandoBaja(false)
            if (confirmandoSalida) setConfirmandoSalida(false)
          }}
        >
          {children}
        </div>

        <div className="drawer-foot">
          {onDelete && (
            <button
              type="button"
              className="btn btn-danger"
              disabled={submitting}
              style={{ marginRight: 'auto' }}
              onClick={() => (confirmandoBaja ? onDelete() : setConfirmandoBaja(true))}
            >
              {confirmandoBaja ? 'Confirmar: no se puede deshacer' : deleteLabel}
            </button>
          )}
          <button
            type="button"
            className={confirmandoSalida ? 'btn btn-danger' : 'btn'}
            onClick={() => (confirmandoSalida ? onClose() : intentarCerrar())}
          >
            {confirmandoSalida ? 'Descartar lo escrito' : 'Cancelar'}
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
