import { useState } from 'react'
import { useParams, Link } from 'react-router-dom'
import { useAsync } from '../lib/useAsync'
import { getProject, getProjectPnl } from '../lib/queries'
import { usd, pct, date, variance } from '../lib/format'
import { Loading, ErrorBox, Badge, Kpi } from '../components/ui'
import Presupuesto from './proyecto/Presupuesto'
import Gastos from './proyecto/Gastos'
import Ingresos from './proyecto/Ingresos'
import Desvios from './proyecto/Desvios'
import Cronograma from './proyecto/Cronograma'

const STATUS = {
  idea: 'Idea',
  evaluacion: 'Evaluación',
  aprobado: 'Aprobado',
  en_construccion: 'En construcción',
  terminado: 'Terminado',
  vendido: 'Vendido',
  cerrado: 'Cerrado',
}

const TABS = [
  ['resumen', 'Resumen'],
  ['presupuesto', 'Presupuesto'],
  ['gastos', 'Gastos'],
  ['ingresos', 'Ingresos'],
  ['desvios', 'Desvíos'],
  ['cronograma', 'Cronograma'],
]

/** Desvío contra el budget original, con signo y color. Un sobrecosto es malo. */
function Variacion({ actual, baseline }) {
  const { abs, rel } = variance(actual, baseline)
  if (abs == null || !baseline) return <span style={{ color: 'var(--text-muted)' }}>—</span>
  const over = abs > 0
  return (
    <span className={over ? 'var-neg' : 'var-pos'}>
      {over ? '+' : ''}
      {usd(abs)} {rel != null && <>({over ? '+' : ''}{pct(rel)})</>}
    </span>
  )
}

export default function Proyecto() {
  const { id } = useParams()
  const [tab, setTab] = useState('resumen')

  const project = useAsync(() => getProject(id), [id])
  const pnl = useAsync(() => getProjectPnl(id), [id])

  if (project.loading || pnl.loading) return <Loading />
  if (project.error) return <ErrorBox message={project.error} />

  const p = project.data
  const f = pnl.data ?? {}

  /* Avance económico: lo ejecutado sobre lo que se espera gastar.
     Es distinto del avance físico (días), que llega en Fase 5. */
  const avance = f.forecast_cost_usd > 0 ? f.actual_cost_usd / f.forecast_cost_usd : 0
  /* Los dos margenes vienen calculados de project_pnl, no se recalculan acá. */
  const margenVenta = f.margin_on_revenue
  const margenCosto = f.margin_on_cost

  return (
    <div>
      <div style={{ marginBottom: 18 }}>
        <Link to="/proyectos" style={{ color: 'var(--text-muted)', fontSize: '0.875rem' }}>
          ← Proyectos
        </Link>
        <div style={{ display: 'flex', alignItems: 'center', gap: 12, marginTop: 6 }}>
          <h1>{p.name}</h1>
          <Badge>{STATUS[p.status] ?? p.status}</Badge>
        </div>
        <p style={{ margin: '4px 0 0', color: 'var(--text-muted)' }}>
          {p.code}
          {p.location && ` · ${p.location}`}
          {p.surface_m2 && ` · ${p.surface_m2} m²`}
          {p.planned_finish && ` · fin previsto ${date(p.planned_finish)}`}
        </p>
      </div>

      <div className="tabs">
        {TABS.map(([key, label]) => (
          <button
            key={key}
            className={`tab${tab === key ? ' active' : ''}`}
            onClick={() => setTab(key)}
          >
            {label}
          </button>
        ))}
      </div>

      {tab === 'resumen' && (
        <div style={{ display: 'grid', gap: 24 }}>
          <div className="kpi-grid">
            <Kpi label="Budget original" value={usd(f.budget_usd)} hint="Congelado" />
            <Kpi label="Forecast de costo" value={usd(f.forecast_cost_usd)} hint="Actual + pendiente" />
            <Kpi label="Actual" value={usd(f.actual_cost_usd)} hint="Recibido o pagado" />
            <Kpi label="Comprometido" value={usd(f.committed_cost_usd)} hint="Aprobado, sin recibir" />
            <Kpi label="Ingresos" value={usd(f.revenue_usd)} hint="Realizados" />
            <Kpi label="Venta estimada" value={usd(f.revenue_target_usd)} />
            <Kpi label="Profit proyectado" value={usd(f.forecast_profit_usd)} hint="Neto de comisión" />
            <Kpi label="Margen sobre venta" value={margenVenta == null ? null : pct(margenVenta)} />
            <Kpi label="Margen sobre costo" value={margenCosto == null ? null : pct(margenCosto)} hint="Criterio del reparto" />
          </div>

          <section className="card" style={{ display: 'grid', gap: 14 }}>
            <h2>Presupuesto vs ejecución</h2>

            <div style={{ display: 'grid', gap: 6 }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '0.875rem' }}>
                <span style={{ color: 'var(--text-muted)' }}>Avance económico</span>
                <span className="num">{pct(avance)}</span>
              </div>
              <div className={`bar${avance > 1 ? ' over' : ''}`}>
                <span style={{ width: `${Math.min(avance, 1) * 100}%` }} />
              </div>
            </div>

            <table className="data" style={{ marginTop: 6 }}>
              <tbody>
                <tr>
                  <td>Budget original</td>
                  <td className="num">{usd(f.budget_usd)}</td>
                  <td></td>
                </tr>
                <tr>
                  <td>Forecast de costo</td>
                  <td className="num">{usd(f.forecast_cost_usd)}</td>
                  <td className="num">
                    <Variacion actual={f.forecast_cost_usd} baseline={f.budget_usd} />
                  </td>
                </tr>
                <tr>
                  <td>Actual</td>
                  <td className="num">{usd(f.actual_cost_usd)}</td>
                  <td className="num">
                    <Variacion actual={f.actual_cost_usd} baseline={f.budget_usd} />
                  </td>
                </tr>
                <tr>
                  <td>Comisión inmobiliaria ({pct(p.broker_fee_pct)})</td>
                  <td className="num">{usd(f.broker_fee_usd)}</td>
                  <td></td>
                </tr>
              </tbody>
            </table>
          </section>

          {f.budget_usd === 0 && (
            <div className="notice notice-warning">
              Este proyecto todavía no tiene presupuesto cargado. Sin budget, el
              forecast se calcula solo sobre lo ya gastado y comprometido, y el
              desvío no se puede medir.
            </div>
          )}
        </div>
      )}

      {tab === 'presupuesto' && <Presupuesto projectId={id} onChange={pnl.reload} />}
      {tab === 'gastos' && <Gastos projectId={id} onChange={pnl.reload} />}
      {tab === 'ingresos' && <Ingresos projectId={id} onChange={pnl.reload} />}
      {tab === 'desvios' && <Desvios projectId={id} />}
      {tab === 'cronograma' && <Cronograma projectId={id} />}
    </div>
  )
}
