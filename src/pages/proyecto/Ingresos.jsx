import { useEffect, useState } from 'react'
import { useAsync } from '../../lib/useAsync'
import { listRevenues, createRevenue, fxRateAt } from '../../lib/queries'
import { usd, date } from '../../lib/format'
import { useAuth } from '../../context/AuthContext'
import { Table, Loading, ErrorBox, Badge, Drawer, Field } from '../../components/ui'

const KINDS = { venta: 'Venta', anticipo: 'Anticipo', otro: 'Otro' }

const EMPTY = {
  kind: 'venta',
  description: '',
  revenue_date: new Date().toISOString().slice(0, 10),
  amount: '',
  currency: 'USD',
  fx_usd: '',
}

export default function Ingresos({ projectId, onChange }) {
  const { canManage } = useAuth()
  const [open, setOpen] = useState(false)
  const [form, setForm] = useState(EMPTY)
  const [saving, setSaving] = useState(false)
  const [formError, setFormError] = useState(null)

  const revenues = useAsync(() => listRevenues(projectId), [projectId])
  const set = (k) => (e) => setForm((f) => ({ ...f, [k]: e.target.value }))

  useEffect(() => {
    if (form.currency !== 'ARS' || !form.revenue_date) return
    let cancelled = false
    fxRateAt(form.revenue_date)
      .then((r) => {
        if (!cancelled && r) setForm((f) => (f.fx_usd ? f : { ...f, fx_usd: String(r) }))
      })
      .catch(() => {})
    return () => { cancelled = true }
  }, [form.currency, form.revenue_date])

  async function save() {
    setSaving(true)
    setFormError(null)
    try {
      await createRevenue({
        project_id: projectId,
        kind: form.kind,
        description: form.description || null,
        revenue_date: form.revenue_date,
        amount: Number(form.amount),
        currency: form.currency,
        fx_usd: form.currency === 'ARS' ? Number(form.fx_usd) : null,
      })
      setForm(EMPTY)
      setOpen(false)
      revenues.reload()
      onChange?.()
    } catch (err) {
      setFormError(err.message)
    } finally {
      setSaving(false)
    }
  }

  const rows = revenues.data ?? []
  const total = rows.reduce((a, r) => a + Number(r.amount_usd ?? 0), 0)

  return (
    <div style={{ display: 'grid', gap: 16 }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', gap: 12, flexWrap: 'wrap' }}>
        <p style={{ margin: 0, color: 'var(--text-muted)', fontSize: '0.9375rem' }}>
          Ingresos realizados. La venta estimada del proyecto es otra cosa: es el objetivo,
          no un ingreso.
        </p>
        {canManage && (
          <button className="btn btn-primary" onClick={() => setOpen(true)}>+ Nuevo ingreso</button>
        )}
      </div>

      {revenues.error && <ErrorBox message={revenues.error} />}

      {revenues.loading ? (
        <Loading />
      ) : (
        <>
          <Table
            columns={[
              { key: 'date', label: 'Fecha' },
              { key: 'kind', label: 'Tipo' },
              { key: 'desc', label: 'Detalle' },
              { key: 'amount', label: 'Importe', num: true },
              { key: 'usd', label: 'USD', num: true },
            ]}
            rows={rows}
            empty="Todavía no hay ingresos registrados."
            renderRow={(r) => (
              <tr key={r.id}>
                <td>{date(r.revenue_date)}</td>
                <td><Badge tone={r.kind === 'venta' ? 'ok' : null}>{KINDS[r.kind] ?? r.kind}</Badge></td>
                <td>{r.description ?? '—'}</td>
                <td className="num">
                  {new Intl.NumberFormat('es-AR').format(r.amount)} {r.currency}
                </td>
                <td className="num">{usd(r.amount_usd)}</td>
              </tr>
            )}
          />
          {rows.length > 0 && (
            <div className="card" style={{ display: 'flex', justifyContent: 'space-between' }}>
              <strong>Total ingresos</strong>
              <strong className="num">{usd(total)}</strong>
            </div>
          )}
        </>
      )}

      {open && (
        <Drawer title="Nuevo ingreso" onClose={() => setOpen(false)} onSubmit={save} submitting={saving}>
          {formError && <ErrorBox message={formError} />}

          <Field label="Tipo">
            <select value={form.kind} onChange={set('kind')}>
              {Object.entries(KINDS).map(([k, l]) => <option key={k} value={k}>{l}</option>)}
            </select>
          </Field>

          <Field label="Detalle">
            <input value={form.description} onChange={set('description')} />
          </Field>

          <Field label="Fecha">
            <input type="date" required value={form.revenue_date} onChange={set('revenue_date')} />
          </Field>

          <Field label="Importe">
            <input type="number" step="0.01" min="0.01" required value={form.amount} onChange={set('amount')} />
          </Field>

          <Field label="Moneda">
            <select value={form.currency} onChange={set('currency')}>
              <option value="USD">USD</option>
              <option value="ARS">ARS</option>
            </select>
          </Field>

          {form.currency === 'ARS' && (
            <Field label="Cotización (ARS por USD)">
              <input type="number" step="0.0001" min="0.0001" required value={form.fx_usd} onChange={set('fx_usd')} />
            </Field>
          )}
        </Drawer>
      )}
    </div>
  )
}
