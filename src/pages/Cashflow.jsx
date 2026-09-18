import { useState } from 'react'
import { Link } from 'react-router-dom'
import { useAsync } from '../lib/useAsync'
import {
  listCashflowConsolidado,
  listProjectCashflow,
  listCashRequirements,
  listProjects,
} from '../lib/queries'
import { usd } from '../lib/format'
import { PageHead, Table, Loading, ErrorBox, Kpi } from '../components/ui'

const MES = new Intl.DateTimeFormat('es-AR', { month: 'short', year: 'numeric' })
const mes = (d) => MES.format(new Date(d + 'T00:00:00'))

const hoyMes = new Date().toISOString().slice(0, 7)

export default function Cashflow() {
  const [projectId, setProjectId] = useState('')

  const projects = useAsync(listProjects)
  const consolidado = useAsync(listCashflowConsolidado)
  const porProyecto = useAsync(
    () => (projectId ? listProjectCashflow(projectId) : Promise.resolve(null)),
    [projectId]
  )
  const requirements = useAsync(listCashRequirements)

  const rows = projectId ? porProyecto.data ?? [] : consolidado.data ?? []
  const loading = projectId ? porProyecto.loading : consolidado.loading
  const error = porProyecto.error || consolidado.error

  const futuros = rows.filter((r) => r.month.slice(0, 7) >= hoyMes)
  const saldoFinal = rows.length ? rows[rows.length - 1].closing_balance : null
  const necesidadMax = (requirements.data ?? []).reduce(
    (a, r) => Math.max(a, Number(r.necesidad_usd ?? 0)),
    0
  )

  return (
    <div style={{ display: 'grid', gap: 24 }}>
      <PageHead
        title="Cashflow"
        subtitle="Entradas y salidas por mes, con saldo acumulado. Realizado y proyectado en la misma línea de tiempo."
        action={
          <select
            value={projectId}
            onChange={(e) => setProjectId(e.target.value)}
            style={{
              padding: '9px 12px',
              border: '1px solid var(--border-strong)',
              borderRadius: 'var(--radius-sm)',
              background: 'var(--surface)',
              color: 'var(--text)',
            }}
          >
            <option value="">Consolidado</option>
            {(projects.data ?? []).map((p) => (
              <option key={p.id} value={p.id}>{p.code} · {p.name}</option>
            ))}
          </select>
        }
      />

      {error && <ErrorBox message={error} />}

      {(requirements.data ?? []).length > 0 && (
        <div className="notice notice-warning">
          <strong>Necesidad de caja detectada.</strong>{' '}
          {requirements.data.length === 1 ? 'Un mes cierra' : `${requirements.data.length} meses cierran`}{' '}
          en negativo. El peor es {usd(necesidadMax)} en{' '}
          {mes(requirements.data.reduce((a, r) => (Number(r.necesidad_usd) > Number(a.necesidad_usd) ? r : a)).month)}.
        </div>
      )}

      {loading ? (
        <Loading />
      ) : (
        <>
          <div className="kpi-grid">
            <Kpi label="Saldo proyectado final" value={usd(saldoFinal)} hint="Al último mes con movimientos" />
            <Kpi
              label="Entradas previstas"
              value={usd(futuros.reduce((a, r) => a + Number(r.inflows ?? 0), 0))}
              hint="De hoy en adelante"
            />
            <Kpi
              label="Salidas previstas"
              value={usd(futuros.reduce((a, r) => a + Number(r.outflows ?? 0), 0))}
              hint="De hoy en adelante"
            />
            <Kpi label="Meses con movimiento" value={rows.length} />
          </div>

          <Table
            columns={[
              { key: 'month', label: 'Mes' },
              { key: 'inflows', label: 'Entradas', num: true },
              { key: 'outflows', label: 'Salidas', num: true },
              { key: 'net', label: 'Neto', num: true },
              { key: 'net_realizado', label: 'Realizado', num: true },
              { key: 'net_proyectado', label: 'Proyectado', num: true },
              { key: 'closing_balance', label: 'Saldo acumulado', num: true },
            ]}
            rows={rows}
            empty="Todavía no hay movimientos. El cashflow se arma con aportes, gastos, ingresos y transferencias."
            renderRow={(r) => {
              const futuro = r.month.slice(0, 7) >= hoyMes
              return (
                <tr key={r.month} style={futuro ? { fontStyle: 'italic' } : undefined}>
                  <td>{mes(r.month)}</td>
                  <td className="num var-pos">{usd(r.inflows)}</td>
                  <td className="num var-neg">{usd(r.outflows)}</td>
                  <td className={`num ${Number(r.net) < 0 ? 'var-neg' : ''}`}>{usd(r.net)}</td>
                  <td className="num">{usd(r.net_realizado)}</td>
                  <td className="num" style={{ color: 'var(--text-muted)' }}>{usd(r.net_proyectado)}</td>
                  <td
                    className={`num ${Number(r.closing_balance) < 0 ? 'var-neg' : ''}`}
                    style={{ fontWeight: 600 }}
                  >
                    {usd(r.closing_balance)}
                  </td>
                </tr>
              )
            }}
          />

          <p style={{ margin: 0, color: 'var(--text-muted)', fontSize: '0.8125rem' }}>
            Los meses en cursiva son de hoy en adelante. Un gasto comprometido se ubica en
            su fecha de vencimiento; si no la tiene, en la del gasto. Las transferencias
            entre proyectos aparecen dos veces: negativa en el origen y positiva en el
            destino.
          </p>

          {(requirements.data ?? []).length > 0 && (
            <section style={{ display: 'grid', gap: 12 }}>
              <h2>Meses que cierran en negativo</h2>
              <Table
                columns={[
                  { key: 'p', label: 'Proyecto' },
                  { key: 'month', label: 'Mes' },
                  { key: 'necesidad_usd', label: 'Necesidad', num: true },
                ]}
                rows={requirements.data}
                renderRow={(r) => (
                  <tr key={`${r.project_id}-${r.month}`}>
                    <td>
                      <Link to={`/proyectos/${r.project_id}`} style={{ color: 'var(--accent)' }}>
                        {r.code}
                      </Link>{' '}
                      {r.name}
                    </td>
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
