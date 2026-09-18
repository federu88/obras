import { useState } from 'react'
import { useAsync } from '../lib/useAsync'
import { listFxRates, createFxRate, updateFxRate } from '../lib/queries'
import { backfill, syncHoy } from '../lib/fx'
import { date } from '../lib/format'
import { useAuth } from '../context/AuthContext'
import { PageHead, Table, Loading, ErrorBox, Drawer, Field, Kpi } from '../components/ui'

const ARS = new Intl.NumberFormat('es-AR', {
  minimumFractionDigits: 2,
  maximumFractionDigits: 2,
})

const hoyIso = () => new Date().toISOString().slice(0, 10)

/** Mini gráfico de línea. Treinta puntos no justifican una librería. */
function Tendencia({ puntos }) {
  if (puntos.length < 2) return null

  const vals = puntos.map((p) => Number(p.ars_per_usd))
  const min = Math.min(...vals)
  const max = Math.max(...vals)
  const rango = max - min || 1
  const W = 600
  const H = 90

  const d = puntos
    .map((p, i) => {
      const x = (i / (puntos.length - 1)) * W
      const y = H - ((Number(p.ars_per_usd) - min) / rango) * (H - 10) - 5
      return `${i === 0 ? 'M' : 'L'}${x.toFixed(1)},${y.toFixed(1)}`
    })
    .join(' ')

  return (
    <div className="card" style={{ display: 'grid', gap: 8 }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '0.8125rem', color: 'var(--text-muted)' }}>
        <span>{date(puntos[0].rate_date)}</span>
        <span>Mínimo {ARS.format(min)} · Máximo {ARS.format(max)}</span>
        <span>{date(puntos[puntos.length - 1].rate_date)}</span>
      </div>
      <svg viewBox={`0 0 ${W} ${H}`} style={{ width: '100%', height: 90 }} aria-label="Evolución del dólar">
        <path d={d} fill="none" stroke="var(--accent)" strokeWidth="2" vectorEffect="non-scaling-stroke" />
      </svg>
    </div>
  )
}

