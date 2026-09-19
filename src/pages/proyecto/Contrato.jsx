import { useState } from 'react'
import { useAsync } from '../../lib/useAsync'
import {
  listClients,
  getContract,
  getContractSummary,
  createContract,
  updateContract,
  listChangeOrders,
  createChangeOrder,
  updateChangeOrder,
  deleteChangeOrder,
  listCertificates,
  createCertificate,
  updateCertificate,
  deleteCertificate,
  getProjectProgress,
  getEncargoPnl,
  fxRateAt,
} from '../../lib/queries'
import { usd, pct, date } from '../../lib/format'
import { useAuth } from '../../context/AuthContext'
import { Table, Loading, ErrorBox, Badge, Drawer, Field, Kpi } from '../../components/ui'

/**
 * Contrato, adicionales y certificados de una obra por encargo.
 *
 * Las tres cosas viven juntas porque son una sola conversación: lo que se
 * pactó, lo que cambió y lo que ya se puede cobrar. Separadas en tres
 * pantallas obligan a saltar para responder "¿cuánto falta cobrar?".
 */

export const FEE_MODELS = {
  porcentaje_obra: '% sobre el costo de obra',
  fijo: 'Honorario fijo',
  costo_mas_fee: 'Costo + fee de administración',
  precio_cerrado: 'Precio cerrado por la obra',
}

const CO_STATUS = {
  propuesto: ['Propuesto', 'warn'],
  aprobado: ['Aprobado', 'ok'],
  rechazado: ['Rechazado', 'off'],
}

/* El circuito real del papel. El orden importa: es el que sigue el botón. */
const CERT_FLOW = ['borrador', 'emitido', 'aprobado', 'facturado', 'cobrado']
const CERT_STATUS = {
  borrador: ['Borrador', null],
  emitido: ['Emitido', 'warn'],
  aprobado: ['Aprobado', 'warn'],
  facturado: ['Facturado', 'warn'],
  cobrado: ['Cobrado', 'ok'],
}
const CERT_FECHA = {
  emitido: 'issued_on',
  aprobado: 'approved_on',
  facturado: 'invoiced_on',
  cobrado: 'paid_on',
}

const hoy = () => new Date().toISOString().slice(0, 10)

const CONTRATO_VACIO = {
  client_id: '',
  signed_on: hoy(),
  fee_model: 'precio_cerrado',
  amount: '',
  currency: 'USD',
  fee_pct: '',
  fee_amount: '',
  advance: '0',
  notes: '',
}

const ADICIONAL_VACIO = {
  order_date: hoy(),
  description: '',
  amount: '',
  currency: 'USD',
  status: 'propuesto',
  notes: '',
}

const CERT_VACIO = {
  number: '',
  period_from: '',
  period_to: hoy(),
  progress_pct: '',
  description: '',
  amount: '',
  currency: 'USD',
  notes: '',
}

/** Completa el fx del día cuando el monto no está en dólares. */
async function conFx(v) {
  if (v.currency === 'USD') return { ...v, fx_usd: null }
  const fx = await fxRateAt(v.fecha)
  if (!fx) throw new Error('No hay cotización cargada para esa fecha. Cargala en Finanzas › Dólar.')
  return { ...v, fx_usd: fx }
}

