import { useAsync } from '../../lib/useAsync'
import { listProcurementVariance, listRubroTotals } from '../../lib/queries'
import { usd, pct, variance } from '../../lib/format'
import { Table, Loading, ErrorBox } from '../../components/ui'

/** Variación contra el budget. Positivo = más caro = malo. */
function Var({ actual, baseline }) {
  const { abs, rel } = variance(actual, baseline)
  if (abs == null || !baseline) return <span style={{ color: 'var(--text-muted)' }}>—</span>
  if (Math.abs(abs) < 0.005) return <span style={{ color: 'var(--text-muted)' }}>0</span>
  const over = abs > 0
  return (
    <span className={over ? 'var-neg' : 'var-pos'}>
      {over ? '+' : ''}{usd(abs)}
      {rel != null && ` (${over ? '+' : ''}${pct(rel)})`}
    </span>
  )
}

export default function Desvios({ projectId }) {
  const lines = useAsync(() => listProcurementVariance(projectId), [projectId])
  const porRubro = useAsync(() => listRubroTotals(projectId), [projectId])
  /* Los rubros sin presupuesto ni gasto no dicen nada: se omiten. */
  const rubros = (porRubro.data ?? []).filter(
    (r) => Number(r.budget_usd) || Number(r.forecast_usd) || Number(r.actual_usd) || Number(r.committed_usd)
  )

  const rows = lines.data ?? []

  /* Las líneas que más se desviaron, en plata. Responde "qué items están
     generando desviaciones" de la sección 24. */
  const peores = [...rows]
    .filter((r) => Number(r.budget_usd) > 0 && Number(r.actual_usd) > 0)
    .sort(
      (a, b) =>
        Number(b.actual_usd) - Number(b.budget_usd) - (Number(a.actual_usd) - Number(a.budget_usd))
    )
    .slice(0, 5)

  return (
    <div style={{ display: 'grid', gap: 24 }}>
      <p style={{ margin: 0, color: 'var(--text-muted)', fontSize: '0.9375rem' }}>
        Budget → Quote → Purchase → Actual, por línea de presupuesto. El quote es la
        mejor cotización disponible para el item, por la cantidad presupuestada.
      </p>

      {lines.error && <ErrorBox message={lines.error} />}

      {lines.loading ? (
        <Loading />
      ) : (
        <>
          {peores.length > 0 && (
            <div className="notice notice-warning">
              <strong>Mayores desvíos:</strong>{' '}
              {peores
                .map((r) => `${r.description} (${usd(Number(r.actual_usd) - Number(r.budget_usd))})`)
                .join(' · ')}
            </div>
          )}

          <section style={{ display: 'grid', gap: 12 }}>
            <h2>Por línea</h2>
            <Table
              columns={[
                { key: 'cat', label: 'Categoría' },
                { key: 'desc', label: 'Item' },
                { key: 'b', label: 'Budget', num: true },
                { key: 'q', label: 'Quote', num: true },
                { key: 'p', label: 'Purchased', num: true },
                { key: 'a', label: 'Actual', num: true },
                { key: 'v', label: 'Desvío vs budget', num: true },
              ]}
              rows={rows}
              empty="Este proyecto todavía no tiene líneas de presupuesto."
              renderRow={(r) => (
                <tr key={r.budget_line_id}>
                  <td style={{ color: 'var(--text-muted)' }}>{r.categoria ?? '—'}</td>
                  <td>{r.description}</td>
                  <td className="num">{usd(r.budget_usd)}</td>
                  <td className="num">{usd(r.quoted_usd)}</td>
                  <td className="num">{usd(r.purchased_usd)}</td>
                  <td className="num">{usd(r.actual_usd)}</td>
                  <td className="num"><Var actual={r.actual_usd} baseline={r.budget_usd} /></td>
                </tr>
              )}
            />
          </section>

          <section style={{ display: 'grid', gap: 12 }}>
            <h2>Por rubro</h2>
            {porRubro.error && <ErrorBox message={porRubro.error} />}
            <Table
              columns={[
                { key: 'rubro', label: 'Rubro', sort: (r) => r.sort_order },
                { key: 'budget_usd', label: 'Budget', num: true },
                { key: 'forecast_usd', label: 'Forecast', num: true },
                { key: 'actual_usd', label: 'Actual', num: true },
                { key: 'committed_usd', label: 'Comprometido', num: true },
                { key: 'v', label: 'Desvío', num: true, sort: (r) => r.actual_usd - r.budget_usd },
              ]}
              rows={rubros}
              empty="Sin presupuesto ni gastos por rubro todavía."
              renderRow={(r) => (
                <tr key={r.project_rubro_id}>
                  <td style={{ fontWeight: 500 }}>{r.rubro}</td>
                  <td className="num">{usd(r.budget_usd)}</td>
                  <td className="num">{usd(r.forecast_usd)}</td>
                  <td className="num">{usd(r.actual_usd)}</td>
                  <td className="num">{usd(r.committed_usd)}</td>
                  <td className="num"><Var actual={r.actual_usd} baseline={r.budget_usd} /></td>
                </tr>
              )}
            />
            <p style={{ margin: 0, color: 'var(--text-muted)', fontSize: '0.8125rem' }}>
              Por rubro cuenta todo lo gastado en ese rubro, esté o no enlazado a una línea
              del presupuesto.
            </p>
          </section>
        </>
      )}
    </div>
  )
}