export default function Dolar() {
  const { canManage } = useAuth()
  const [abierto, setAbierto] = useState(null)
  const [form, setForm] = useState({ rate_date: hoyIso(), ars_per_usd: '', note: '' })
  const [saving, setSaving] = useState(false)
  const [error, setError] = useState(null)
  const [cargando, setCargando] = useState(null)
  const [resultado, setResultado] = useState(null)

  const rates = useAsync(listFxRates)
  const set = (k) => (e) => setForm((f) => ({ ...f, [k]: e.target.value }))

  const filas = rates.data ?? []
  const hoy = filas.find((r) => r.rate_date === hoyIso() && r.source === 'MEP')
  const ultima = filas.find((r) => r.source === 'MEP')
  const anterior = filas.filter((r) => r.source === 'MEP')[1]

  const variacion =
    ultima && anterior && Number(anterior.ars_per_usd) > 0
      ? (Number(ultima.ars_per_usd) - Number(anterior.ars_per_usd)) / Number(anterior.ars_per_usd)
      : null

  /* Los últimos 30 puntos, del más viejo al más nuevo para dibujarlos. */
  const serie = [...filas.filter((r) => r.source === 'MEP')]
    .slice(0, 30)
    .reverse()

  async function save() {
    setSaving(true)
    setError(null)
    try {
      const payload = {
        rate_date: form.rate_date,
        ars_per_usd: Number(form.ars_per_usd),
        note: form.note || 'Carga manual',
      }
      if (abierto === 'nuevo') await createFxRate({ ...payload, source: 'MEP' })
      else await updateFxRate(abierto.id, payload)
      setAbierto(null)
      rates.reload()
    } catch (err) {
      setError(err.message)
    } finally {
      setSaving(false)
    }
  }

  async function traerHistorico() {
    setCargando({ revisadas: 0, total: 90 })
    setResultado(null)
    const r = await backfill(90, setCargando)
    setCargando(null)
    setResultado(r)
    rates.reload()
  }

  async function traerHoy() {
    const v = await syncHoy()
    rates.reload()
    setResultado(v ? { cargadas: 1, saltadas: 0 } : { cargadas: 0, saltadas: 1 })
  }

  return (
    <div style={{ display: 'grid', gap: 20 }}>
      <PageHead
        title="Dólar"
        subtitle="MEP, valor de compra — el mismo criterio de tu planilla. Con esta cotización se valúa en USD todo lo que se carga en pesos."
        action={
          canManage && (
            <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap' }}>
              <button className="btn" onClick={traerHoy}>Traer el de hoy</button>
              <button className="btn" onClick={traerHistorico} disabled={!!cargando}>
                {cargando ? `Trayendo… ${cargando.revisadas}/${cargando.total}` : 'Traer 90 días'}
              </button>
              <button
                className="btn btn-primary"
                onClick={() => {
                  setForm({ rate_date: hoyIso(), ars_per_usd: '', note: '' })
                  setAbierto('nuevo')
                }}
              >
                + Cargar a mano
              </button>
            </div>
          )
        }
      />

      <div className="kpi-grid">
        <Kpi
          label="Dólar de hoy"
          value={hoy ? ARS.format(hoy.ars_per_usd) : null}
          hint={hoy ? hoy.note ?? 'MEP' : 'todavía no cargado'}
        />
        <Kpi
          label="Última cotización"
          value={ultima ? ARS.format(ultima.ars_per_usd) : null}
          hint={ultima ? date(ultima.rate_date) : '—'}
        />
        <Kpi
          label="Variación"
          value={variacion == null ? null : `${variacion > 0 ? '+' : ''}${(variacion * 100).toFixed(2)} %`}
          hint="contra la cotización anterior"
        />
        <Kpi label="Cotizaciones cargadas" value={filas.length} />
      </div>

      {!hoy && (
        <div className="notice notice-warning">
          <strong>Todavía no está cargado el dólar de hoy.</strong> Un gasto en pesos que
          cargues hoy se va a valuar con la última cotización disponible
          {ultima ? ` (${ARS.format(ultima.ars_per_usd)} del ${date(ultima.rate_date)})` : ''}.
          No rompe nada, pero el valor en dólares va a ser aproximado.
        </div>
      )}

      {resultado && (
        <div className="notice">
          {resultado.cargadas} cotización(es) nueva(s). {resultado.saltadas} ya estaban.
        </div>
      )}

      {serie.length > 1 && <Tendencia puntos={serie} />}

      {rates.error && <ErrorBox message={rates.error} />}

      {rates.loading ? (
        <Loading />
      ) : (
        <Table
          columns={[
            { key: 'rate_date', label: 'Fecha' },
            { key: 'ars_per_usd', label: 'ARS por USD', num: true },
            { key: 'source', label: 'Fuente' },
            { key: 'note', label: 'Detalle' },
            { key: 'act', label: '', sort: false },
          ]}
          rows={filas}
          empty="Todavía no hay cotizaciones. Probá con “Traer 90 días”."
          renderRow={(r) => (
            <tr key={r.id}>
              <td className="nowrap">{date(r.rate_date)}</td>
              <td className="num">{ARS.format(r.ars_per_usd)}</td>
              <td>{r.source}</td>
              <td style={{ color: 'var(--text-muted)' }}>{r.note ?? '—'}</td>
              <td className="nowrap">
                {canManage && (
                  <button
                    className="icon-btn"
                    onClick={() => {
                      setForm({
                        rate_date: r.rate_date,
                        ars_per_usd: String(r.ars_per_usd),
                        note: r.note ?? '',
                      })
                      setAbierto(r)
                    }}
                  >
                    Editar
                  </button>
                )}
              </td>
            </tr>
          )}
        />
      )}

      {abierto && (
        <Drawer
          title={abierto === 'nuevo' ? 'Cargar cotización' : 'Editar cotización'}
          submitLabel={abierto === 'nuevo' ? 'Guardar' : 'Guardar cambios'}
          onClose={() => setAbierto(null)}
          onSubmit={save}
          submitting={saving}
        >
          {error && <ErrorBox message={error} />}
          <Field label="Fecha">
            <input type="date" required value={form.rate_date} onChange={set('rate_date')} />
          </Field>
          <Field
            label="ARS por USD"
            hint="Si hiciste una operación de cambio real, esa cotización es más precisa que la de mercado."
          >
            <input
              type="number"
              step="0.0001"
              min="0.0001"
              required
              value={form.ars_per_usd}
              onChange={set('ars_per_usd')}
            />
          </Field>
          <Field label="Detalle"><input value={form.note} onChange={set('note')} /></Field>
        </Drawer>
      )}
    </div>
  )
}
