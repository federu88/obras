import { usd } from '../lib/format'

/**
 * Dashboard consolidado.
 *
 * Fase 1 monta la estructura; los indicadores quedan vacíos a propósito.
 * La regla 1 del proyecto es no inventar datos financieros: preferimos un
 * guion a un número plausible que después nadie sepa de dónde salió.
 */

const KPIS = [
  { label: 'Capital aportado', value: null, hint: 'Fase 2' },
  { label: 'Capital invertido', value: null, hint: 'Fase 2' },
  { label: 'Capital disponible', value: null, hint: 'Fase 2' },
  { label: 'Capital comprometido', value: null, hint: 'Fase 4' },
  { label: 'Resultado acumulado', value: null, hint: 'Fase 3' },
  { label: 'Profit realizado', value: null, hint: 'Fase 6' },
  { label: 'Profit proyectado', value: null, hint: 'Fase 3' },
  { label: 'Proyectos activos', value: null, hint: 'Fase 2', raw: true },
]

export default function Dashboard() {
  return (
    <div style={{ display: 'grid', gap: 20 }}>
      <div>
        <h1>Dashboard</h1>
        <p style={{ margin: '4px 0 0', color: 'var(--text-muted)' }}>
          Posición consolidada del negocio. Todos los importes en USD.
        </p>
      </div>

      <div className="notice notice-warning">
        <strong>Fase 1 — Foundation.</strong> Están montados el esquema, la
        autenticación, los roles y la navegación. Los indicadores se completan en
        las fases 2 y 3, cuando existan inversores y movimientos de capital.
      </div>

      <div
        style={{
          display: 'grid',
          gap: 12,
          gridTemplateColumns: 'repeat(auto-fill, minmax(210px, 1fr))',
        }}
      >
        {KPIS.map((k) => (
          <div className="card" key={k.label}>
            <div
              style={{
                fontSize: '0.8125rem',
                color: 'var(--text-muted)',
                marginBottom: 8,
              }}
            >
              {k.label}
            </div>
            <div
              className="num"
              style={{
                fontSize: '1.5rem',
                fontWeight: 600,
                textAlign: 'left',
                color: k.value == null ? 'var(--text-muted)' : 'var(--text)',
              }}
            >
              {k.value == null ? '—' : k.raw ? k.value : usd(k.value)}
            </div>
            <div
              style={{
                marginTop: 6,
                fontSize: '0.75rem',
                color: 'var(--text-muted)',
              }}
            >
              {k.hint}
            </div>
          </div>
        ))}
      </div>
    </div>
  )
}
