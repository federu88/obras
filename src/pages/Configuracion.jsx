import { useAsync } from '../lib/useAsync'
import { listProfiles, updateProfileRole } from '../lib/queries'
import { date } from '../lib/format'
import { useAuth } from '../context/AuthContext'
import { PageHead, Table, Loading, ErrorBox } from '../components/ui'

const ROLES = {
  admin: 'Admin · acceso total',
  manager: 'Manager · opera todo, no gestiona usuarios',
  viewer: 'Viewer · solo lectura de todo el negocio',
  investor: 'Investor · solo sus propias obras',
}

export default function Configuracion() {
  const { isAdmin, profile } = useAuth()
  const users = useAsync(listProfiles)

  return (
    <div style={{ display: 'grid', gap: 24 }}>
      <PageHead
        title="Configuración"
        subtitle="Usuarios y accesos. El tipo de cambio tiene su propia pantalla, en Finanzas → Dólar."
      />

      <section className="card" style={{ display: 'grid', gap: 10 }}>
        <h2 style={{ fontSize: '1rem' }}>Tu cuenta</h2>
        <div style={{ color: 'var(--text-muted)', fontSize: '0.9375rem' }}>
          {profile?.full_name || profile?.email} · rol <strong>{profile?.role}</strong>
        </div>
      </section>

      <section style={{ display: 'grid', gap: 12 }}>
        <div>
          <h2>Usuarios y accesos</h2>
          <p style={{ margin: '4px 0 0', color: 'var(--text-muted)', fontSize: '0.875rem' }}>
            Hoy todos tienen acceso total porque son el equipo de trabajo.
          </p>
        </div>

        <div className="notice notice-warning">
          <strong>Cuando entre el primer inversor con usuario propio</strong>, ponele rol{' '}
          <em>Investor</em> acá <strong>antes</strong> de que inicie sesión. Si queda en
          Admin va a ver cuánto puso cada otro inversor, los precios de todos los
          proveedores, la caja completa y el margen del negocio.
        </div>

        {users.error && <ErrorBox message={users.error} />}

        {users.loading ? (
          <Loading />
        ) : (
          <Table
            columns={[
              { key: 'full_name', label: 'Usuario' },
              { key: 'email', label: 'Email' },
              { key: 'role', label: 'Rol' },
              { key: 'created_at', label: 'Alta' },
            ]}
            rows={users.data ?? []}
            empty="No hay usuarios."
            renderRow={(u) => (
              <tr key={u.id}>
                <td style={{ fontWeight: 500 }}>{u.full_name || '—'}</td>
                <td>{u.email}</td>
                <td>
                  {isAdmin ? (
                    <select
                      value={u.role}
                      onChange={async (e) => {
                        await updateProfileRole(u.id, e.target.value)
                        users.reload()
                      }}
                      style={{
                        padding: '5px 8px',
                        border: '1px solid var(--border-strong)',
                        borderRadius: 'var(--radius-sm)',
                        background: 'var(--surface)',
                        color: 'var(--text)',
                        fontSize: '0.875rem',
                      }}
                    >
                      {Object.entries(ROLES).map(([k, label]) => (
                        <option key={k} value={k}>{label}</option>
                      ))}
                    </select>
                  ) : (
                    ROLES[u.role] ?? u.role
                  )}
                </td>
                <td className="nowrap">{date(u.created_at)}</td>
              </tr>
            )}
          />
        )}
      </section>
    </div>
  )
}
