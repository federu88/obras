import { useState } from 'react'
import { useAsync } from '../lib/useAsync'
import {
  listCashBalances,
  listCashAccounts,
  createCashAccount,
  listCashMovements,
  createCashMovement,
  listProjects,
} from '../lib/queries'
import { usd, ars, date } from '../lib/format'
import { useAuth } from '../context/AuthContext'
import { PageHead, Table, Loading, ErrorBox, Drawer, Field, Kpi } from '../components/ui'

const EMPTY_ACCOUNT = { name: '', currency: 'ARS', project_id: '' }
const EMPTY_MOVEMENT = {
  account_id: '',
  project_id: '',
  movement_date: new Date().toISOString().slice(0, 10),
  concept: '',
  direction: 'salida',
  amount: '',
}

export default function Caja() {
  const { canManage } = useAuth()
  const [drawer, setDrawer] = useState(null) // 'account' | 'movement'
  const [account, setAccount] = useState(EMPTY_ACCOUNT)
  const [movement, setMovement] = useState(EMPTY_MOVEMENT)
  const [saving, setSaving] = useState(false)
  const [formError, setFormError] = useState(null)

  const balances = useAsync(listCashBalances)
  const accounts = useAsync(listCashAccounts)
  const movements = useAsync(listCashMovements)
  const projects = useAsync(listProjects)

  const setA = (k) => (e) => setAccount((f) => ({ ...f, [k]: e.target.value }))
  const setM = (k) => (e) => setMovement((f) => ({ ...f, [k]: e.target.value }))

  function close() {
    setDrawer(null)
    setFormError(null)
  }

  async function saveAccount() {
    setSaving(true)
    setFormError(null)
    try {
      await createCashAccount({
        name: account.name,
        currency: account.currency,
        project_id: account.project_id || null,
      })
      setAccount(EMPTY_ACCOUNT)
      close()
      balances.reload()
      accounts.reload()
    } catch (err) {
      setFormError(err.message)
    } finally {
      setSaving(false)
    }
  }

  async function saveMovement() {
    setSaving(true)
    setFormError(null)
    try {
      /* El signo lo pone la dirección elegida, no el usuario tipeando un
         número negativo. En la planilla actual hay importes negativos sueltos
         que nadie sabe si son devoluciones o errores de carga. */
      const signed =
        movement.direction === 'salida'
          ? -Math.abs(Number(movement.amount))
          : Math.abs(Number(movement.amount))

      await createCashMovement({
        account_id: movement.account_id,
        project_id: movement.project_id || null,
        movement_date: movement.movement_date,
        concept: movement.concept,
        amount: signed,
      })
      setMovement(EMPTY_MOVEMENT)
      close()
      balances.reload()
      movements.reload()
    } catch (err) {
      setFormError(err.message)
    } finally {
      setSaving(false)
    }
  }

  const rows = balances.data ?? []

  return (
    <div style={{ display: 'grid', gap: 24 }}>
      <PageHead
        title="Caja y cambios"
        subtitle="Una cuenta sin proyecto es caja común del negocio. Cada movimiento se imputa a una obra, esté en la cuenta que esté."
        action={
          canManage && (
            <div style={{ display: 'flex', gap: 8 }}>
              <button className="btn" onClick={() => setDrawer('account')}>+ Cuenta</button>
              <button className="btn btn-primary" onClick={() => setDrawer('movement')}>
                + Movimiento
              </button>
            </div>
          )
        }
      />

      {balances.error && <ErrorBox message={balances.error} />}

      {balances.loading ? (
        <Loading />
      ) : rows.length === 0 ? (
        <div className="notice notice-warning">
          Todavía no hay cuentas de caja. Creá al menos una en pesos y una en dólares —
          así opera hoy tu planilla, con ARS 9.988.670 y USD 124.100 compartidos entre las
          dos obras.
        </div>
      ) : (
        <div className="kpi-grid">
          {rows.map((b) => (
            <Kpi
              key={b.account_id}
              label={b.name}
              value={b.currency === 'USD' ? usd(b.balance) : ars(b.balance)}
              hint={b.project_id ? 'Caja del proyecto' : 'Caja común'}
            />
          ))}
        </div>
      )}

      <section style={{ display: 'grid', gap: 12 }}>
        <h2>Movimientos</h2>
        {movements.loading ? (
          <Loading />
        ) : (
          <Table
            columns={[
              { key: 'date', label: 'Fecha' },
              { key: 'account', label: 'Cuenta' },
              { key: 'concept', label: 'Concepto' },
              { key: 'project', label: 'Obra' },
              { key: 'amount', label: 'Importe', num: true },
            ]}
            rows={movements.data ?? []}
            empty="Todavía no hay movimientos de caja."
            renderRow={(m) => (
              <tr key={m.id}>
                <td>{date(m.movement_date)}</td>
                <td>{m.account?.name}</td>
                <td>{m.concept}</td>
                <td>{m.project?.code ?? <span style={{ color: 'var(--text-muted)' }}>sin imputar</span>}</td>
                <td className={`num ${Number(m.amount) < 0 ? 'var-neg' : 'var-pos'}`}>
                  {new Intl.NumberFormat('es-AR').format(m.amount)} {m.account?.currency}
                </td>
              </tr>
            )}
          />
        )}
      </section>

      {drawer === 'account' && (
        <Drawer title="Nueva cuenta de caja" onClose={close} onSubmit={saveAccount} submitting={saving}>
          {formError && <ErrorBox message={formError} />}
          <Field label="Nombre" hint="Ej: Caja pesos, Caja dólares, Banco">
            <input required value={account.name} onChange={setA('name')} />
          </Field>
          <Field label="Moneda">
            <select value={account.currency} onChange={setA('currency')}>
              <option value="ARS">ARS</option>
              <option value="USD">USD</option>
            </select>
          </Field>
          <Field label="Proyecto" hint="Dejalo vacío si es caja común del negocio.">
            <select value={account.project_id} onChange={setA('project_id')}>
              <option value="">Caja común</option>
              {(projects.data ?? []).map((p) => (
                <option key={p.id} value={p.id}>{p.code} · {p.name}</option>
              ))}
            </select>
          </Field>
        </Drawer>
      )}

      {drawer === 'movement' && (
        <Drawer title="Nuevo movimiento de caja" onClose={close} onSubmit={saveMovement} submitting={saving}>
          {formError && <ErrorBox message={formError} />}
          <Field label="Cuenta">
            <select required value={movement.account_id} onChange={setM('account_id')}>
              <option value="">Elegir…</option>
              {(accounts.data ?? []).map((a) => (
                <option key={a.id} value={a.id}>{a.name} ({a.currency})</option>
              ))}
            </select>
          </Field>
          <Field label="Dirección">
            <select value={movement.direction} onChange={setM('direction')}>
              <option value="entrada">Entrada</option>
              <option value="salida">Salida</option>
            </select>
          </Field>
          <Field label="Importe" hint="Siempre positivo. El signo lo define la dirección.">
            <input type="number" step="0.01" min="0.01" required value={movement.amount} onChange={setM('amount')} />
          </Field>
          <Field label="Fecha">
            <input type="date" required value={movement.movement_date} onChange={setM('movement_date')} />
          </Field>
          <Field label="Concepto">
            <input required value={movement.concept} onChange={setM('concept')} />
          </Field>
          <Field label="Imputar a obra" hint="Opcional, pero sin esto el gasto no se puede atribuir a ninguna casa.">
            <select value={movement.project_id} onChange={setM('project_id')}>
              <option value="">Sin imputar</option>
              {(projects.data ?? []).map((p) => (
                <option key={p.id} value={p.id}>{p.code} · {p.name}</option>
              ))}
            </select>
          </Field>
        </Drawer>
      )}
    </div>
  )
}
