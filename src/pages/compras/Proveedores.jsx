import { useState } from 'react'
import { useAsync } from '../../lib/useAsync'
import { listSuppliers, createSupplier, updateSupplier } from '../../lib/queries'
import { useAuth } from '../../context/AuthContext'
import { PageHead, Table, Loading, ErrorBox, Badge, Drawer, Field } from '../../components/ui'

const EMPTY = { name: '', contact_name: '', phone: '', email: '', notes: '' }

export default function Proveedores() {
  const { canManage } = useAuth()
  const [abierto, setAbierto] = useState(null)
  const [form, setForm] = useState(EMPTY)
  const [saving, setSaving] = useState(false)
  const [formError, setFormError] = useState(null)

  const suppliers = useAsync(listSuppliers)
  const set = (k) => (e) => setForm((f) => ({ ...f, [k]: e.target.value }))

  async function save() {
    setSaving(true)
    setFormError(null)
    try {
      const payload = Object.fromEntries(
        Object.entries(form).map(([k, v]) => [k, v === '' ? null : v])
      )
      if (abierto === 'nuevo') await createSupplier(payload)
      else await updateSupplier(abierto.id, payload)
      setForm(EMPTY)
      setAbierto(null)
      suppliers.reload()
    } catch (err) {
      setFormError(err.message)
    } finally {
      setSaving(false)
    }
  }

  return (
    <div>
      <PageHead
        title="Proveedores"
        subtitle="El teléfono va en su columna, no dentro del nombre."
        action={
          canManage && (
            <button className="btn btn-primary" onClick={() => { setForm(EMPTY); setAbierto('nuevo') }}>
              + Nuevo proveedor
            </button>
          )
        }
      />

      {suppliers.error && <ErrorBox message={suppliers.error} />}

      {suppliers.loading ? (
        <Loading />
      ) : (
        <Table
          columns={[
            { key: 'name', label: 'Proveedor' },
            { key: 'contact', label: 'Contacto' },
            { key: 'phone', label: 'Teléfono' },
            { key: 'email', label: 'Email' },
            { key: 'state', label: 'Estado' },
            { key: 'act', label: '' },
          ]}
          rows={suppliers.data ?? []}
          empty="Todavía no hay proveedores cargados."
          renderRow={(s) => (
            <tr key={s.id}>
              <td style={{ fontWeight: 500 }}>{s.name}</td>
              <td>{s.contact_name ?? '—'}</td>
              <td>{s.phone ?? '—'}</td>
              <td>{s.email ?? '—'}</td>
              <td>
                <Badge tone={s.is_active ? 'ok' : 'off'}>
                  {s.is_active ? 'Activo' : 'Inactivo'}
                </Badge>
              </td>
              <td className="nowrap">
                {canManage && (
                  <button
                    className="icon-btn"
                    onClick={() => {
                      setForm({
                        name: s.name ?? '',
                        contact_name: s.contact_name ?? '',
                        phone: s.phone ?? '',
                        email: s.email ?? '',
                        notes: s.notes ?? '',
                      })
                      setAbierto(s)
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
          title={abierto === 'nuevo' ? 'Nuevo proveedor' : 'Editar proveedor'}
          submitLabel={abierto === 'nuevo' ? 'Crear' : 'Guardar cambios'}
          onClose={() => setAbierto(null)}
          onSubmit={save}
          submitting={saving}
        >
          {formError && <ErrorBox message={formError} />}
          <Field label="Nombre" hint="Un nombre real, no “TBD” ni “estimado”.">
            <input required value={form.name} onChange={set('name')} />
          </Field>
          <Field label="Contacto"><input value={form.contact_name} onChange={set('contact_name')} /></Field>
          <Field label="Teléfono"><input value={form.phone} onChange={set('phone')} /></Field>
          <Field label="Email"><input type="email" value={form.email} onChange={set('email')} /></Field>
          <Field label="Notas"><input value={form.notes} onChange={set('notes')} /></Field>
        </Drawer>
      )}
    </div>
  )
}
