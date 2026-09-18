import { Link } from 'react-router-dom'
import { useAsync } from '../lib/useAsync'
import { listProjectProgress, listScheduleAlerts } from '../lib/queries'
import { pct, date } from '../lib/format'
import { PageHead, Table, Loading, ErrorBox, Badge } from '../components/ui'

const ALERTAS = {
  atrasada: ['Atrasada', 'off'],
  deberia_haber_empezado: ['Debía haber empezado', 'warn'],
  terminada_fuera_de_plazo: ['Terminada fuera de plazo', 'warn'],
  bloqueada: ['Bloqueada', 'off'],
}

export default function Cronogramas() {
  const progress = useAsync(listProjectProgress)
  const alerts = useAsync(() => listScheduleAlerts())

  const rows = (progress.data ?? []).filter((p) => p.actividades > 0)

  return (
    <div style={{ display: 'grid', gap: 24 }}>
      <PageHead
        title="Cronogramas"
        subtitle="Avance físico por obra y actividades con problemas de plazo."
      />

      {(progress.error || alerts.error) && (
        <ErrorBox message={progress.error || alerts.error} />
      )}

      {progress.loading ? (
        <Loading />
      ) : (
        <>
          <Table
            columns={[
              { key: 'code', label: 'Obra' },
              { key: 'act', label: 'Actividades', num: true },
              { key: 'ok', label: 'Terminadas', num: true },
              { key: 'late', label: 'Demoradas', num: true },
              { key: 'plan', label: 'Avance plan', num: true },
              { key: 'real', label: 'Avance real', num: true },
              { key: 'fin', label: 'Fin proyectado' },
            ]}
            rows={rows}
            empty="Ninguna obra tiene cronograma cargado todavía."
            renderRow={(p) => {
              const atraso = Number(p.avance_real) < Number(p.avance_planificado)
              return (
                <tr key={p.project_id}>
                  <td style={{ fontWeight: 500 }}>
                    <Link to={`/proyectos/${p.project_id}`} style={{ color: 'var(--accent)' }}>
                      {p.code}
                    </Link>{' '}
                    {p.name}
                  </td>
                  <td className="num">{p.actividades}</td>
                  <td className="num">{p.terminadas}</td>
                  <td className={`num ${p.demoradas > 0 ? 'var-neg' : ''}`}>{p.demoradas}</td>
                  <td className="num">{pct(p.avance_planificado)}</td>
                  <td className={`num ${atraso ? 'var-neg' : 'var-pos'}`}>{pct(p.avance_real)}</td>
                  <td className={p.fin_proyectado > p.fin_plan ? 'var-neg' : undefined}>
                    {date(p.fin_proyectado)}
                  </td>
                </tr>
              )
            }}
          />

          <section style={{ display: 'grid', gap: 12 }}>
            <h2>Actividades con problemas</h2>
            {alerts.loading ? (
              <Loading />
            ) : (
              <Table
                columns={[
                  { key: 'p', label: 'Obra' },
                  { key: 'n', label: 'Actividad' },
                  { key: 'a', label: 'Problema' },
                  { key: 'pf', label: 'Fin plan' },
                  { key: 'd', label: 'Atraso', num: true },
                ]}
                rows={alerts.data ?? []}
                empty="Ninguna actividad con problemas de plazo."
                renderRow={(a) => {
                  const [label, tone] = ALERTAS[a.alerta] ?? [a.alerta, null]
                  return (
                    <tr key={a.task_id}>
                      <td>
                        <Link to={`/proyectos/${a.project_id}`} style={{ color: 'var(--accent)' }}>
                          {a.code}
                        </Link>
                      </td>
                      <td>{a.name}</td>
                      <td><Badge tone={tone}>{label}</Badge></td>
                      <td>{date(a.planned_finish)}</td>
                      <td className={`num ${a.delay_days > 0 ? 'var-neg' : ''}`}>
                        {a.delay_days == null ? '—' : `+${a.delay_days} d`}
                      </td>
                    </tr>
                  )
                }}
              />
            )}
          </section>

          <p style={{ margin: 0, color: 'var(--text-muted)', fontSize: '0.8125rem' }}>
            El avance se pondera por días hábiles planificados. Es avance físico: para el
            avance económico, mirá el resumen de cada proyecto.
          </p>
        </>
      )}
    </div>
  )
}
