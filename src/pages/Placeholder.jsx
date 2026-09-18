/**
 * Pantalla aún no construida. Declara en qué fase llega, para que quede claro
 * que falta y no parezca una sección rota.
 */
export default function Placeholder({ title, phase, detail }) {
  return (
    <div style={{ display: 'grid', gap: 16 }}>
      <h1>{title}</h1>
      <div className="card" style={{ display: 'grid', gap: 8 }}>
        <div style={{ fontWeight: 600 }}>Llega en {phase}</div>
        <p style={{ margin: 0, color: 'var(--text-muted)' }}>{detail}</p>
      </div>
    </div>
  )
}
