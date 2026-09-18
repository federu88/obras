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

export function Table({ columns, rows, empty = 'Todavía no hay registros.', renderRow }) {
  if (!rows?.length) return <div className="table-wrap"><div className="state">{empty}</div></div>

  return (
    <div className="table-wrap">
      <table className="data">
        <thead>
          <tr>
            {columns.map((c) => (
              <th key={c.key} className={c.num ? 'num' : undefined}>
                {c.label}
              </th>
            ))}
          </tr>
        </thead>
        <tbody>{rows.map(renderRow)}</tbody>
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
export function Drawer({ title, onClose, onSubmit, submitting, children, submitLabel = 'Guardar' }) {
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
        <div className="drawer-body">{children}</div>
        <div className="drawer-foot">
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
