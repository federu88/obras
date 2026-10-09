import { useEffect, useState } from 'react'
import { useAsync } from '../../lib/useAsync'
import {
  listWalletLedger,
  getWalletReconciliation,
  createWalletCount,
  registrarCambioBilletera,
  fxRateAt,
} from '../../lib/queries'
import { usd, ars, date } from '../../lib/format'
import { useAuth } from '../../context/AuthContext'
import { Table, Loading, ErrorBox, Badge, Drawer, Field } from '../../components/ui'

/**
 * Billetera de la obra.
 *
 * Los dólares que entregan los inversores (o el cliente, si la obra es por
 * encargo), los pesos que salen de cambiarlos y lo que se gastó con esa plata.
 * Nada de esto se carga acá: sale de los aportes, los cobros y los gastos que
 * ya están registrados. Lo único que se tipea es el cambio y el arqueo.
 *
 * Se concilia en cada moneda por separado. Pasar los pesos a dólares a otra
 * cotización que la del cambio inventaría una diferencia que no existe.
 */

const TIPOS = {
  entrada: ['Entrada', 'ok'],
  retiro: ['Retiro', 'off'],
  cambio: ['Cambio', 'warn'],
  gasto: ['Gasto', null],
}

const hoyIso = () => new Date().toISOString().slice(0, 10)

const CAMBIO_VACIO = { fecha: hoyIso(), usd: '', cotizacion: '', nota: '' }
const ARQUEO_VACIO = { count_date: hoyIso(), currency: 'USD', amount: '', note: '' }

/** Una línea del cuadre: etiqueta a la izquierda, importe a la derecha. */
function Linea({ label, value, fuerte, tono }) {
  return (
    <div
      style={{
        display: 'flex',
        justifyContent: 'space-between',
        gap: 12,
        padding: '6px 0',
        borderTop: fuerte ? '1px solid var(--border)' : undefined,
        fontWeight: fuerte ? 600 : 400,
        color: tono ? `var(--${tono})` : undefined,
      }}
    >
      <span>{label}</span>
      <span className="num">{value}</span>
    </div>
  )
}

/** El cuadre de una moneda: lo que entró, lo que salió, lo que hay. */
function Cuadre({ titulo, fmt, entradas, salidas, deberia, arqueo, arqueoFecha }) {
  const diferencia = arqueo == null ? null : Number(arqueo) - Number(deberia)
  const cuadra = diferencia != null && Math.abs(diferencia) < 1

  return (
    <div className="card" style={{ display: 'grid', gap: 2 }}>
      <h3 style={{ margin: '0 0 8px' }}>{titulo}</h3>
      {entradas.map(([label, v]) => <Linea key={label} label={label} value={fmt(v)} />)}
      {salidas.map(([label, v]) => <Linea key={label} label={label} value={`− ${fmt(v)}`} />)}
      <Linea label="Debería haber" value={fmt(deberia)} fuerte />
      <Linea
        label={arqueo == null ? 'Arqueo' : `Arqueo del ${date(arqueoFecha)}`}
        value={arqueo == null ? 'sin arqueo' : fmt(arqueo)}
      />
      {diferencia != null && (
        <Linea
          label={cuadra ? 'Cuadra' : diferencia < 0 ? 'Falta rendir' : 'Sobra'}
          value={cuadra ? '✓' : fmt(Math.abs(diferencia))}
          fuerte
          tono={cuadra ? 'positive' : 'negative'}
        />
      )}
    </div>
  )
}

