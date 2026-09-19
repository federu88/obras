import { Link } from 'react-router-dom'
import { useAsync } from '../lib/useAsync'
import { getEncargoSummary, listEncargoHealth } from '../lib/queries'
import { usd, pct } from '../lib/format'
import { Table, Loading, ErrorBox, Badge, Kpi } from '../components/ui'

/**
 * El negocio del estudio: las obras que se construyen para un tercero.
 *
 * No son los mismos indicadores del desarrollo propio con otro filtro: son
 * otros indicadores. Acá no hay capital aportado ni profit a repartir. Hay
 * contratos, avance certificado y plata que el estudio adelantó.
 *
 * Que esté en otra pantalla es comodidad. Lo que impide que un inversor vea
 * estos números es la RLS: para él, estas consultas vuelven vacías.
 */

export default function DashboardEncargo() {
  const resumen = useAsync(getEncargoSummary)
  const obras = useAsync(listEncargoHealth)

  const s = resumen.data ?? {}
  const filas = obras.data ?? []
  const sinCertificar = filas.filter((o) => o.problema_certificacion)
  const conAdicionales = filas.filter((o) => o.adicionales_sin_decidir)

  if (resumen.loading || obras.loading) return <Loading />

  return (
    <div style={{ display: 'grid', gap: 24 }}>
      {(resumen.error || obras.error) && (
        <ErrorBox message={resumen.error || obras.error} />
      )}

      {filas.length === 0 ? (
        <div className="notice">
          <strong>Todavía no hay obras por encargo.</strong> Creá una obra en{' '}
          <Link to="/proyectos" style={{ color: 'var(--accent)' }}>Proyectos</Link> con
          modelo <em>obra por encargo</em>, cargale el contrato y va a aparecer acá.
        </div>
      ) : (
        <>
          {sinCertificar.length > 0 && (
            <div className="notice notice-warning">
              <strong>
                {sinCertificar.length === 1
                  ? '1 obra con trabajo sin certificar'
                  : `${sinCertificar.length} obras con trabajo sin certificar`}
                :
              </strong>{' '}
              {sinCertificar
                .map((o) => `${o.code} (${pct(o.sin_certificar_rel)} de avance)`)
                .join(' · ')}
              . Es obra hecha que todavía no se puede cobrar.
            </div>
          )}

          {conAdicionales.length > 0 && (
            <div className="notice notice-warning">
              <strong>Adicionales sin decidir:</strong>{' '}
              {conAdicionales
                .map((o) => `${o.code} ${usd(o.adicionales_propuestos_usd)}`)
                .join(' · ')}
              . No cuentan en el contrato hasta que el cliente los apruebe.
            </div>
          )}

          <section style={{ display: 'grid', gap: 12 }}>
            <h2>Contratos</h2>
            <div className="kpi-grid">
              <Kpi
                label="Contrato vigente"
                value={usd(s.contrato_vigente_usd)}
                hint="firmado + adicionales aprobados"
              />
              <Kpi label="Certificado" value={usd(s.certificado_usd)} />
              <Kpi label="Cobrado" value={usd(s.cobrado_usd)} />
              <Kpi
                label="Falta cobrar"
                value={usd(s.por_cobrar_usd)}
                hint="certificado que no entró"
              />
              <Kpi
                label="Falta certificar"
                value={usd(s.por_certificar_usd)}
                hint="contrato todavía sin certificar"
              />
              <Kpi label="Obras activas" value={s.obras_activas} />
            </div>
          </section>

          <section style={{ display: 'grid', gap: 12 }}>
            <h2>Resultado del estudio</h2>
            <div className="kpi-grid">
              <Kpi
                label="Puso el estudio"
                value={usd(s.puso_estudio_usd)}
                hint="gastos pagados de su bolsillo"
              />
              <Kpi
                label="Pagó el cliente"
                value={usd(s.puso_cliente_usd)}
                hint="costo de obra, plata ajena"
              />
              <Kpi
                label="Resultado"
                value={usd(s.resultado_estudio_usd)}
                hint={s.margen_pct != null ? `${pct(s.margen_pct)} sobre lo cobrado` : undefined}
              />
              <Kpi
                label="Adelantado"
                value={usd(s.adelantado_usd)}
                hint="puesto menos cobrado"
              />
            </div>
            <p style={{ margin: 0, color: 'var(--text-muted)', fontSize: '0.8125rem' }}>
              Construir estas casas costó {usd(s.costo_obra_usd)} en total, lo haya pagado
              quien lo haya pagado. El resultado de arriba es otra pregunta: cuánto ganó el
              estudio, que solo cuenta la plata que salió de su bolsillo.
            </p>
          </section>

          <section style={{ display: 'grid', gap: 12 }}>
            <h2>Por obra</h2>
            <Table
              columns={[
                { key: 'code', label: 'Obra' },
                { key: 'client_name', label: 'Cliente' },
                { key: 'contrato_vigente_usd', label: 'Contrato', num: true },
                { key: 'certificado_usd', label: 'Certificado', num: true },
                { key: 'cobrado_usd', label: 'Cobrado', num: true },
                { key: 'por_cobrar_usd', label: 'Falta cobrar', num: true },
                { key: 'avance_certificado', label: 'Certif.', num: true },
                { key: 'avance_real', label: 'Obra', num: true },
                { key: 'resultado_estudio_usd', label: 'Resultado', num: true },
                { key: 'flags', label: 'Estado', sort: (o) => (o.problema_certificacion ? 1 : 0) },
              ]}
              rows={filas}
              empty="Todavía no hay obras por encargo."
              renderRow={(o) => (
                <tr key={o.project_id}>
                  <td style={{ fontWeight: 500 }}>
                    <Link to={`/proyectos/${o.project_id}`} style={{ color: 'var(--accent)' }}>
                      {o.code}
                    </Link>{' '}
                    {o.name}
                  </td>
                  <td style={{ color: 'var(--text-muted)' }}>{o.client_name}</td>
                  <td className="num">{usd(o.contrato_vigente_usd)}</td>
                  <td className="num">{usd(o.certificado_usd)}</td>
                  <td className="num">{usd(o.cobrado_usd)}</td>
                  <td className={`num ${o.por_cobrar_usd > 0 ? 'var-neg' : ''}`}>
                    {usd(o.por_cobrar_usd)}
                  </td>
                  <td className="num">
                    {o.avance_certificado == null ? '—' : pct(o.avance_certificado)}
                  </td>
                  <td className="num">
                    {o.avance_real == null ? '—' : pct(o.avance_real)}
                  </td>
                  <td className={`num ${Number(o.resultado_estudio_usd) < 0 ? 'var-neg' : ''}`}>
                    {usd(o.resultado_estudio_usd)}
                  </td>
                  <td style={{ display: 'flex', gap: 4 }}>
                    {o.problema_certificacion && <Badge tone="off">sin certificar</Badge>}
                    {o.adicionales_sin_decidir && <Badge tone="warn">adicionales</Badge>}
                    {!o.problema_certificacion && !o.adicionales_sin_decidir && (
                      <Badge tone="ok">ok</Badge>
                    )}
                  </td>
                </tr>
              )}
            />
            <p style={{ margin: 0, color: 'var(--text-muted)', fontSize: '0.8125rem' }}>
              <strong>Certif.</strong> es cuánto del contrato ya se certificó;{' '}
              <strong>Obra</strong> es el avance físico del cronograma. Si la obra va
              adelante de la certificación, el estudio está financiando al cliente.
            </p>
          </section>
        </>
      )}
    </div>
  )
}
