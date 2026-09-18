import { Link } from 'react-router-dom'
import { useAsync } from '../lib/useAsync'
import { listPnl } from '../lib/queries'
import { usd, pct } from '../lib/format'
import { PageHead, Table, Loading, ErrorBox, Kpi } from '../components/ui'

const sum = (rows, key) => (rows ?? []).reduce((a, r) => a + Number(r[key] ?? 0), 0)

export default function Pnl() {
  const pnl = useAsync(listPnl)
  const rows = pnl.data ?? []

  const revenue = sum(rows, 'revenue_usd')
  const actual = sum(rows, 'actual_cost_usd')
  const forecastCost = sum(rows, 'forecast_cost_usd')
  const forecastProfit = sum(rows, 'forecast_profit_usd')
  const targetRevenue = sum(rows, 'revenue_target_usd')
  const margenVenta = targetRevenue > 0 ? forecastProfit / targetRevenue : null
  /* Margen sobre costo: es el criterio del reparto real. Mide cuánto rinde la
     plata puesta, no cuánto queda de cada dólar vendido. */
  const margenCosto = forecastCost > 0 ? forecastProfit / forecastCost : null

  return (
    <div style={{ display: 'grid', gap: 24 }}>
      <PageHead
        title="P&L"
        subtitle="Resultado por proyecto y consolidado. Budget, forecast y actual lado a lado."
      />

      {pnl.error && <ErrorBox message={pnl.error} />}

      {pnl.loading ? (
        <Loading />
      ) : (
        <>
          <div className="kpi-grid">
            <Kpi label="Ingresos realizados" value={usd(revenue)} />
            <Kpi label="Venta estimada" value={usd(targetRevenue)} hint="Objetivo de todos los proyectos" />
            <Kpi label="Costo actual" value={usd(actual)} hint="Recibido o pagado" />
            <Kpi label="Costo proyectado" value={usd(forecastCost)} />
            <Kpi label="Profit proyectado" value={usd(forecastProfit)} hint="Neto de comisión" />
            <Kpi label="Margen sobre venta" value={margenVenta == null ? null : pct(margenVenta)} />
            <Kpi label="Margen sobre costo" value={margenCosto == null ? null : pct(margenCosto)} hint="Criterio del reparto" />
          </div>

          <Table
            columns={[
              { key: 'code', label: 'Código' },
              { key: 'name', label: 'Proyecto' },
              { key: 'budget_usd', label: 'Budget', num: true },
              { key: 'forecast_cost_usd', label: 'Forecast', num: true },
              { key: 'actual_cost_usd', label: 'Actual', num: true },
              { key: 'committed_cost_usd', label: 'Comprometido', num: true },
              { key: 'revenue_usd', label: 'Ingresos', num: true },
              { key: 'forecast_profit_usd', label: 'Profit proyectado', num: true },
            ]}
            rows={rows}
            empty="Todavía no hay proyectos."
            renderRow={(r) => (
              <tr key={r.project_id}>
                <td style={{ fontWeight: 500 }}>
                  <Link to={`/proyectos/${r.project_id}`} style={{ color: 'var(--accent)' }}>
                    {r.code}
                  </Link>
                </td>
                <td>{r.name}</td>
                <td className="num">{usd(r.budget_usd)}</td>
                <td className="num">{usd(r.forecast_cost_usd)}</td>
                <td className="num">{usd(r.actual_cost_usd)}</td>
                <td className="num">{usd(r.committed_cost_usd)}</td>
                <td className="num">{usd(r.revenue_usd)}</td>
                <td
                  className={`num ${Number(r.forecast_profit_usd) < 0 ? 'var-neg' : ''}`}
                  style={{ fontWeight: 500 }}
                >
                  {usd(r.forecast_profit_usd)}
                </td>
              </tr>
            )}
          />

          <p style={{ margin: 0, color: 'var(--text-muted)', fontSize: '0.8125rem' }}>
            Forecast de costo = el mayor entre el forecast de presupuesto y lo ya
            ejecutado más comprometido. No se puede prever gastar menos de lo ya gastado.
          </p>
        </>
      )}
    </div>
  )
}