export default function Billetera({ projectId, encargo }) {
  const { canManage } = useAuth()
  /* null = cerrado · 'cambio' · 'arqueo' */
  const [abierto, setAbierto] = useState(null)
  const [cambio, setCambio] = useState(CAMBIO_VACIO)
  const [arqueo, setArqueo] = useState(ARQUEO_VACIO)
  const [saving, setSaving] = useState(false)
  const [formError, setFormError] = useState(null)

  const conc = useAsync(() => getWalletReconciliation(projectId), [projectId])
  const ledger = useAsync(() => listWalletLedger(projectId), [projectId])

  const setC = (k) => (e) => setCambio((f) => ({ ...f, [k]: e.target.value }))
  const setA = (k) => (e) => setArqueo((f) => ({ ...f, [k]: e.target.value }))

  /* Sugiere el MEP del día como cotización; la real es la que se pagó. */
  useEffect(() => {
    if (abierto !== 'cambio' || !cambio.fecha) return
    let cancelled = false
    fxRateAt(cambio.fecha)
      .then((r) => {
        if (!cancelled && r) setCambio((f) => (f.cotizacion ? f : { ...f, cotizacion: String(r) }))
      })
      .catch(() => {})
    return () => { cancelled = true }
  }, [abierto, cambio.fecha])

  function recargar() {
    conc.reload()
    ledger.reload()
  }

  async function guardar() {
    setSaving(true)
    setFormError(null)
    try {
      if (abierto === 'cambio') {
        await registrarCambioBilletera({
          projectId,
          fecha: cambio.fecha,
          usd: Number(cambio.usd),
          cotizacion: Number(cambio.cotizacion),
          nota: cambio.nota,
        })
        setCambio(CAMBIO_VACIO)
      } else {
        await createWalletCount({
          project_id: projectId,
          count_date: arqueo.count_date,
          currency: arqueo.currency,
          amount: Number(arqueo.amount),
          note: arqueo.note || null,
        })
        setArqueo(ARQUEO_VACIO)
      }
      setAbierto(null)
      recargar()
    } catch (err) {
      setFormError(err.message)
    } finally {
      setSaving(false)
    }
  }

  const c = conc.data
  const quien = encargo ? 'el cliente' : 'los inversores'
  const pesosCambio = Number(cambio.usd) * Number(cambio.cotizacion)

  return (
    <div style={{ display: 'grid', gap: 20 }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', gap: 12, flexWrap: 'wrap' }}>
        <p style={{ margin: 0, color: 'var(--text-muted)', fontSize: '0.9375rem' }}>
          Los dólares que entregó {quien}, los pesos que salieron de cambiarlos y lo que
          se gastó con esa plata.
        </p>
        {canManage && (
          <div style={{ display: 'flex', gap: 8 }}>
            <button className="btn" onClick={() => { setFormError(null); setAbierto('arqueo') }}>
              + Arqueo
            </button>
            <button className="btn btn-primary" onClick={() => { setFormError(null); setAbierto('cambio') }}>
              + Cambio a pesos
            </button>
          </div>
        )}
      </div>

      {conc.error && <ErrorBox message={conc.error} />}

      {conc.loading || !c ? (
        !conc.error && <Loading />
      ) : (
        <>
          {(c.usd_deberia < -1 || c.ars_deberia < -1) && (
            <div className="notice notice-error">
              <strong>Salió más plata de la que entró.</strong> Falta cargar algún{' '}
              {encargo ? 'cobro al cliente' : 'aporte'} o algún cambio a pesos, o hay un gasto
              cargado en la moneda equivocada.
            </div>
          )}

          <div style={{ display: 'grid', gap: 16, gridTemplateColumns: 'repeat(auto-fit, minmax(280px, 1fr))' }}>
            <Cuadre
              titulo="Dólares"
              fmt={usd}
              entradas={[[`Entregado por ${quien}`, c.usd_recibido]]}
              salidas={[
                ['Cambiado a pesos', c.usd_cambiado],
                ['Gastado en dólares', c.usd_gastado],
              ]}
              deberia={c.usd_deberia}
              arqueo={c.usd_arqueo}
              arqueoFecha={c.usd_arqueo_fecha}
            />
            <Cuadre
              titulo="Pesos"
              fmt={ars}
              entradas={[
                ['Obtenido de los cambios', c.ars_cambiado],
                ...(Number(c.ars_recibido) !== 0 ? [[`Entregado en pesos por ${quien}`, c.ars_recibido]] : []),
              ]}
              salidas={[['Gastado en pesos', c.ars_gastado]]}
              deberia={c.ars_deberia}
              arqueo={c.ars_arqueo}
              arqueoFecha={c.ars_arqueo_fecha}
            />
          </div>

          {c.cotizacion_promedio != null && (
            <p style={{ margin: 0, color: 'var(--text-muted)', fontSize: '0.8125rem' }}>
              Los dólares de esta obra se cambiaron a un promedio de{' '}
              <strong>{ars(c.cotizacion_promedio)}</strong> por dólar.
            </p>
          )}
        </>
      )}

      <section style={{ display: 'grid', gap: 12 }}>
        <h2>Movimientos</h2>
        {ledger.error && <ErrorBox message={ledger.error} />}
        {ledger.loading ? (
          <Loading />
        ) : (
          <Table
            columns={[
              { key: 'fecha', label: 'Fecha' },
              { key: 'tipo', label: 'Tipo' },
              { key: 'concepto', label: 'Concepto' },
              { key: 'usd', label: 'Dólares', num: true, sort: false },
              { key: 'ars', label: 'Pesos', num: true, sort: false },
              { key: 'cotizacion', label: 'Cotización', num: true },
            ]}
            rows={ledger.data ?? []}
            empty={`Todavía no hay movimientos. Las entradas aparecen solas cuando se cargan ${encargo ? 'los cobros al cliente' : 'los aportes de los inversores'}.`}
            renderRow={(m) => {
              const [label, tone] = TIPOS[m.tipo] ?? [m.tipo, null]
              const monto = Number(m.amount)
              const fmt = m.currency === 'USD' ? usd : ars
              const celda = <span className={monto < 0 ? 'var-neg' : undefined}>{fmt(monto)}</span>
              return (
                <tr key={`${m.tipo}-${m.origen_id}-${m.currency}`}>
                  <td className="nowrap">{date(m.fecha)}</td>
                  <td><Badge tone={tone}>{label}</Badge></td>
                  <td>
                    {m.concepto}
                    {m.quien && m.quien !== m.concepto && (
                      <span style={{ color: 'var(--text-muted)' }}> · {m.quien}</span>
                    )}
                  </td>
                  <td className="num">{m.currency === 'USD' ? celda : ''}</td>
                  <td className="num">{m.currency === 'ARS' ? celda : ''}</td>
                  <td className="num">{m.cotizacion == null ? '—' : ars(m.cotizacion)}</td>
                </tr>
              )
            }}
          />
        )}
        <p style={{ margin: 0, color: 'var(--text-muted)', fontSize: '0.8125rem' }}>
          Cuentan los gastos marcados como pagados.
          {encargo && ' Los que pagó el cliente directo no salen de la billetera.'}
        </p>
      </section>

      {abierto === 'cambio' && (
        <Drawer
          title="Cambio de dólares a pesos"
          submitLabel="Registrar cambio"
          onClose={() => setAbierto(null)}
          onSubmit={guardar}
          submitting={saving}
        >
          {formError && <ErrorBox message={formError} />}
          <Field label="Fecha">
            <input type="date" required value={cambio.fecha} onChange={setC('fecha')} />
          </Field>
          <Field label="Dólares que se cambiaron">
            <input type="number" required min="0.01" step="0.01" value={cambio.usd} onChange={setC('usd')} />
          </Field>
          <Field
            label="Cotización"
            hint="La que se pagó de verdad. Se sugiere el MEP del día, pero manda la del cambio."
          >
            <input type="number" required min="0.0001" step="0.0001" value={cambio.cotizacion} onChange={setC('cotizacion')} />
          </Field>
          {pesosCambio > 0 && (
            <div className="notice">Entran <strong>{ars(pesosCambio)}</strong> a la billetera.</div>
          )}
          <Field label="Nota">
            <input value={cambio.nota} onChange={setC('nota')} placeholder="Quién cambió, dónde" />
          </Field>
        </Drawer>
      )}

      {abierto === 'arqueo' && (
        <Drawer
          title="Arqueo de la billetera"
          submitLabel="Registrar arqueo"
          onClose={() => setAbierto(null)}
          onSubmit={guardar}
          submitting={saving}
        >
          {formError && <ErrorBox message={formError} />}
          <div className="notice">
            Cuánta plata hay de verdad, contada. Un arqueo no se corrige: si cambió, se
            carga otro con fecha posterior.
          </div>
          <Field label="Fecha">
            <input type="date" required value={arqueo.count_date} onChange={setA('count_date')} />
          </Field>
          <Field label="Moneda">
            <select value={arqueo.currency} onChange={setA('currency')}>
              <option value="USD">Dólares</option>
              <option value="ARS">Pesos</option>
            </select>
          </Field>
          <Field label="Monto contado">
            <input type="number" required min="0" step="0.01" value={arqueo.amount} onChange={setA('amount')} />
          </Field>
          <Field label="Nota">
            <input value={arqueo.note} onChange={setA('note')} />
          </Field>
        </Drawer>
      )}
    </div>
  )
}
