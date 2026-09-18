import { useAsync } from '../lib/useAsync'
import { listInvestorSummary, listProjects, listProjectCapital } from '../lib/queries'
import { usd } from '../lib/format'
import { PageHead, Kpi, Table, Loading, ErrorBox, Badge } from '../components/ui'

const ACTIVOS = ['aprobado', 'en_construccion']
const TERMINADOS = ['terminado', 'vendido', 'cerrado']

const sum = (rows, key) => (rows ?? []).reduce((a, r) => a + Number(r[key] ?? 0), 0)

export default function Dashboard() {
  const investors = useAsync(listInvestorSummary)
  const projects = useAsync(listProjects)
  const capital = useAsync(listProjectCapital)

  const loading = investors.loading || projects.loading || capital.loading
  const error = investors.error || projects.error || capital.error

  const capitalInvertido = sum(investors.data, 'capital_invertido_usd')
  const profitPendiente = sum(investors.data, 'profit_pendiente_usd')
  const profitCobrado = sum(investors.data, 'profit_cobrado_usd')

  const activos = (projects.data ?? []).filter((p) => ACTIVOS.includes(p.status))
  const terminados = (projects.data ?? []).filter((p) => TERMINADOS.includes(p.status))

  const capitalByProject = Object.fromEntries(
    (capital.data ?? []).map((c) => [c.project_id, c])
  )

  return (
    <div style={{ display: 'grid', gap: 24 }}>
      <PageHead
        title="Dashboard"
        subtitle="Posición consolidada del negocio. Todos los importes en USD."
      />

      {error && <ErrorBox message={error} />}

      {loading ? (
        <Loading />
      ) : (
        <>
          <div className="kpi-grid">
            <Kpi
              label="Capital invertido"
              value={usd(capitalInvertido)}
              hint="Aportes − retiros + reinversiones"
            />
            <Kpi
              label="Profit pendiente"
              value={usd(profitPendiente)}
              hint="Asignado, sin cobrar ni reinvertir"
            />
            <Kpi
              label="Profit cobrado"
              value={usd(profitCobrado)}
              hint="Efectivamente distribuido"
            />
            <Kpi label="Proyectos activos" value={activos.length} hint="Aprobados o en construcción" />
            <Kpi label="Proyectos terminados" value={terminados.length} hint="Terminados, vendidos o cerrados" />
            <Kpi label="Inversores" value={(investors.data ?? []).length} />
            <Kpi label="Capital disponible" value={null} hint="Fase 3 — requiere caja" />
            <Kpi label="Resultado acumulado" value={null} hint="Fase 3 — requiere costos e ingresos" />
          </div>

          <section style={{ display: 'grid', gap: 12 }}>
            <h2>Capital por proyecto</h2>
            <Table
              columns={[
                { key: 'code', label: 'Código' },
                { key: 'name', label: 'Proyecto' },
                { key: 'status', label: 'Estado' },
                { key: 'cap', label: 'Capital aportado', num: true },
                { key: 'budget', label: 'Presupuesto', num: true },
              ]}
              rows={projects.data ?? []}
              empty="Todavía no hay proyectos cargados."
              renderRow={(p) => (
                <tr key={p.id}>
                  <td style={{ fontWeight: 500 }}>{p.code}</td>
                  <td>{p.name}</td>
                  <td><Badge>{p.status.replace('_', ' ')}</Badge></td>
                  <td className="num">{usd(capitalByProject[p.id]?.capital_aportado_usd)}</td>
                  <td className="num">{usd(p.budget_usd)}</td>
                </tr>
              )}
            />
          </section>

          <section style={{ display: 'grid', gap: 12 }}>
            <h2>Posición por inversor</h2>
            <Table
              columns={[
                { key: 'name', label: 'Inversor' },
                { key: 'cap', label: 'Capital invertido', num: true },
                { key: 'pend', label: 'Profit pendiente', num: true },
                { key: 'cobr', label: 'Profit cobrado', num: true },
              ]}
              rows={investors.data ?? []}
              empty="Todavía no hay inversores cargados."
              renderRow={(i) => (
                <tr key={i.investor_id}>
                  <td style={{ fontWeight: 500 }}>{i.name}</td>
                  <td className="num">{usd(i.capital_invertido_usd)}</td>
                  <td className="num">{usd(i.profit_pendiente_usd)}</td>
                  <td className="num">{usd(i.profit_cobrado_usd)}</td>
                </tr>
              )}
            />
          </section>
        </>
      )}
    </div>
  )
}