export default function Contrato({ projectId }) {
  const { canManage } = useAuth()
  const [drawer, setDrawer] = useState(null)   // 'contrato' | 'adicional' | 'certificado'
  const [editando, setEditando] = useState(null)
  const [form, setForm] = useState(CONTRATO_VACIO)
  const [saving, setSaving] = useState(false)
  const [error, setError] = useState(null)

  const clientes = useAsync(listClients)
  const contrato = useAsync(() => getContract(projectId), [projectId])
  const resumen = useAsync(() => getContractSummary(projectId), [projectId])
  const progreso = useAsync(() => getProjectProgress(projectId), [projectId])
  const encargo = useAsync(() => getEncargoPnl(projectId), [projectId])

  const c = contrato.data
  const adicionales = useAsync(
    () => (c ? listChangeOrders(c.id) : Promise.resolve([])),
    [c?.id]
  )
  const certificados = useAsync(() => listCertificates(projectId), [projectId])

  const set = (k) => (e) => setForm((f) => ({ ...f, [k]: e.target.value }))

  function reload() {
    contrato.reload()
    resumen.reload()
    adicionales.reload()
    certificados.reload()
    encargo.reload()
  }

  function abrir(tipo, fila = null) {
    setError(null)
    setEditando(fila)
    if (tipo === 'contrato') {
      setForm(
        c
          ? {
              client_id: c.client_id,
              signed_on: c.signed_on ?? '',
              fee_model: c.fee_model,
              amount: String(c.amount ?? ''),
              currency: c.currency,
              fee_pct: c.fee_pct == null ? '' : String(c.fee_pct * 100),
              fee_amount: c.fee_amount == null ? '' : String(c.fee_amount),
              advance: String(c.advance ?? '0'),
              notes: c.notes ?? '',
            }
          : CONTRATO_VACIO
      )
    } else if (tipo === 'adicional') {
      setForm(
        fila
          ? {
              order_date: fila.order_date,
              description: fila.description,
              amount: String(fila.amount),
              currency: fila.currency,
              status: fila.status,
              notes: fila.notes ?? '',
            }
          : ADICIONAL_VACIO
      )
    } else {
      const siguiente = (certificados.data ?? []).reduce((m, x) => Math.max(m, x.number), 0) + 1
      setForm(
        fila
          ? {
              number: String(fila.number),
              period_from: fila.period_from ?? '',
              period_to: fila.period_to,
              progress_pct: fila.progress_pct == null ? '' : String(fila.progress_pct * 100),
              description: fila.description ?? '',
              amount: String(fila.amount),
              currency: fila.currency,
              notes: fila.notes ?? '',
            }
          : { ...CERT_VACIO, number: String(siguiente) }
      )
    }
    setDrawer(tipo)
  }

  async function guardar() {
    setSaving(true)
    setError(null)
    try {
      if (drawer === 'contrato') {
        const { fx_usd } = await conFx({ currency: form.currency, fecha: form.signed_on || hoy() })
        const payload = {
          client_id: form.client_id,
          signed_on: form.signed_on || null,
          fee_model: form.fee_model,
          amount: Number(form.amount || 0),
          currency: form.currency,
          fx_usd,
          /* En la base el porcentaje es una fracción; en pantalla se escribe entero. */
          fee_pct: form.fee_pct === '' ? null : Number(form.fee_pct) / 100,
          fee_amount: form.fee_amount === '' ? null : Number(form.fee_amount),
          advance: Number(form.advance || 0),
          notes: form.notes || null,
        }
        if (c) await updateContract(c.id, payload)
        else await createContract({ ...payload, project_id: projectId })
      } else if (drawer === 'adicional') {
        const { fx_usd } = await conFx({ currency: form.currency, fecha: form.order_date })
        const payload = {
          order_date: form.order_date,
          description: form.description,
          amount: Number(form.amount),
          currency: form.currency,
          fx_usd,
          status: form.status,
          decided_on: form.status === 'propuesto' ? null : hoy(),
          notes: form.notes || null,
        }
        if (editando) await updateChangeOrder(editando.id, payload)
        else await createChangeOrder({ ...payload, contract_id: c.id })
      } else {
        const { fx_usd } = await conFx({ currency: form.currency, fecha: form.period_to })
        const payload = {
          number: Number(form.number),
          period_from: form.period_from || null,
          period_to: form.period_to,
          progress_pct: form.progress_pct === '' ? null : Number(form.progress_pct) / 100,
          description: form.description || null,
          amount: Number(form.amount),
          currency: form.currency,
          fx_usd,
          notes: form.notes || null,
        }
        if (editando) await updateCertificate(editando.id, payload)
        else await createCertificate({ ...payload, project_id: projectId })
      }
      setDrawer(null)
      reload()
    } catch (err) {
      setError(err.message)
    } finally {
      setSaving(false)
    }
  }

  async function borrar() {
    setSaving(true)
    setError(null)
    try {
      if (drawer === 'adicional') await deleteChangeOrder(editando.id)
      else await deleteCertificate(editando.id)
      setDrawer(null)
      reload()
    } catch (err) {
      setError(err.message)
    } finally {
      setSaving(false)
    }
  }

  /** Empuja un certificado al siguiente estado del circuito y le pone la fecha. */
  async function avanzar(cert) {
    const i = CERT_FLOW.indexOf(cert.status)
    const proximo = CERT_FLOW[i + 1]
    if (!proximo) return
    await updateCertificate(cert.id, { status: proximo, [CERT_FECHA[proximo]]: hoy() })
    reload()
  }

  if (contrato.loading || clientes.loading) return <Loading />

  const r = resumen.data
  const e = encargo.data ?? {}
  const avanceReal = progreso.data?.avance_real

  if (!c) {
    return (
      <div style={{ display: 'grid', gap: 16 }}>
        {contrato.error && <ErrorBox message={contrato.error} />}
        <div className="notice">
          <strong>Esta obra todavía no tiene contrato.</strong> Cargalo para poder
          registrar adicionales y certificados, y para que el sistema sepa cuánto falta
          cobrar. Si el cliente no está en la lista, crealo primero en Clientes.
        </div>
        {canManage && (
          <div>
            <button className="btn btn-primary" onClick={() => abrir('contrato')}>
              Cargar contrato
            </button>
          </div>
        )}
        {drawer === 'contrato' && (
          <FormContrato
            form={form} set={set} clientes={clientes.data ?? []}
            error={error} saving={saving}
            onClose={() => setDrawer(null)} onSubmit={guardar}
          />
        )}
      </div>
    )
  }

  return (
    <div style={{ display: 'grid', gap: 24 }}>
      {(resumen.error || adicionales.error || certificados.error) && (
        <ErrorBox message={resumen.error || adicionales.error || certificados.error} />
      )}

      <section style={{ display: 'grid', gap: 12 }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', gap: 12, flexWrap: 'wrap' }}>
          <h2>Contrato con {r?.client_name}</h2>
          {canManage && (
            <button className="btn" onClick={() => abrir('contrato')}>Editar contrato</button>
          )}
        </div>

        <div className="kpi-grid">
          <Kpi
            label="Contrato vigente"
            value={usd(r?.contrato_vigente_usd)}
            hint={
              r?.adicionales_aprobados_usd
                ? `${usd(r.contrato_original_usd)} + ${usd(r.adicionales_aprobados_usd)} de adicionales`
                : FEE_MODELS[c.fee_model]
            }
          />
          <Kpi
            label="Certificado"
            value={usd(r?.certificado_usd)}
            hint={r?.avance_certificado != null ? `${pct(r.avance_certificado)} del contrato` : 'sin certificar'}
          />
          <Kpi label="Cobrado" value={usd(r?.cobrado_usd)} hint="ingresos imputados a la obra" />
          <Kpi
            label="Falta cobrar"
            value={usd(r?.por_cobrar_usd)}
            hint="certificado que todavía no entró"
          />
        </div>

        {r?.adicionales_propuestos_usd > 0 && (
          <div className="notice notice-warning">
            Hay <strong>{usd(r.adicionales_propuestos_usd)}</strong> en adicionales
            propuestos sin decidir. No cuentan en el contrato vigente hasta que el cliente
            los apruebe.
          </div>
        )}

        {avanceReal != null && r?.avance_certificado != null &&
          avanceReal - r.avance_certificado > 0.05 && (
          <div className="notice notice-warning">
            La obra va {pct(avanceReal)} de avance físico y está certificada al{' '}
            {pct(r.avance_certificado)}. Hay trabajo hecho sin certificar: eso es plata
            adelantada por el estudio.
          </div>
        )}
      </section>

      <section style={{ display: 'grid', gap: 12 }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', gap: 12, flexWrap: 'wrap' }}>
          <h2>Adicionales</h2>
          {canManage && (
            <button className="btn" onClick={() => abrir('adicional')}>+ Adicional</button>
          )}
        </div>
        <p style={{ margin: 0, color: 'var(--text-muted)', fontSize: '0.875rem' }}>
          Todo cambio de alcance que mueve el precio. Solo los aprobados cuentan: un
          adicional propuesto es una conversación, no plata.
        </p>
        <Table
          columns={[
            { key: 'order_date', label: 'Fecha' },
            { key: 'description', label: 'Detalle' },
            { key: 'amount_usd', label: 'Monto', num: true },
            { key: 'status', label: 'Estado' },
            { key: 'act', label: '', sort: false },
          ]}
          rows={adicionales.data ?? []}
          empty="Todavía no hay adicionales."
          renderRow={(a) => {
            const [label, tone] = CO_STATUS[a.status] ?? [a.status, null]
            return (
              <tr key={a.id}>
                <td className="nowrap">{date(a.order_date)}</td>
                <td>{a.description}</td>
                <td className="num">{usd(a.amount_usd)}</td>
                <td><Badge tone={tone}>{label}</Badge></td>
                <td className="nowrap">
                  {canManage && (
                    <>
                      <button className="icon-btn" onClick={() => abrir('adicional', a)}>Editar</button>
                      {a.status === 'propuesto' && (
                        <button
                          className="icon-btn"
                          onClick={async () => {
                            await updateChangeOrder(a.id, { status: 'aprobado', decided_on: hoy() })
                            reload()
                          }}
                        >
                          Aprobar
                        </button>
                      )}
                    </>
                  )}
                </td>
              </tr>
            )
          }}
        />
      </section>

      <section style={{ display: 'grid', gap: 12 }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', gap: 12, flexWrap: 'wrap' }}>
          <h2>Certificados de avance</h2>
          {canManage && (
            <button className="btn btn-primary" onClick={() => abrir('certificado')}>
              + Certificado
            </button>
          )}
        </div>
        <p style={{ margin: 0, color: 'var(--text-muted)', fontSize: '0.875rem' }}>
          Lo que se le puede cobrar al cliente por el avance de cada período.
          {avanceReal != null && (
            <> El cronograma marca <strong>{pct(avanceReal)}</strong> de avance físico a hoy.</>
          )}
        </p>
        <Table
          columns={[
            { key: 'number', label: 'N°', num: true },
            { key: 'period_to', label: 'Período' },
            { key: 'progress_pct', label: 'Avance', num: true },
            { key: 'amount_usd', label: 'Monto', num: true },
            { key: 'status', label: 'Estado' },
            { key: 'act', label: '', sort: false },
          ]}
          rows={certificados.data ?? []}
          empty="Todavía no hay certificados emitidos."
          renderRow={(x) => {
            const [label, tone] = CERT_STATUS[x.status] ?? [x.status, null]
            const proximo = CERT_FLOW[CERT_FLOW.indexOf(x.status) + 1]
            return (
              <tr key={x.id}>
                <td className="num">{x.number}</td>
                <td className="nowrap">
                  {x.period_from ? `${date(x.period_from)} – ` : ''}{date(x.period_to)}
                </td>
                <td className="num">{x.progress_pct == null ? '—' : pct(x.progress_pct)}</td>
                <td className="num">{usd(x.amount_usd)}</td>
                <td><Badge tone={tone}>{label}</Badge></td>
                <td className="nowrap">
                  {canManage && (
                    <>
                      <button className="icon-btn" onClick={() => abrir('certificado', x)}>Editar</button>
                      {proximo && (
                        <button className="icon-btn" onClick={() => avanzar(x)}>
                          {CERT_STATUS[proximo][0]}
                        </button>
                      )}
                    </>
                  )}
                </td>
              </tr>
            )
          }}
        />
        <p style={{ margin: 0, color: 'var(--text-muted)', fontSize: '0.8125rem' }}>
          Marcar un certificado como cobrado no carga el ingreso: eso va en la pestaña
          Ingresos, para que el cashflow tenga la fecha real en que entró la plata.
        </p>
      </section>

      <section style={{ display: 'grid', gap: 12 }}>
        <h2>Resultado del estudio</h2>
        <div className="kpi-grid">
          <Kpi label="Cobrado al cliente" value={usd(e.cobrado_usd)} />
          <Kpi
            label="Puso el estudio"
            value={usd(e.costo_estudio_usd)}
            hint="gastos pagados por el estudio"
          />
          <Kpi
            label="Pagó el cliente directo"
            value={usd(e.costo_cliente_usd)}
            hint="costo de obra, pero no plata del estudio"
          />
          <Kpi
            label="Resultado"
            value={usd(e.resultado_estudio_usd)}
            hint={e.margen_pct != null ? `${pct(e.margen_pct)} sobre lo cobrado` : undefined}
          />
        </div>
        <p style={{ margin: 0, color: 'var(--text-muted)', fontSize: '0.8125rem' }}>
          El costo total de construir la casa es {usd(e.costo_obra_usd)}, la haya pagado
          quien la haya pagado. El resultado de arriba es otra pregunta: cuánto ganó el
          estudio, que solo cuenta la plata que salió de su bolsillo.
        </p>
      </section>

      {drawer === 'contrato' && (
        <FormContrato
          form={form} set={set} clientes={clientes.data ?? []}
          error={error} saving={saving}
          onClose={() => setDrawer(null)} onSubmit={guardar}
        />
      )}

      {drawer === 'adicional' && (
        <Drawer
          title={editando ? 'Editar adicional' : 'Nuevo adicional'}
          submitLabel={editando ? 'Guardar cambios' : 'Crear'}
          onClose={() => setDrawer(null)}
          onSubmit={guardar}
          submitting={saving}
          onDelete={editando ? borrar : undefined}
          deleteLabel="Eliminar adicional"
        >
          {error && <ErrorBox message={error} />}
          <Field label="Fecha">
            <input type="date" required value={form.order_date} onChange={set('order_date')} />
          </Field>
          <Field label="Detalle" hint="Qué se cambió y por qué. Es lo que se va a leer dentro de un año.">
            <input required value={form.description} onChange={set('description')} />
          </Field>
          <Field label="Monto" hint="Negativo si el cambio baja el precio.">
            <input type="number" step="0.01" required value={form.amount} onChange={set('amount')} />
          </Field>
          <Field label="Moneda">
            <select value={form.currency} onChange={set('currency')}>
              <option value="USD">USD</option>
              <option value="ARS">ARS</option>
            </select>
          </Field>
          <Field label="Estado">
            <select value={form.status} onChange={set('status')}>
              {Object.entries(CO_STATUS).map(([k, v]) => (
                <option key={k} value={k}>{v[0]}</option>
              ))}
            </select>
          </Field>
          <Field label="Notas"><input value={form.notes} onChange={set('notes')} /></Field>
        </Drawer>
      )}

      {drawer === 'certificado' && (
        <Drawer
          title={editando ? 'Editar certificado' : 'Nuevo certificado'}
          submitLabel={editando ? 'Guardar cambios' : 'Crear'}
          onClose={() => setDrawer(null)}
          onSubmit={guardar}
          submitting={saving}
          onDelete={editando ? borrar : undefined}
          deleteLabel="Eliminar certificado"
        >
          {error && <ErrorBox message={error} />}
          <Field label="Número"><input type="number" min="1" required value={form.number} onChange={set('number')} /></Field>
          <Field label="Desde"><input type="date" value={form.period_from} onChange={set('period_from')} /></Field>
          <Field label="Hasta"><input type="date" required value={form.period_to} onChange={set('period_to')} /></Field>
          <Field
            label="Avance acumulado (%)"
            hint={
              avanceReal != null
                ? `El cronograma marca ${pct(avanceReal)}. Certificar es una negociación: el número lo ponés vos.`
                : 'Avance de obra que reconoce este certificado, acumulado.'
            }
          >
            <input type="number" step="0.01" min="0" max="100" value={form.progress_pct} onChange={set('progress_pct')} />
          </Field>
          <Field label="Monto"><input type="number" step="0.01" required value={form.amount} onChange={set('amount')} /></Field>
          <Field label="Moneda">
            <select value={form.currency} onChange={set('currency')}>
              <option value="USD">USD</option>
              <option value="ARS">ARS</option>
            </select>
          </Field>
          <Field label="Detalle"><input value={form.description} onChange={set('description')} /></Field>
          <Field label="Notas"><input value={form.notes} onChange={set('notes')} /></Field>
        </Drawer>
      )}
    </div>
  )
}

function FormContrato({ form, set, clientes, error, saving, onClose, onSubmit }) {
  const necesitaPct = form.fee_model === 'porcentaje_obra' || form.fee_model === 'costo_mas_fee'
  const necesitaMonto = form.fee_model === 'fijo'

  return (
    <Drawer
      title="Contrato"
      submitLabel="Guardar"
      onClose={onClose}
      onSubmit={onSubmit}
      submitting={saving}
    >
      {error && <ErrorBox message={error} />}

      <Field label="Cliente">
        <select required value={form.client_id} onChange={set('client_id')}>
          <option value="">Elegir…</option>
          {clientes.map((c) => (
            <option key={c.id} value={c.id}>{c.name}</option>
          ))}
        </select>
      </Field>

      <Field label="Fecha de firma">
        <input type="date" value={form.signed_on} onChange={set('signed_on')} />
      </Field>

      <Field
        label="Modalidad de honorarios"
        hint="Se elige por obra porque en la práctica varía, y cada una calcula distinto."
      >
        <select value={form.fee_model} onChange={set('fee_model')}>
          {Object.entries(FEE_MODELS).map(([k, v]) => (
            <option key={k} value={k}>{v}</option>
          ))}
        </select>
      </Field>

      {form.fee_model === 'porcentaje_obra' && (
        <div className="notice">
          Ojo con el incentivo: cuanto más cara sale la obra, más cobra el estudio. El
          cliente también lo sabe.
        </div>
      )}
      {form.fee_model === 'costo_mas_fee' && (
        <div className="notice">
          Esta modalidad implica mostrarle el costo real al cliente, así que acá no hay
          margen escondido: el precio al cliente es el costo más el fee.
        </div>
      )}

      <Field
        label="Monto del contrato"
        hint="Lo que el cliente paga por la obra. En porcentaje o costo + fee, la estimación pactada."
      >
        <input type="number" step="0.01" min="0" required value={form.amount} onChange={set('amount')} />
      </Field>

      <Field label="Moneda">
        <select value={form.currency} onChange={set('currency')}>
          <option value="USD">USD</option>
          <option value="ARS">ARS</option>
        </select>
      </Field>

      {necesitaPct && (
        <Field label="Honorario (%)" hint="Sobre el costo de obra.">
          <input type="number" step="0.01" min="0" max="100" required value={form.fee_pct} onChange={set('fee_pct')} />
        </Field>
      )}

      {necesitaMonto && (
        <Field label="Honorario fijo" hint="En la misma moneda del contrato.">
          <input type="number" step="0.01" min="0" required value={form.fee_amount} onChange={set('fee_amount')} />
        </Field>
      )}

      <Field label="Anticipo">
        <input type="number" step="0.01" min="0" value={form.advance} onChange={set('advance')} />
      </Field>

      <Field label="Notas"><input value={form.notes} onChange={set('notes')} /></Field>
    </Drawer>
  )
}
