import { useState } from 'react'
import { useAsync } from '../../lib/useAsync'
import {
  listItems,
  createItem,
  listCostCategories,
  suggestItemCode,
  listSupplierPrices,
} from '../../lib/queries'
import { usd, date } from '../../lib/format'
import { useAuth } from '../../context/AuthContext'
import { PageHead, Table, Loading, ErrorBox, Drawer, Field } from '../../components/ui'

/* Unidades reales. El catálogo actual tiene los 225 items en "Uni", y sin
   unidad no se puede comparar un precio entre proveedores. */
const UNITS = ['un', 'm', 'm2', 'm3', 'kg', 'tn', 'lt', 'bolsa', 'ml', 'global', 'jornal']

const EMPTY = { code: '', description: '', category_id: '', unit: 'un', spec: '' }

export default function Items() {
  const { canManage } = useAuth()
  const [open, setOpen] = useState(false)
  const [form, setForm] = useState(EMPTY)
  const [saving, setSaving] = useState(false)
  const [formError, setFormError] = useState(null)
  const [expanded, setExpanded] = useState(null)

  const items = useAsync(listItems)
  const categories = useAsync(listCostCategories)
  const prices = useAsync(
    () => (expanded ? listSupplierPrices(expanded) : Promise.resolve(null)),
    [expanded]
  )

  const set = (k) => (e) => setForm((f) => ({ ...f, [k]: e.target.value }))

  /* Al elegir categoría sugerimos el código con la misma lógica del catálogo
     actual: 4 letras de la subcategoría + contador (Pilo-1, Viga-13...). */
  async function onCategory(e) {
    const category_id = e.target.value
    setForm((f) => ({ ...f, category_id }))
    if (!category_id) return
    try {
      const code = await suggestItemCode(category_id)
      if (code) setForm((f) => (f.code ? f : { ...f, code }))
    } catch {
      /* la sugerencia es una comodidad, no un requisito */
    }
  }

  async function save() {
    setSaving(true)
    setFormError(null)
    try {
      await createItem({
        code: form.code,
        description: form.description,
        category_id: form.category_id || null,
        unit: form.unit,
        spec: form.spec || null,
      })
      setForm(EMPTY)
      setOpen(false)
      items.reload()
    } catch (err) {
      setFormError(err.message)
    } finally {
      setSaving(false)
    }
  }

  return (
    <div>
      <PageHead
        title="Items"
        subtitle="Catálogo central, reutilizable entre proyectos. Guarda el historial de precios."
        action={
          canManage && (
            <button className="btn btn-primary" onClick={() => setOpen(true)}>+ Nuevo item</button>
          )
        }
      />

      {items.error && <ErrorBox message={items.error} />}

      {items.loading ? (
        <Loading />
      ) : (
        <Table
          columns={[
            { key: 'code', label: 'Código' },
            { key: 'desc', label: 'Item' },
            { key: 'cat', label: 'Categoría' },
            { key: 'unit', label: 'Unidad' },
            { key: 'quoted', label: 'Últ. cotizado', num: true },
            { key: 'bought', label: 'Últ. comprado', num: true },
            { key: 'avg', label: 'Promedio', num: true },
            { key: 'n', label: 'Cotiz.', num: true },
          ]}
          rows={items.data ?? []}
          empty="Todavía no hay items en el catálogo."
          renderRow={(i) => (
            <tr
              key={i.item_id}
              onClick={() => setExpanded(expanded === i.item_id ? null : i.item_id)}
              style={{ cursor: 'pointer' }}
            >
              <td style={{ fontWeight: 500 }}>{i.code}</td>
              <td>{i.description}</td>
              <td style={{ color: 'var(--text-muted)' }}>{i.categoria ?? '—'}</td>
              <td>{i.unit}</td>
              <td className="num">{usd(i.ultimo_precio_cotizado_usd)}</td>
              <td className="num">{usd(i.ultimo_precio_comprado_usd)}</td>
              <td className="num">{usd(i.precio_promedio_usd)}</td>
              <td className="num">{i.cotizaciones}</td>
            </tr>
          )}
        />
      )}

      {expanded && (
        <section style={{ marginTop: 20, display: 'grid', gap: 12 }}>
          <h2>Precios por proveedor</h2>
          {prices.loading ? (
            <Loading />
          ) : (
            <Table
              columns={[
                { key: 's', label: 'Proveedor' },
                { key: 'best', label: 'Mejor precio', num: true },
                { key: 'cur', label: 'Precio vigente', num: true },
                { key: 'n', label: 'Cotizaciones', num: true },
                { key: 'last', label: 'Última' },
              ]}
              rows={prices.data ?? []}
              empty="Este item todavía no tiene cotizaciones."
              renderRow={(p, idx) => (
                <tr key={p.supplier_id}>
                  <td style={{ fontWeight: idx === 0 ? 600 : 400 }}>
                    {p.supplier_name}
                    {idx === 0 && <> · <span className="var-pos">mejor precio</span></>}
                  </td>
                  <td className="num">{usd(p.mejor_precio_usd)}</td>
                  <td className="num">{usd(p.precio_vigente_usd)}</td>
                  <td className="num">{p.cotizaciones}</td>
                  <td>{date(p.ultima_cotizacion)}</td>
                </tr>
              )}
            />
          )}
        </section>
      )}

      {open && (
        <Drawer title="Nuevo item" onClose={() => setOpen(false)} onSubmit={save} submitting={saving}>
          {formError && <ErrorBox message={formError} />}

          <Field label="Categoría">
            <select value={form.category_id} onChange={onCategory}>
              <option value="">Sin categoría</option>
              {(categories.data ?? []).filter((c) => c.parent_id).map((c) => (
                <option key={c.id} value={c.id}>{c.path}</option>
              ))}
            </select>
          </Field>

          <Field label="Código" hint="Se sugiere solo al elegir categoría. Podés cambiarlo.">
            <input required value={form.code} onChange={set('code')} />
          </Field>

          <Field label="Descripción">
            <input required value={form.description} onChange={set('description')} />
          </Field>

          <Field
            label="Unidad"
            hint="Elegí la real. Si todo queda en “un” no se pueden comparar precios ni calcular consumos."
          >
            <select value={form.unit} onChange={set('unit')}>
              {UNITS.map((u) => <option key={u} value={u}>{u}</option>)}
            </select>
          </Field>

          <Field label="Especificación"><input value={form.spec} onChange={set('spec')} /></Field>
        </Drawer>
      )}
    </div>
  )
}
