import { useEffect, useState } from 'react'
import { useAsync } from '../lib/useAsync'
import {
  listCapitalMovements,
  createCapitalMovement,
  updateCapitalMovement,
  voidCapitalMovement,
  listInvestors,
  listProjects,
  fxRateAt,
} from '../lib/queries'
import { usd, date } from '../lib/format'
import { useAuth } from '../context/AuthContext'
import { PageHead, Table, Loading, ErrorBox, Badge, Drawer, Field } from '../components/ui'

const TYPES = {
  aporte: 'Aporte de capital',
  retiro: 'Retiro de capital',
  profit_asignado: 'Profit asignado',
  profit_distribuido: 'Profit distribuido',
  reinversion: 'Reinversión en otro proyecto',
  transferencia: 'Transferencia entre proyectos',
}

/** Tipos que mueven capital entre dos proyectos. */
const ENTRE_PROYECTOS = ['reinversion', 'transferencia']

const EMPTY = {
  type: 'aporte',
  investor_id: '',
  from_project_id: '',
  project_id: '',
  movement_date: new Date().toISOString().slice(0, 10),
  amount: '',
  currency: 'USD',
  fx_usd: '',
  concept: '',
}

export default function Capital() {
  const { canManage } = useAuth()
  const [abierto, setAbierto] = useState(null)
  const [form, setForm] = useState(EMPTY)
  const [saving, setSaving] = useState(false)
  const [formError, setFormError] = useState(null)

  const movements = useAsync(listCapitalMovements)
  const investors = useAsync(listInvestors)
  const projects = useAsync(listProjects)

  const set = (k) => (e) => setForm((f) => ({ ...f, [k]: e.target.value }))
  const esEntreProyectos = ENTRE_PROYECTOS.includes(form.type)
  const esTransferencia = form.type === 'transferencia'

  /* Cotización sugerida: la vigente a la fecha del movimiento. El usuario
     puede pisarla si la operación se hizo a un tipo de cambio distinto. */
  useEffect(() => {
    if (form.currency !== 'ARS' || !form.movement_date) return
    let cancelled = false
    fxRateAt(form.movement_date)
      .then((rate) => {
        if (!cancelled && rate) setForm((f) => (f.fx_usd ? f : { ...f, fx_usd: String(rate) }))
      })
      .catch(() => {})
    return () => {
      cancelled = true
    }
  }, [form.currency, form.movement_date])

  async function save() {
    setSaving(true)
    setFormError(null)
    try {
      const payload = {
        type: form.type,
        investor_id: esTransferencia ? null : form.investor_id || null,
        from_project_id: esEntreProyectos ? form.from_project_id || null : null,
        project_id: form.project_id || null,
        movement_date: form.movement_date,
        amount: Number(form.amount),
        currency: form.currency,
        fx_usd: form.currency === 'ARS' ? Number(form.fx_usd) : null,
        concept: form.concept || null,
      }
      if (abierto === 'nuevo') await createCapitalMovement(payload)
      else await updateCapitalMovement(abierto.id, payload)
      setForm(EMPTY)
      setAbierto(null)
      movements.reload()
    } catch (err) {
      setFormError(err.message)
    } finally {
      setSaving(false)
    }
  }

  function abrirEdicion(m) {
    setForm({
      type: m.type,
      investor_id: m.investor?.id ?? '',
      from_project_id: m.origen?.id ?? '',
      project_id: m.project?.id ?? '',
      movement_date: m.movement_date,
      amount: String(m.amount),
      currency: m.currency,
      fx_usd: m.fx_usd == null ? '' : String(m.fx_usd),
      concept: m.concept ?? '',
    })
    setAbierto(m)
  }

  async function anular(id) {
    await voidCapitalMovement(id)
    movements.reload()
  }

  const columns = [
    { key: 'movement_date', label: 'Fecha' },
    { key: 'type', label: 'Tipo' },
    { key: 'investor', label: 'Inversor', sort: (m) => m.investor?.name },
    { key: 'project', label: 'Proyecto', sort: (m) => m.project?.code },
    { key: 'amount', label: 'Importe', num: true },
    { key: 'amount_usd', label: 'USD', num: true },
    { key: 'status', label: 'Estado' },
    { key: 'actions', label: '', sort: false },
  ]

  return (
    <div>
      <PageHead
        title="Movimientos de capital"
        subtitle="Libro mayor único: aportes, retiros, profit, reinversiones y transferencias. Nada se borra; se anula."
        action={
          canManage && (
            <button className="btn btn-primary" onClick={() => { setForm(EMPTY); setAbierto('nuevo') }}>
              + Nuevo movimiento
            </button>
          )
        }
      />

      {movements.error && <ErrorBox message={movements.error} />}

      {movements.loading ? (
        <Loading />
      ) : (
        <Table
          columns={columns}
          rows={movements.data ?? []}
          empty="Todavía no hay movimientos de capital."
          renderRow={(m) => (
            <tr key={m.id} style={{ opacity: m.status === 'anulado' ? 0.5 : 1 }}>
              <td>{date(m.movement_date)}</td>
              <td>{TYPES[m.type] ?? m.type}</td>
              <td>{m.investor?.name ?? '—'}</td>
              <td>
                {m.origen ? `${m.origen.code} → ${m.project?.code}` : m.project?.code ?? '—'}
              </td>
              <td className="num">
                {new Intl.NumberFormat('es-AR').format(m.amount)} {m.currency}
              </td>
              <td className="num">{usd(m.amount_usd)}</td>
              <td>
                <Badge tone={m.status === 'confirmado' ? 'ok' : 'off'}>
                  {m.status === 'confirmado' ? 'Confirmado' : 'Anulado'}
                </Badge>
              </td>
              <td className="nowrap">
                {canManage && m.status === 'confirmado' && (
                  <>
                    <button className="icon-btn" onClick={() => abrirEdicion(m)}>
                      Editar
                    </button>
                    <button className="icon-btn" title="Anular" onClick={() => anular(m.id)}>
                      Anular
                    </button>
                  </>
                )}
              </td>
            </tr>
          )}
        />
      )}

      {abierto && (
        <Drawer
          title={abierto === 'nuevo' ? 'Nuevo movimiento de capital' : 'Editar movimiento'}
          submitLabel={abierto === 'nuevo' ? 'Crear' : 'Guardar cambios'}
          onClose={() => setAbierto(null)}
          onSubmit={save}
          submitting={saving}
        >
          {formError && <ErrorBox message={formError} />}

          <Field label="Tipo">
            <select value={form.type} onChange={set('type')}>
              {Object.entries(TYPES).map(([k, label]) => (
                <option key={k} value={k}>{label}</option>
              ))}
            </select>
          </Field>

          {!esTransferencia && (
            <Field label="Inversor">
              <select required value={form.investor_id} onChange={set('investor_id')}>
                <option value="">Elegir…</option>
                {(investors.data ?? []).map((i) => (
                  <option key={i.id} value={i.id}>{i.name}</option>
                ))}
              </select>
            </Field>
          )}

          {esEntreProyectos && (
            <Field label="Proyecto origen" hint="De dónde sale el capital.">
              <select required value={form.from_project_id} onChange={set('from_project_id')}>
                <option value="">Elegir…</option>
                {(projects.data ?? []).map((p) => (
                  <option key={p.id} value={p.id}>{p.code} · {p.name}</option>
                ))}
              </select>
            </Field>
          )}

          <Field label={esEntreProyectos ? 'Proyecto destino' : 'Proyecto'}>
            <select required value={form.project_id} onChange={set('project_id')}>
              <option value="">Elegir…</option>
              {(projects.data ?? [])
                .filter((p) => !esEntreProyectos || p.id !== form.from_project_id)
                .map((p) => (
                  <option key={p.id} value={p.id}>{p.code} · {p.name}</option>
                ))}
            </select>
          </Field>

          <Field label="Fecha">
            <input type="date" required value={form.movement_date} onChange={set('movement_date')} />
          </Field>

          <Field label="Importe" hint="Siempre positivo. El signo lo define el tipo de movimiento.">
            <input type="number" step="0.01" min="0.01" required value={form.amount} onChange={set('amount')} />
          </Field>

          <Field label="Moneda">
            <select value={form.currency} onChange={set('currency')}>
              <option value="USD">USD</option>
              <option value="ARS">ARS</option>
            </select>
          </Field>

          {form.currency === 'ARS' && (
            <Field
              label="Cotización (ARS por USD)"
              hint="Sugerida según la fecha. Cambiala si la operación se hizo a otro tipo de cambio."
            >
              <input type="number" step="0.0001" min="0.0001" required value={form.fx_usd} onChange={set('fx_usd')} />
            </Field>
          )}

          <Field label="Concepto">
            <input value={form.concept} onChange={set('concept')} />
          </Field>
        </Drawer>
      )}
    </div>
  )
}
