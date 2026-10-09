import { useState } from 'react'
import { useAsync } from '../lib/useAsync'
import {
  listProjects,
  listRubroTotals,
  listRubroCostTypeTotals,
  listCostTypeTotals,
  listLaborPayments,
} from '../lib/queries'
import { COST_TYPES } from '../lib/costos'
import { downloadCsv } from '../lib/csv'
import { usd, pct, date } from '../lib/format'
import { PageHead, Table, Loading, ErrorBox, Kpi } from '../components/ui'

const TIPOS = Object.keys(COST_TYPES)
const n = (v) => Number(v ?? 0)

/**
 * Costos por rubro y tipo de costo.
 *
 * Con una obra elegida: el cruce rubro × tipo, los totales por tipo y los
 * pagos de mano de obra por trabajador. Con todas: el mismo rubro lado a lado
 * en cada obra, que es lo que permite comparar cuánto costó la estructura
 * acá y allá.
 *
 * Todo sale de las vistas de la base (rubro_totals, rubro_cost_type_totals,
 * cost_type_totals, labor_payments): acá solo se acomoda en filas y columnas.
 */
export default function CostosPorRubro() {
  const projects = useAsync(listProjects)
  const [projectId, setProjectId] = useState('')

  const cruce = useAsync(() => listRubroCostTypeTotals(projectId || undefined), [projectId])
  const porTipo = useAsync(() => listCostTypeTotals(projectId || undefined), [projectId])
  const rubros = useAsync(() => listRubroTotals(projectId || undefined), [projectId])
  const mano = useAsync(() => (projectId ? listLaborPayments(projectId) : Promise.resolve([])), [projectId])

  const cargando = cruce.loading || porTipo.loading || rubros.loading
  const errores = [cruce.error, porTipo.error, rubros.error, mano.error].filter(Boolean)

  /* Totales por tipo, sumando todas las obras si no hay una elegida. */
  const totalTipo = Object.fromEntries(TIPOS.map((t) => [t, 0]))
  for (const r of porTipo.data ?? []) totalTipo[r.cost_type] += n(r.actual_usd)
  const totalGeneral = Object.values(totalTipo).reduce((a, b) => a + b, 0)

  /* Pivote rubro × tipo para una obra. */
  const matriz = new Map()
  for (const r of cruce.data ?? []) {
    if (!matriz.has(r.project_rubro_id)) {
      matriz.set(r.project_rubro_id, { rubro: r.rubro, sort_order: r.sort_order, total: 0, ...Object.fromEntries(TIPOS.map((t) => [t, 0])) })
    }
    const fila = matriz.get(r.project_rubro_id)
    fila[r.cost_type] += n(r.actual_usd)
    fila.total += n(r.actual_usd)
  }
  const filasMatriz = [...matriz.values()].filter((f) => f.total).sort((a, b) => a.sort_order - b.sort_order)

  /* Pivote rubro × obra para todas. Se agrupa por nombre: es lo que permite
     comparar el mismo rubro entre obras aunque cada una tenga su copia. */
  const obras = [...new Set((rubros.data ?? []).filter((r) => n(r.actual_usd)).map((r) => r.code))].sort()
  const entreObras = new Map()
  for (const r of rubros.data ?? []) {
    if (!n(r.actual_usd)) continue
    if (!entreObras.has(r.rubro)) entreObras.set(r.rubro, { rubro: r.rubro, sort_order: r.sort_order, total: 0 })
    const fila = entreObras.get(r.rubro)
    fila[r.code] = (fila[r.code] ?? 0) + n(r.actual_usd)
    fila.total += n(r.actual_usd)
    fila.sort_order = Math.min(fila.sort_order, r.sort_order)
  }
  const filasObras = [...entreObras.values()].sort((a, b) => a.sort_order - b.sort_order)

  const colsMatriz = [
    { key: 'rubro', label: 'Rubro', sort: (f) => f.sort_order },
    ...TIPOS.map((t) => ({ key: t, label: COST_TYPES[t], num: true })),
    { key: 'total', label: 'Total', num: true },
  ]
  const colsObras = [
    { key: 'rubro', label: 'Rubro', sort: (f) => f.sort_order },
    ...obras.map((c) => ({ key: c, label: c, num: true })),
    { key: 'total', label: 'Total', num: true },
  ]
  const obra = (projects.data ?? []).find((p) => p.id === projectId)

  return (
    <div style={{ display: 'grid', gap: 20 }}>
      <PageHead
        title="Costos por rubro"
        subtitle="Lo gastado (recibido y pagado), por rubro y tipo de costo, en dólares."
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
              fontWeight: 500,
            }}
          >
            <option value="">Todas las obras</option>
            {(projects.data ?? []).map((p) => (
              <option key={p.id} value={p.id}>{p.code} · {p.name}</option>
            ))}
          </select>
        }
      />

      {errores.map((e) => <ErrorBox key={e} message={e} />)}

      {cargando ? (
        <Loading />
      ) : (
        <>
          <div className="kpi-grid">
            {TIPOS.map((t) => (
              <Kpi
                key={t}
                label={COST_TYPES[t]}
                value={usd(totalTipo[t])}
                hint={totalGeneral ? pct(totalTipo[t] / totalGeneral) : undefined}
              />
            ))}
          </div>

          {projectId ? (
            <section style={{ display: 'grid', gap: 12 }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', gap: 12 }}>
                <h2>Rubro por tipo de costo</h2>
                <button className="btn" disabled={!filasMatriz.length} onClick={() => downloadCsv(`rubro-x-tipo-${obra?.code ?? 'obra'}`, colsMatriz, filasMatriz)}>
                  Exportar CSV
                </button>
              </div>
              <Table
                columns={colsMatriz}
                rows={filasMatriz}
                empty="Esta obra todavía no tiene gastos recibidos o pagados."
                renderRow={(f) => (
                  <tr key={f.rubro}>
                    <td style={{ fontWeight: 500 }}>{f.rubro}</td>
                    {TIPOS.map((t) => (
                      <td key={t} className="num" style={f[t] ? undefined : { color: 'var(--text-muted)' }}>
                        {f[t] ? usd(f[t]) : '—'}
                      </td>
                    ))}
                    <td className="num" style={{ fontWeight: 600 }}>{usd(f.total)}</td>
                  </tr>
                )}
              />
            </section>
          ) : (
            <section style={{ display: 'grid', gap: 12 }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', gap: 12 }}>
                <h2>Rubro por obra</h2>
                <button className="btn" disabled={!filasObras.length} onClick={() => downloadCsv('rubro-x-obra', colsObras, filasObras)}>
                  Exportar CSV
                </button>
              </div>
              <Table
                columns={colsObras}
                rows={filasObras}
                empty="Todavía no hay gastos recibidos o pagados."
                renderRow={(f) => (
                  <tr key={f.rubro}>
                    <td style={{ fontWeight: 500 }}>{f.rubro}</td>
                    {obras.map((c) => (
                      <td key={c} className="num" style={f[c] ? undefined : { color: 'var(--text-muted)' }}>
                        {f[c] ? usd(f[c]) : '—'}
                      </td>
                    ))}
                    <td className="num" style={{ fontWeight: 600 }}>{usd(f.total)}</td>
                  </tr>
                )}
              />
              <p style={{ margin: 0, color: 'var(--text-muted)', fontSize: '0.8125rem' }}>
                Los rubros se comparan por nombre: si en una obra se renombró uno, aparece
                como fila propia.
              </p>
            </section>
          )}

          {projectId && (
            <section style={{ display: 'grid', gap: 12 }}>
              <h2>Mano de obra por trabajador</h2>
              {mano.loading ? (
                <Loading />
              ) : (
                <Table
                  columns={[
                    { key: 'worker', label: 'Trabajador o cuadrilla' },
                    { key: 'modalidades', label: 'Modalidad' },
                    { key: 'pagos', label: 'Pagos', num: true },
                    { key: 'pagado_usd', label: 'Pagado', num: true },
                    { key: 'adelantos_usd', label: 'Adelantos', num: true },
                    { key: 'ultimo_avance', label: 'Último avance', num: true },
                    { key: 'ultimo_pago', label: 'Último pago' },
                  ]}
                  rows={mano.data ?? []}
                  empty="No hay pagos con detalle de mano de obra. Se cargan al elegir Mano de obra o Subcontrato, en «Más datos» o en el desglose de la línea."
                  renderRow={(m) => (
                    <tr key={m.worker}>
                      <td style={{ fontWeight: 500 }}>{m.worker}</td>
                      <td style={{ color: 'var(--text-muted)' }}>{m.modalidades}</td>
                      <td className="num">{m.pagos}</td>
                      <td className="num">{usd(m.pagado_usd)}</td>
                      <td className="num">{n(m.adelantos_usd) ? usd(m.adelantos_usd) : '—'}</td>
                      <td className="num">{m.ultimo_avance == null ? '—' : pct(m.ultimo_avance)}</td>
                      <td className="nowrap">{date(m.ultimo_pago)}</td>
                    </tr>
                  )}
                />
              )}
            </section>
          )}
        </>
      )}
    </div>
  )
}
