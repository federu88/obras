import { useEffect, useState } from 'react'
import { useAsync } from '../../lib/useAsync'
import {
  listQuotes,
  createQuote,
  updateQuote,
  listItemsPlain,
  listSuppliers,
  listProjects,
  fxRateAt,
} from '../../lib/queries'
import { usd, date } from '../../lib/format'
import { useAuth } from '../../context/AuthContext'
import { PageHead, Table, Loading, ErrorBox, Drawer, Field, Badge } from '../../components/ui'

const EMPTY = {
  item_id: '',
  supplier_id: '',
  project_id: '',
  quote_date: new Date().toISOString().slice(0, 10),
  qty: '1',
  unit_price: '',
  currency: 'ARS',
  fx_usd: '',
  payment_terms: '',
  valid_until: '',
  notes: '',
}

export default function Cotizaciones() {
  const { canManage } = useAuth()
  const [abierto, setAbierto] = useState(null)
  const [form, setForm] = useState(EMPTY)
  const [saving, setSaving] = useState(false)
  const [formError, setFormError] = useState(null)

  const quotes = useAsync(() => listQuotes())
  const items = useAsync(listItemsPlain)
  const suppliers = useAsync(listSuppliers)
  const projects = useAsync(listProjects)

  const set = (k) => (e) => setForm((f) => ({ ...f, [k]: e.target.value }))

  useEffect(() => {
    if (form.currency !== 'ARS' || !form.quote_date) return
    let cancelled = false
    fxRateAt(form.quote_date)
      .then((r) => {
        if (!cancelled && r) setForm((f) => (f.fx_usd ? f : { ...f, fx_usd: String(r) }))
      })
      .catch(() => {})
    return () => { cancelled = true }
  }, [form.currency, form.quote_date])

  async function save() {
    setSaving(true)
    setFormError(null)
    try {
      const payload = {
        item_id: form.item_id,
        supplier_id: form.supplier_id,
        project_id: form.project_id || null,
        quote_date: form.quote_date,
        qty: Number(form.qty || 1),
        unit_price: Number(form.unit_price),
        currency: form.currency,
        fx_usd: form.currency === 'ARS' ? Number(form.fx_usd) : null,
        payment_terms: form.payment_terms || null,
        valid_until: form.valid_until || null,
        notes: form.notes || null,
      }
      if (abierto === 'nuevo') await createQuote(payload)
      else await updateQuote(abierto.id, payload)
      setForm(EMPTY)
      setAbierto(null)
      quotes.reload()
    } catch (err) {
      setFormError(err.message)
    } finally {
      setSaving(false)
    }
  }

  const hoy = new Date().toISOString().slice(0, 10)

  return (
    <div>
      <PageHead
        title="Cotizaciones"
        subtitle="El histórico no se borra: es lo que permite comparar presupuesto contra cotización contra compra real."
        action={
          canManage && (
            <button className="btn btn-primary" onClick={() => { setForm(EMPTY); setAbierto('nuevo') }}>
              + Nueva cotización
            </button>
          )
        }
      />

      {quotes.error && <ErrorBox message={quotes.error} />}

      {quotes.loading ? (
        <Loading />
      ) : (
        <Table
          columns={[
            { key: 'date', label: 'Fecha' },
            { key: 'item', label: 'Item' },
            { key: 'sup', label: 'Proveedor' },
            { key: 'qty', label: 'Cant.', num: true },
            { key: 'price', label: 'Precio un.', num: true },
            { key: 'usd', label: 'USD/un', num: true },
            { key: 'terms', label: 'Pago' },
            { key: 'valid', label: 'Validez' },
            { key: 'act', label: '' },
          ]}
          rows={quotes.data ?? []}
          empty="Todavía no hay cotizaciones registradas."
          renderRow={(q) => {
            const vencida = q.valid_until && q.valid_until < hoy
            return (
              <tr key={q.id} style={vencida ? { opacity: 0.55 } : undefined}>
                <td>{date(q.quote_date)}</td>
                <td>
                  <strong>{q.item?.code}</strong> {q.item?.description}
                </td>
                <td>{q.supplier?.name}</td>
                <td className="num">{q.qty} {q.item?.unit}</td>
                <td className="num">
                  {new Intl.NumberFormat('es-AR').format(q.unit_price)} {q.currency}
                </td>
                <td className="num">{usd(q.unit_price_usd)}</td>
                <td>{q.payment_terms ?? '—'}</td>
                <td>
                  {q.valid_until
                    ? vencida
                      ? <Badge tone="off">Vencida</Badge>
                      : date(q.valid_until)
                    : '—'}
                </td>
                <td className="nowrap">
                  {canManage && (
                    <button
                      className="icon-btn"
                      onClick={() => {
                        setForm({
                          item_id: q.item?.id ?? '',
                          supplier_id: q.supplier?.id ?? '',
                          project_id: q.project_id ?? '',
                          quote_date: q.quote_date,
                          qty: String(q.qty),
                          unit_price: String(q.unit_price),
                          currency: q.currency,
                          fx_usd: q.fx_usd == null ? '' : String(q.fx_usd),
                          payment_terms: q.payment_terms ?? '',
                          valid_until: q.valid_until ?? '',
                          notes: q.notes ?? '',
                        })
                        setAbierto(q)
                      }}
                    >
                      Editar
                    </button>
                  )}
                </td>
              </tr>
            )
          }}
        />
      )}

      {abierto && (
        <Drawer
          title={abierto === 'nuevo' ? 'Nueva cotización' : 'Editar cotización'}
          submitLabel={abierto === 'nuevo' ? 'Crear' : 'Guardar cambios'}
          onClose={() => setAbierto(null)}
          onSubmit={save}
          submitting={saving}
        >
          {formError && <ErrorBox message={formError} />}

          <Field label="Item">
            <select required value={form.item_id} onChange={set('item_id')}>
              <option value="">Elegir…</option>
              {(items.data ?? []).map((i) => (
                <option key={i.id} value={i.id}>{i.code} · {i.description}</option>
              ))}
            </select>
          </Field>

          <Field label="Proveedor">
            <select required value={form.supplier_id} onChange={set('supplier_id')}>
              <option value="">Elegir…</option>
              {(suppliers.data ?? []).map((s) => (
                <option key={s.id} value={s.id}>{s.name}</option>
              ))}
            </select>
          </Field>

          <Field label="Proyecto" hint="Opcional: una cotización puede servir para varias obras.">
            <select value={form.project_id} onChange={set('project_id')}>
              <option value="">General</option>
              {(projects.data ?? []).map((p) => (
                <option key={p.id} value={p.id}>{p.code} · {p.name}</option>
              ))}
            </select>
          </Field>

          <Field label="Fecha">
            <input type="date" required value={form.quote_date} onChange={set('quote_date')} />
          </Field>

          <Field label="Cantidad">
            <input type="number" step="0.0001" min="0.0001" required value={form.qty} onChange={set('qty')} />
          </Field>

          <Field label="Precio unitario">
            <input type="number" step="0.0001" min="0" required value={form.unit_price} onChange={set('unit_price')} />
          </Field>

          <Field label="Moneda">
            <select value={form.currency} onChange={set('currency')}>
              <option value="ARS">ARS</option>
              <option value="USD">USD</option>
            </select>
          </Field>

          {form.currency === 'ARS' && (
            <Field label="Cotización (ARS por USD)">
              <input type="number" step="0.0001" min="0.0001" required value={form.fx_usd} onChange={set('fx_usd')} />
            </Field>
          )}

          <Field label="Condición de pago" hint="Ej: 30 días, contado, 50/50">
            <input value={form.payment_terms} onChange={set('payment_terms')} />
          </Field>

          <Field label="Válida hasta">
            <input type="date" value={form.valid_until} onChange={set('valid_until')} />
          </Field>

          <Field label="Observaciones"><input value={form.notes} onChange={set('notes')} /></Field>
        </Drawer>
      )}
    </div>
  )
}
