import { useState } from 'react'
import { useAsync } from '../lib/useAsync'
import {
  listClients,
  createClient,
  updateClient,
  deleteClient,
  countClientProjects,
} from '../lib/queries'
import { useAuth } from '../context/AuthContext'
import { PageHead, Table, Loading, ErrorBox, Badge, Drawer, Field } from '../components/ui'

/**
 * Clientes: quien encarga una obra.
 *
 * Tabla aparte de los inversores a propósito. Un inversor tiene un derecho
 * proporcional sobre una utilidad que va a existir algún día; un cliente tiene
 * un contrato con un precio y una entrega. Si comparten tabla, "capital
 * invertido" significa dos cosas distintas según la fila.
 */

const VACIO = { name: '', tax_id: '', email: '', phone: '', address: '', notes: '' }

export default function Clientes() {
  const { canManage } = useAuth()
  const [abierto, setAbierto] = useState(null)
  const [form, setForm] = useState(VACIO)
  const [obras, setObras] = useState(0)
  const [saving, setSaving] = useState(false)
  const [error, setError] = useState(null)

  const clientes = useAsync(listClients)
  const set = (k) => (e) => setForm((f) => ({ ...f, [k]: e.target.value }))

  async function abrirEdicion(c) {
    setForm({
      name: c.name ?? '',
      tax_id: c.tax_id ?? '',
      email: c.email ?? '',
      phone: c.phone ?? '',
      address: c.address ?? '',
      notes: c.notes ?? '',
    })
    setObras(await countClientProjects(c.id))
    setError(null)
    setAbierto(c)
  }

  async function guardar() {
    setSaving(true)
    setError(null)
    try {
      const payload = Object.fromEntries(
        Object.entries(form).map(([k, v]) => [k, v === '' ? null : v])
      )
      if (abierto === 'nuevo') await createClient(payload)
      else await updateClient(abierto.id, payload)
      setAbierto(null)
      clientes.reload()
    } catch (err) {
      setError(err.message)
    } finally {
      setSaving(false)
    }
  }

  async function eliminar() {
    setSaving(true)
    setError(null)
    try {
      await deleteClient(abierto.id)
      setAbierto(null)
      clientes.reload()
    } catch (err) {
      setError(err.message)
    } finally {
      setSaving(false)
    }
  }

  async function alternarActivo(c) {
    await updateClient(c.id, { is_active: !c.is_active })
    clientes.reload()
  }

  return (
    <div>
      <PageHead
        title="Clientes"
        subtitle="Quién encarga cada obra. El contrato, los adicionales y los certificados se cargan después, dentro del proyecto."
        action={
          canManage && (
            <button
              className="btn btn-primary"
              onClick={() => { setForm(VACIO); setObras(0); setError(null); setAbierto('nuevo') }}
            >
              + Nuevo cliente
            </button>
          )
        }
      />

      {clientes.error && <ErrorBox message={clientes.error} />}

      {clientes.loading ? (
        <Loading />
      ) : (
        <Table
          columns={[
            { key: 'name', label: 'Cliente' },
            { key: 'tax_id', label: 'CUIT' },
            { key: 'email', label: 'Email' },
            { key: 'phone', label: 'Teléfono' },
            { key: 'is_active', label: 'Estado' },
            { key: 'act', label: '', sort: false },
          ]}
          rows={clientes.data ?? []}
          empty="Todavía no hay clientes cargados."
          renderRow={(c) => (
            <tr key={c.id}>
              <td style={{ fontWeight: 500 }}>{c.name}</td>
              <td>{c.tax_id ?? '—'}</td>
              <td>{c.email ?? '—'}</td>
              <td className="nowrap">{c.phone ?? '—'}</td>
              <td>
                <Badge tone={c.is_active ? 'ok' : 'off'}>
                  {c.is_active ? 'Activo' : 'Inactivo'}
                </Badge>
              </td>
              <td className="nowrap">
                {canManage && (
                  <>
                    <button className="icon-btn" onClick={() => abrirEdicion(c)}>Editar</button>
                    <button className="icon-btn" onClick={() => alternarActivo(c)}>
                      {c.is_active ? 'Desactivar' : 'Activar'}
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
          title={abierto === 'nuevo' ? 'Nuevo cliente' : 'Editar cliente'}
          submitLabel={abierto === 'nuevo' ? 'Crear' : 'Guardar cambios'}
          onClose={() => setAbierto(null)}
          onSubmit={guardar}
          submitting={saving}
          onDelete={abierto !== 'nuevo' && obras === 0 ? eliminar : undefined}
          deleteLabel="Eliminar cliente"
        >
          {error && <ErrorBox message={error} />}

          {abierto !== 'nuevo' && obras > 0 && (
            <div className="notice">
              Tiene {obras === 1 ? '1 obra contratada' : `${obras} obras contratadas`}, así
              que no se puede eliminar: el contrato quedaría sin dueño. Si ya no trabajan
              juntos, desactivalo.
            </div>
          )}

          <Field label="Nombre">
            <input required value={form.name} onChange={set('name')} />
          </Field>

          <Field label="CUIT / CUIL">
            <input value={form.tax_id} onChange={set('tax_id')} />
          </Field>

          <Field label="Email">
            <input type="email" value={form.email} onChange={set('email')} />
          </Field>

          <Field label="Teléfono">
            <input value={form.phone} onChange={set('phone')} />
          </Field>

          <Field label="Dirección">
            <input value={form.address} onChange={set('address')} />
          </Field>

          <Field label="Notas">
            <input value={form.notes} onChange={set('notes')} />
          </Field>
        </Drawer>
      )}
    </div>
  )
}
