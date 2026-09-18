import { useState } from 'react'
import { useAsync } from '../lib/useAsync'
import { listFxRates, createFxRate, listProfiles, updateProfileRole } from '../lib/queries'
import { backfill } from '../lib/fx'
import { date } from '../lib/format'
import { useAuth } from '../context/AuthContext'
import { PageHead, Table, Loading, ErrorBox, Drawer, Field } from '../components/ui'

const ARS = new Intl.NumberFormat('es-AR', { minimumFractionDigits: 2, maximumFractionDigits: 2 })

const ROLES = {
  admin: 'Admin · acceso total',
  manager: 'Manager · opera todo, no gestiona usuarios',
  viewer: 'Viewer · solo lectura de todo el negocio',
  investor: 'Investor · solo sus propias obras',
}

export default function Configuracion() {
  const { canManage, isAdmin, profile } = useAuth()
  const [open, setOpen] = useState(false)
  const [form, setForm] = useState({
    rate_date: new Date().toISOString().slice(0, 10),
    ars_per_usd: '',
    note: '',
  })
  const [saving, setSaving] = useState(false)
  const [formError, setFormError] = useState(null)
  const [cargando, setCargando] = useState(null)
  const [resultado, setResultado] = useState(null)

  const rates = useAsync(listFxRates)
  const users = useAsync(listProfiles)
  const set = (k) => (e) => setForm((f) => ({ ...f, [k]: e.target.value }))

  async function save() {
    setSaving(true)
    setFormError(null)
    try {
      await createFxRate({
        rate_date: form.rate_date,
        source: 'MEP',
        ars_per_usd: Number(form.ars_per_usd),
        note: form.note || 'Carga manual',
      })
      setForm({ ...form, ars_per_usd: '', note: '' })
      setOpen(false)
      rates.reload()
    } catch (err) {
      setFormError(err.message)
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

  return (
    <div style={{ display: 'grid', gap: 24 }}>
      <PageHead
        title="Configuración"
        subtitle="Tipo de cambio de referencia y datos de tu cuenta."
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
          <strong>Cuando entre el primer inversor con usuario propio</strong>, ponele
          rol <em>Investor</em> acá <strong>antes</strong> de que inicie sesión. Si queda
          en Admin va a ver cuánto puso cada otro inversor, los precios de todos los
          proveedores, la caja completa y el margen del negocio.
        </div>

        {users.error && <ErrorBox message={users.error} />}

        {users.loading ? (
          <Loading />
        ) : (
          <Table
            columns={[
              { key: 'u', label: 'Usuario' },
              { key: 'e', label: 'Email' },
              { key: 'r', label: 'Rol' },
              { key: 'a', label: 'Alta' },
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
                <td>{date(u.created_at)}</td>
              </tr>
            )}
          />
        )}
      </section>

      <section style={{ display: 'grid', gap: 12 }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', gap: 12, flexWrap: 'wrap' }}>
          <div>
            <h2>Tipo de cambio</h2>
            <p style={{ margin: '4px 0 0', color: 'var(--text-muted)', fontSize: '0.875rem' }}>
              Dólar MEP, valor de venta. Se trae solo al abrir la app.
            </p>
          </div>
          {canManage && (
            <div style={{ display: 'flex', gap: 8 }}>
              <button className="btn" onClick={traerHistorico} disabled={!!cargando}>
                {cargando
                  ? `Trayendo… ${cargando.revisadas}/${cargando.total}`
                  : 'Traer últimos 90 días'}
              </button>
              <button className="btn btn-primary" onClick={() => setOpen(true)}>
                + Cotización manual
              </button>
            </div>
          )}
        </div>

        <div className="notice">
          <strong>No hace falta cargarlo todos los días.</strong> Cada importe usa la
          cotización más reciente anterior o igual a su fecha, así que un hueco de
          varios días no rompe nada: arrastra la última disponible. La carga
          automática es para que los valores sean exactos, no para que el sistema
          funcione.
        </div>

        {resultado && (
          <div className="notice notice-warning">
            Cargadas {resultado.cargadas} cotizaciones nuevas. {resultado.saltadas} ya
            estaban.
          </div>
        )}

        {rates.error && <ErrorBox message={rates.error} />}

        {rates.loading ? (
          <Loading />
        ) : (
          <Table
            columns={[
              { key: 'd', label: 'Fecha' },
              { key: 'v', label: 'ARS por USD', num: true },
              { key: 's', label: 'Fuente' },
              { key: 'n', label: 'Detalle' },
            ]}
            rows={rates.data ?? []}
            empty="Todavía no hay cotizaciones cargadas. Probá con “Traer últimos 90 días”."
            renderRow={(r) => (
              <tr key={r.id}>
                <td>{date(r.rate_date)}</td>
                <td className="num">{ARS.format(r.ars_per_usd)}</td>
                <td>{r.source}</td>
                <td style={{ color: 'var(--text-muted)' }}>{r.note ?? '—'}</td>
              </tr>
            )}
          />
        )}
      </section>

      {open && (
        <Drawer
          title="Cotización manual"
          onClose={() => setOpen(false)}
          onSubmit={save}
          submitting={saving}
        >
          {formError && <ErrorBox message={formError} />}
          <Field label="Fecha">
            <input type="date" required value={form.rate_date} onChange={set('rate_date')} />
          </Field>
          <Field
            label="ARS por USD"
            hint="Si hiciste una operación de cambio real, cargá esa cotización: es más precisa que la de referencia."
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
