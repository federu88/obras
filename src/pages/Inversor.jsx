import { useParams, Link } from 'react-router-dom'
import { useAsync } from '../lib/useAsync'
import { getInvestor, listInvestorReport, listInvestorMovements } from '../lib/queries'
import { usd, pct, date } from '../lib/format'
import { downloadCsv } from '../lib/csv'
import { Table, Loading, ErrorBox, Badge, Kpi } from '../components/ui'

const TYPES = {
  aporte: 'Aporte',
  retiro: 'Retiro',
  profit_asignado: 'Profit asignado',
  profit_distribuido: 'Profit distribuido',
  reinversion: 'Reinversión',
  transferencia: 'Transferencia',
}

const sum = (rows, key) => (rows ?? []).reduce((a, r) => a + Number(r[key] ?? 0), 0)

export default function Inversor() {
  const { id } = useParams()

  const investor = useAsync(() => getInvestor(id), [id])
  const report = useAsync(() => listInvestorReport(id), [id])
  const movements = useAsync(() => listInvestorMovements(id), [id])

  if (investor.loading) return <Loading />
  if (investor.error) return <ErrorBox message={investor.error} />

  const inv = investor.data
  const rows = report.data ?? []
  const movs = movements.data ?? []

  const capital = sum(rows, 'capital_invertido_usd')
  const pendiente = sum(rows, 'profit_pendiente_usd')
  const cobrado = sum(rows, 'profit_cobrado_usd')
  const proyectado = sum(rows, 'profit_proyectado_usd')

  /* ROI sobre el capital efectivamente invertido. Realizado, no proyectado:
     mezclarlos daría un número que parece un hecho y es una estimación. */
  const roi = capital > 0 ? cobrado / capital : null

  function exportarMovimientos() {
    downloadCsv(
      `movimientos-${inv.name.replace(/\s+/g, '-').toLowerCase()}`,
      [
        { key: 'fecha', label: 'Fecha' },
        { key: 'tipo', label: 'Tipo' },
        { key: 'obra', label: 'Obra' },
        { key: 'concepto', label: 'Concepto' },
        { key: 'importe', label: 'Importe' },
        { key: 'moneda', label: 'Moneda' },
        { key: 'usd', label: 'USD' },
        { key: 'estado', label: 'Estado' },
      ],
      movs.map((m) => ({
        fecha: m.movement_date,
        tipo: TYPES[m.type] ?? m.type,
        obra: m.origen ? `${m.origen.code} → ${m.project?.code}` : m.project?.code ?? '',
        concepto: m.concept ?? '',
        importe: m.amount,
        moneda: m.currency,
        usd: m.amount_usd,
        estado: m.status,
      }))
    )
  }

  return (
    <div style={{ display: 'grid', gap: 24 }}>
      <div>
        <Link to="/inversores" style={{ color: 'var(--text-muted)', fontSize: '0.875rem' }}>
          ← Inversores
        </Link>
        <div style={{ display: 'flex', alignItems: 'center', gap: 12, marginTop: 6 }}>
          <h1>{inv.name}</h1>
          <Badge tone={inv.is_active ? 'ok' : 'off'}>
            {inv.is_active ? 'Activo' : 'Inactivo'}
          </Badge>
        </div>
        <p style={{ margin: '4px 0 0', color: 'var(--text-muted)' }}>
          {[inv.email, inv.phone, inv.joined_on && `desde ${date(inv.joined_on)}`]
            .filter(Boolean)
            .join(' · ') || 'Sin datos de contacto'}
        </p>
      </div>

      <div className="kpi-grid">
        <Kpi label="Capital invertido" value={usd(capital)} />
        <Kpi label="Profit cobrado" value={usd(cobrado)} hint="Efectivamente distribuido" />
        <Kpi label="Profit pendiente" value={usd(pendiente)} hint="Asignado, sin cobrar" />
        <Kpi label="Profit proyectado" value={usd(proyectado)} hint="Si las obras cierran como se prevé" />
        <Kpi label="ROI realizado" value={roi == null ? null : pct(roi)} hint="Cobrado sobre invertido" />
        <Kpi label="Obras" value={rows.length} />
      </div>

      <section style={{ display: 'grid', gap: 12 }}>
        <h2>Posición por obra</h2>
        {report.loading ? (
          <Loading />
        ) : (
          <Table
            columns={[
              { key: 'p', label: 'Obra' },
              { key: 's', label: 'Estado' },
              { key: 'c', label: 'Capital', num: true },
              { key: 'part', label: 'Participación', num: true },
              { key: 'pend', label: 'Pendiente', num: true },
              { key: 'cob', label: 'Cobrado', num: true },
              { key: 'proy', label: 'Profit proy.', num: true },
            ]}
            rows={rows}
            empty="Este inversor todavía no tiene capital asignado a ninguna obra."
            renderRow={(r) => (
              <tr key={r.project_id}>
                <td style={{ fontWeight: 500 }}>
                  <Link to={`/proyectos/${r.project_id}`} style={{ color: 'var(--accent)' }}>
                    {r.code}
                  </Link>{' '}
                  {r.project_name}
                </td>
                <td><Badge>{r.project_status.replace('_', ' ')}</Badge></td>
                <td className="num">{usd(r.capital_invertido_usd)}</td>
                <td className="num">{r.participacion == null ? '—' : pct(r.participacion)}</td>
                <td className="num">{usd(r.profit_pendiente_usd)}</td>
                <td className="num">{usd(r.profit_cobrado_usd)}</td>
                <td className="num">{usd(r.profit_proyectado_usd)}</td>
              </tr>
            )}
          />
        )}
        <p style={{ margin: 0, color: 'var(--text-muted)', fontSize: '0.8125rem' }}>
          La participación se calcula sobre el capital efectivamente aportado a cada obra.
          El profit proyectado es una estimación según cómo cierre el proyecto, no un
          derecho adquirido.
        </p>
      </section>

      <section style={{ display: 'grid', gap: 12 }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', gap: 12 }}>
          <h2>Movimientos</h2>
          {movs.length > 0 && (
            <button className="btn" onClick={exportarMovimientos}>Exportar CSV</button>
          )}
        </div>
        {movements.loading ? (
          <Loading />
        ) : (
          <Table
            columns={[
              { key: 'd', label: 'Fecha' },
              { key: 't', label: 'Tipo' },
              { key: 'p', label: 'Obra' },
              { key: 'c', label: 'Concepto' },
              { key: 'a', label: 'Importe', num: true },
              { key: 'u', label: 'USD', num: true },
            ]}
            rows={movs}
            empty="Sin movimientos registrados."
            renderRow={(m) => (
              <tr key={m.id} style={{ opacity: m.status === 'anulado' ? 0.5 : 1 }}>
                <td>{date(m.movement_date)}</td>
                <td>{TYPES[m.type] ?? m.type}</td>
                <td>
                  {m.origen ? `${m.origen.code} → ${m.project?.code}` : m.project?.code ?? '—'}
                </td>
                <td>{m.concept ?? '—'}</td>
                <td className="num">
                  {new Intl.NumberFormat('es-AR').format(m.amount)} {m.currency}
                </td>
                <td className="num">{usd(m.amount_usd)}</td>
              </tr>
            )}
          />
        )}
      </section>
    </div>
  )
}
