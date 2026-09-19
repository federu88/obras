import { useState } from 'react'
import { Link } from 'react-router-dom'
import { useAsync } from '../lib/useAsync'
import {
  getBusinessSummary,
  listProjectHealth,
  listCashRequirements,
  listInvestorSummary,
  puedeVerEncargo,
} from '../lib/queries'
import DashboardEncargo from './DashboardEncargo'
import { usd, pct } from '../lib/format'
import { PageHead, Table, Loading, ErrorBox, Badge, Kpi } from '../components/ui'

const MES = new Intl.DateTimeFormat('es-AR', { month: 'short', year: 'numeric' })
const mes = (d) => MES.format(new Date(d + 'T00:00:00'))

export default function Dashboard() {
  const [negocio, setNegocio] = useState('desarrollo')

  const summary = useAsync(getBusinessSummary)
  const health = useAsync(listProjectHealth)
  const requirements = useAsync(listCashRequirements)
  const investors = useAsync(listInvestorSummary)
  const permisoEncargo = useAsync(puedeVerEncargo)

  const loading = summary.loading || health.loading
  const error = summary.error || health.error

  const s = summary.data ?? {}
  /* El selector se muestra por PERMISO, no porque ya existan obras por
     encargo. Atarlo a que haya datos dejaba al estudio sin forma de llegar a
     la pantalla donde se crea la primera. Para un inversor can_see_encargo()
     devuelve falso y el selector no aparece: no hay pestaña vacía que invite
     a preguntar qué hay del otro lado. */
  const hayEncargo = permisoEncargo.data === true
  const proyectos = health.data ?? []
  const conProblemas = proyectos.filter((p) => p.problema_costo || p.problema_plazo)
  const necesidades = requirements.data ?? []

  const vacio = !loading && (s.proyectos_total ?? 0) === 0 && (investors.data ?? []).length === 0

  return (
    <div style={{ display: 'grid', gap: 24 }}>
      <PageHead
        title="Dashboard"
        subtitle={
          hayEncargo
            ? 'Dos negocios distintos, con indicadores distintos. Todos los importes en USD.'
            : 'Posición consolidada del negocio. Todos los importes en USD.'
        }
      />

      {hayEncargo && (
        <div className="tabs">
          <button
            className={`tab${negocio === 'desarrollo' ? ' active' : ''}`}
            onClick={() => setNegocio('desarrollo')}
          >
            Desarrollo propio
          </button>
          <button
            className={`tab${negocio === 'encargo' ? ' active' : ''}`}
            onClick={() => setNegocio('encargo')}
          >
            Obra por encargo
          </button>
        </div>
      )}

      {negocio === 'encargo' && <DashboardEncargo />}

      {negocio === 'desarrollo' && error && <ErrorBox message={error} />}

      {negocio === 'encargo' ? null : loading ? (
        <Loading />
      ) : vacio ? (
        <div className="notice notice-warning">
          <strong>El sistema está vacío.</strong> Cargá una obra en{' '}
          <Link to="/proyectos" style={{ color: 'var(--accent)' }}>Proyectos</Link> y los
          inversores en{' '}
          <Link to="/inversores" style={{ color: 'var(--accent)' }}>Inversores</Link> para
          empezar a ver números reales acá.
        </div>
      ) : (
        <>
          {/* --- Alertas primero: lo que requiere acción --- */}
          {conProblemas.length > 0 && (
            <div className="notice notice-warning">
              <strong>
                {conProblemas.length === 1
                  ? '1 obra con problemas'
                  : `${conProblemas.length} obras con problemas`}
                :
              </strong>{' '}
              {conProblemas
                .map(
                  (p) =>
                    `${p.code} (${[
                      p.problema_costo && 'costo',
                      p.problema_plazo && 'plazo',
                    ]
                      .filter(Boolean)
                      .join(' y ')})`
                )
                .join(' · ')}
            </div>
          )}

          {necesidades.length > 0 && (
            <div className="notice notice-warning">
              <strong>Necesidad de caja:</strong>{' '}
              {necesidades
                .slice(0, 3)
                .map((r) => `${r.code} ${usd(r.necesidad_usd)} en ${mes(r.month)}`)
                .join(' · ')}
            </div>
          )}

          {/* --- Capital --- */}
          <section style={{ display: 'grid', gap: 12 }}>
            <h2>Capital</h2>
            <div className="kpi-grid">
              <Kpi label="Aportado" value={usd(s.capital_aportado_usd)} hint="Total histórico" />
              <Kpi label="Invertido" value={usd(s.capital_invertido_usd)} hint="Aportes − retiros + reinversiones" />
              <Kpi label="Disponible" value={usd(s.capital_disponible_usd)} hint="Caja − comprometido" />
              <Kpi label="Comprometido" value={usd(s.comprometido_usd)} hint="Aprobado, sin recibir" />
            </div>
          </section>

          {/* --- Resultado --- */}
          <section style={{ display: 'grid', gap: 12 }}>
            <h2>Resultado</h2>
            <div className="kpi-grid">
              <Kpi label="Resultado acumulado" value={usd(s.resultado_acumulado_usd)} hint="Ingresos − costo actual" />
              <Kpi label="Profit proyectado" value={usd(s.profit_proyectado_usd)} hint="Si todo cierra como se prevé" />
              <Kpi label="Profit distribuido" value={usd(s.profit_realizado_usd)} hint="Pagado a inversores" />
              <Kpi label="Profit pendiente" value={usd(s.profit_pendiente_usd)} hint="Asignado, sin cobrar" />
              <Kpi label="Profit reinvertido" value={usd(s.profit_reinvertido_usd)} />
              <Kpi label="Obras activas" value={s.proyectos_activos} />
              <Kpi label="Obras terminadas" value={s.proyectos_terminados} />
              <Kpi label="Inversores" value={(investors.data ?? []).length} />
            </div>
          </section>

          {/* --- Por proyecto --- */}
          <section style={{ display: 'grid', gap: 12 }}>
            <h2>Por obra</h2>
            <Table
              columns={[
                { key: 'code', label: 'Obra' },
                { key: 'budget_usd', label: 'Budget', num: true },
                { key: 'forecast_cost_usd', label: 'Forecast', num: true },
                { key: 'actual_cost_usd', label: 'Actual', num: true },
                { key: 'desvio_costo_rel', label: 'Desvío', num: true },
                { key: 'forecast_profit_usd', label: 'Profit proy.', num: true },
                { key: 'avance_real', label: 'Avance', num: true },
                { key: 'flags', label: 'Estado', sort: (p) => (p.problema_costo ? 2 : 0) + (p.problema_plazo ? 1 : 0) },
              ]}
              rows={proyectos}
              empty="Todavía no hay obras cargadas."
              renderRow={(p) => (
                <tr key={p.project_id}>
                  <td style={{ fontWeight: 500 }}>
                    <Link to={`/proyectos/${p.project_id}`} style={{ color: 'var(--accent)' }}>
                      {p.code}
                    </Link>{' '}
                    {p.name}
                  </td>
                  <td className="num">{usd(p.budget_usd)}</td>
                  <td className="num">{usd(p.forecast_cost_usd)}</td>
                  <td className="num">{usd(p.actual_cost_usd)}</td>
                  <td className={`num ${p.desvio_costo_rel > 0 ? 'var-neg' : 'var-pos'}`}>
                    {p.desvio_costo_rel == null ? '—' : pct(p.desvio_costo_rel)}
                  </td>
                  <td className={`num ${Number(p.forecast_profit_usd) < 0 ? 'var-neg' : ''}`}>
                    {usd(p.forecast_profit_usd)}
                  </td>
                  <td className="num">
                    {p.avance_real == null ? '—' : pct(p.avance_real)}
                  </td>
                  <td style={{ display: 'flex', gap: 4 }}>
                    {p.problema_costo && <Badge tone="off">costo</Badge>}
                    {p.problema_plazo && <Badge tone="off">plazo</Badge>}
                    {!p.problema_costo && !p.problema_plazo && <Badge tone="ok">ok</Badge>}
                  </td>
                </tr>
              )}
            />
          </section>

          {/* --- Por inversor --- */}
          <section style={{ display: 'grid', gap: 12 }}>
            <h2>Por inversor</h2>
            <Table
              columns={[
                { key: 'name', label: 'Inversor' },
                { key: 'capital_invertido_usd', label: 'Capital invertido', num: true },
                { key: 'profit_pendiente_usd', label: 'Profit pendiente', num: true },
                { key: 'profit_cobrado_usd', label: 'Profit cobrado', num: true },
                { key: 'proyectos_activos', label: 'Obras', num: true },
              ]}
              rows={investors.data ?? []}
              empty="Todavía no hay inversores cargados."
              renderRow={(i) => (
                <tr key={i.investor_id}>
                  <td style={{ fontWeight: 500 }}>
                    <Link to={`/inversores/${i.investor_id}`} style={{ color: 'var(--accent)' }}>
                      {i.name}
                    </Link>
                  </td>
                  <td className="num">{usd(i.capital_invertido_usd)}</td>
                  <td className="num">{usd(i.profit_pendiente_usd)}</td>
                  <td className="num">{usd(i.profit_cobrado_usd)}</td>
                  <td className="num">{i.proyectos_activos}</td>
                </tr>
              )}
            />
          </section>

          {necesidades.length > 0 && (
            <section style={{ display: 'grid', gap: 12 }}>
              <h2>Próximas necesidades de caja</h2>
              <Table
                columns={[
                  { key: 'p', label: 'Obra' },
                  { key: 'month', label: 'Mes' },
                  { key: 'necesidad_usd', label: 'Necesidad', num: true },
                ]}
                rows={necesidades}
                renderRow={(r) => (
                  <tr key={`${r.project_id}-${r.month}`}>
                    <td>{r.code} {r.name}</td>
                    <td>{mes(r.month)}</td>
                    <td className="num var-neg">{usd(r.necesidad_usd)}</td>
                  </tr>
                )}
              />
            </section>
          )}
        </>
      )}
    </div>
  )
}
