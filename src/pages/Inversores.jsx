import { useState } from 'react'
import { Link } from 'react-router-dom'
import { useAsync } from '../lib/useAsync'
import { listInvestorSummary, createInvestor, updateInvestor, getInvestor } from '../lib/queries'
import { usd } from '../lib/format'
import { useAuth } from '../context/AuthContext'
import { PageHead, Table, Loading, ErrorBox, Badge, Drawer, Field } from '../components/ui'

const EMPTY = { name: '', email: '', phone: '', joined_on: '', notes: '' }

export default function Inversores() {
  const { canManage } = useAuth()
  /* null = cerrado · 'nuevo' = alta · objeto = edición */
  const [abierto, setAbierto] = useState(null)
  const [form, setForm] = useState(EMPTY)
  const [saving, setSaving] = useState(false)
  const [formError, setFormError] = useState(null)

  const investors = useAsync(listInvestorSummary)
  const set = (k) => (e) => setForm((f) => ({ ...f, [k]: e.target.value }))

  async function abrirEdicion(id) {
    const inv = await getInvestor(id)
    setForm({
      name: inv.name ?? '',
      email: inv.email ?? '',
      phone: inv.phone ?? '',
      joined_on: inv.joined_on ?? '',
      notes: inv.notes ?? '',
    })
    setAbierto(inv)
  }

  async function save() {
    setSaving(true)
    setFormError(null)
    try {
      const payload = Object.fromEntries(
        Object.entries(form).map(([k, v]) => [k, v === '' ? null : v])
      )
      if (abierto === 'nuevo') await createInvestor(payload)
      else await updateInvestor(abierto.id, payload)
      setForm(EMPTY)
      setAbierto(null)
      investors.reload()
    } catch (err) {
      setFormError(err.message)
    } finally {
      setSaving(false)
    }
  }

  const columns = [
    { key: 'name', label: 'Inversor' },
    { key: 'state', label: 'Estado' },
    { key: 'capital', label: 'Capital invertido', num: true },
    { key: 'pend', label: 'Profit pendiente', num: true },
    { key: 'cobr', label: 'Profit cobrado', num: true },
    { key: 'proj', label: 'Proyectos', num: true },
    { key: 'act', label: '' },
  ]

  return (
    <div>
      <PageHead
        title="Inversores"
        subtitle="Posición consolidada de cada inversor. Calculada sobre el libro mayor de capital, no cargada a mano."
        action={
          canManage && (
            <button className="btn btn-primary" onClick={() => { setForm(EMPTY); setAbierto('nuevo') }}>
              + Nuevo inversor
            </button>
          )
        }
      />

      {investors.error && <ErrorBox message={investors.error} />}

      {investors.loading ? (
        <Loading />
      ) : (
        <Table
          columns={columns}
          rows={investors.data ?? []}
          empty="Todavía no hay inversores cargados."
          renderRow={(i) => (
            <tr key={i.investor_id}>
              <td style={{ fontWeight: 500 }}>
                <Link to={`/inversores/${i.investor_id}`} style={{ color: 'var(--accent)' }}>{i.name}</Link>
              </td>
              <td>
                <Badge tone={i.is_active ? 'ok' : 'off'}>
                  {i.is_active ? 'Activo' : 'Inactivo'}
                </Badge>
              </td>
              <td className="num">{usd(i.capital_invertido_usd)}</td>
              <td className="num">{usd(i.profit_pendiente_usd)}</td>
              <td className="num">{usd(i.profit_cobrado_usd)}</td>
              <td className="num">{i.proyectos_activos}</td>
              <td className="nowrap">
                {canManage && (
                  <button className="icon-btn" onClick={() => abrirEdicion(i.investor_id)}>
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
          title={abierto === 'nuevo' ? 'Nuevo inversor' : 'Editar inversor'}
          submitLabel={abierto === 'nuevo' ? 'Crear' : 'Guardar cambios'}
          onClose={() => setAbierto(null)}
          onSubmit={save}
          submitting={saving}
        >
          {formError && <ErrorBox message={formError} />}

          <Field
            label="Nombre"
            hint="Puede ser una pareja o un grupo familiar, como figura hoy en la planilla."
          >
            <input required value={form.name} onChange={set('name')} />
          </Field>

          <Field label="Email">
            <input type="email" value={form.email} onChange={set('email')} />
          </Field>

          <Field label="Teléfono">
            <input value={form.phone} onChange={set('phone')} />
          </Field>

          <Field label="Fecha de ingreso">
            <input type="date" value={form.joined_on} onChange={set('joined_on')} />
          </Field>

          <Field label="Notas">
            <input value={form.notes} onChange={set('notes')} />
          </Field>
        </Drawer>
      )}
    </div>
  )
}
