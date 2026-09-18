import { useState } from 'react'
import { useAsync } from '../../lib/useAsync'
import {
  listItems,
  createItem,
  updateItem,
  getItem,
  listCostCategories,
  suggestItemCode,
  listSupplierPrices,
  listItemPriceHistory,
  createPricePoint,
  listSuppliers,
  fxRateAt,
} from '../../lib/queries'
import { usd, date } from '../../lib/format'
import { useAuth } from '../../context/AuthContext'
import { PageHead, Table, Loading, ErrorBox, Drawer, Field, Badge } from '../../components/ui'

/* Unidades reales. El catálogo actual tiene los 225 items en "Uni", y sin
   unidad no se puede comparar un precio entre proveedores. */
const UNITS = ['un', 'm', 'm2', 'm3', 'kg', 'tn', 'lt', 'bolsa', 'ml', 'global', 'jornal']

const KINDS = {
  insumo: 'Insumo de obra',
  servicio: 'Servicio — expensas, luz, gas, seguros',
  honorario: 'Honorario — escribanía, gestoría, arquitectura',
}

const KIND_CORTO = { insumo: 'Insumo', servicio: 'Servicio', honorario: 'Honorario' }

const EMPTY = { code: '', description: '', category_id: '', unit: 'un', spec: '', kind: 'insumo' }

const FUENTE = {
  referencia: ['Referencia', null],
  cotizacion: ['Cotización', 'warn'],
  compra: ['Compra', 'ok'],
}

const PRECIO_VACIO = {
  price_date: new Date().toISOString().slice(0, 10),
  unit_price: '',
  currency: 'ARS',
  supplier_id: '',
  note: '',
}

export default function Items() {
  const { canManage } = useAuth()
  const [abierto, setAbierto] = useState(null)
  const [form, setForm] = useState(EMPTY)
  const [saving, setSaving] = useState(false)
  const [formError, setFormError] = useState(null)
  const [expanded, setExpanded] = useState(null)
  const [filtro, setFiltro] = useState('')

  const items = useAsync(listItems)
  const categories = useAsync(listCostCategories)
  const prices = useAsync(
    () => (expanded ? listSupplierPrices(expanded) : Promise.resolve(null)),
    [expanded]
  )
  const historial = useAsync(
    () => (expanded ? listItemPriceHistory(expanded) : Promise.resolve(null)),
    [expanded]
  )
  const suppliers = useAsync(listSuppliers)

  /* Registrar un precio agrega un punto al historial; no pisa los anteriores. */
  const [precio, setPrecio] = useState(null)
  const [guardandoPrecio, setGuardandoPrecio] = useState(false)

  async function guardarPrecio() {
    setGuardandoPrecio(true)
    try {
      const fx = precio.currency === 'ARS' ? await fxRateAt(precio.price_date) : null
      if (precio.currency === 'ARS' && !fx) {
        throw new Error('No hay cotización del dólar para esa fecha ni anterior.')
      }
      await createPricePoint({
        item_id: expanded,
        price_date: precio.price_date,
        unit_price: Number(precio.unit_price),
        currency: precio.currency,
        fx_usd: fx,
        supplier_id: precio.supplier_id || null,
        note: precio.note || null,
      })
      setPrecio(null)
      historial.reload()
      items.reload()
    } catch (err) {
      setPrecio((p) => ({ ...p, error: err.message }))
    } finally {
      setGuardandoPrecio(false)
    }
  }

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
      const payload = {
        code: form.code,
        description: form.description,
        category_id: form.category_id || null,
        unit: form.unit,
        spec: form.spec || null,
        kind: form.kind,
      }
      if (abierto === 'nuevo') await createItem(payload)
      else await updateItem(abierto.item_id, payload)
      setForm(EMPTY)
      setAbierto(null)
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
          <div style={{ display: 'flex', gap: 8, alignItems: 'center' }}>
            <select
              value={filtro}
              onChange={(e) => setFiltro(e.target.value)}
              style={{
                padding: '9px 12px',
                border: '1px solid var(--border-strong)',
                borderRadius: 'var(--radius-sm)',
                background: 'var(--surface)',
                color: 'var(--text)',
              }}
            >
              <option value="">Todos los tipos</option>
              {Object.entries(KIND_CORTO).map(([k, l]) => (
                <option key={k} value={k}>{l}</option>
              ))}
            </select>
            {canManage && (
              <button className="btn btn-primary" onClick={() => { setForm(EMPTY); setAbierto('nuevo') }}>+ Nuevo item</button>
            )}
          </div>
        }
      />

      {items.error && <ErrorBox message={items.error} />}

      {items.loading ? (
        <Loading />
      ) : (
        <Table
          columns={[
            { key: 'code', label: 'Código' },
            { key: 'description', label: 'Item' },
            { key: 'kind', label: 'Tipo' },
            { key: 'categoria', label: 'Categoría' },
            { key: 'unit', label: 'Unidad' },
            { key: 'ultimo_precio_cotizado_usd', label: 'Últ. cotizado', num: true },
            { key: 'ultimo_precio_comprado_usd', label: 'Últ. comprado', num: true },
            { key: 'precio_promedio_usd', label: 'Promedio', num: true },
            { key: 'cotizaciones', label: 'Cotiz.', num: true },
            { key: 'act', label: '', sort: false },
          ]}
          rows={(items.data ?? []).filter((i) => !filtro || i.kind === filtro)}
          empty="No hay items de este tipo en el catálogo."
          renderRow={(i) => (
            <tr
              key={i.item_id}
              onClick={() => setExpanded(expanded === i.item_id ? null : i.item_id)}
              style={{ cursor: 'pointer' }}
            >
              <td style={{ fontWeight: 500 }}>{i.code}</td>
              <td>{i.description}</td>
              <td className="nowrap" style={{ color: 'var(--text-muted)' }}>
                {KIND_CORTO[i.kind] ?? i.kind}
              </td>
              <td style={{ color: 'var(--text-muted)' }}>{i.categoria ?? '—'}</td>
              <td>{i.unit}</td>
              <td className="num">{usd(i.ultimo_precio_cotizado_usd)}</td>
              <td className="num">{usd(i.ultimo_precio_comprado_usd)}</td>
              <td className="num">{usd(i.precio_promedio_usd)}</td>
              <td className="num">{i.cotizaciones}</td>
              <td className="nowrap">
                {canManage && (
                  <button
                    className="icon-btn"
                    onClick={async (e) => {
                      e.stopPropagation()
                      const full = await getItem(i.item_id)
                      setForm({
                        code: full.code ?? '',
                        description: full.description ?? '',
                        category_id: full.category_id ?? '',
                        unit: full.unit ?? 'un',
                        spec: full.spec ?? '',
                        kind: full.kind ?? 'insumo',
                      })
                      setAbierto(i)
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

      {expanded && (
        <section style={{ marginTop: 20, display: 'grid', gap: 12 }}>
          <div
            style={{
              display: 'flex',
              justifyContent: 'space-between',
              alignItems: 'center',
              gap: 12,
              flexWrap: 'wrap',
            }}
          >
            <h2>Historial de precios</h2>
            {canManage && (
              <button className="btn btn-primary" onClick={() => setPrecio(PRECIO_VACIO)}>
                + Registrar precio
              </button>
            )}
          </div>

          <p style={{ margin: 0, color: 'var(--text-muted)', fontSize: '0.875rem' }}>
            Las tres fuentes en una sola línea de tiempo. Nada se pisa: cada precio nuevo
            es un punto más, y así se ve hacia dónde va el valor.
          </p>

          {historial.loading ? (
            <Loading />
          ) : (
            <Table
              columns={[
                { key: 'fecha', label: 'Fecha' },
                { key: 'fuente', label: 'Origen' },
                { key: 'proveedor', label: 'Proveedor' },
                { key: 'unit_price', label: 'Precio', num: true },
                { key: 'unit_price_usd', label: 'USD', num: true },
                { key: 'detalle', label: 'Detalle' },
              ]}
              rows={historial.data ?? []}
              empty="Este item todavía no tiene precios registrados."
              renderRow={(h, i) => {
                const [label, tone] = FUENTE[h.fuente] ?? [h.fuente, null]
                const prev = (historial.data ?? [])[i + 1]
                const delta =
                  prev && Number(prev.unit_price_usd) > 0
                    ? (Number(h.unit_price_usd) - Number(prev.unit_price_usd)) /
                      Number(prev.unit_price_usd)
                    : null
                return (
                  <tr key={`${h.fuente}-${h.fecha}-${i}`}>
                    <td className="nowrap">{date(h.fecha)}</td>
                    <td><Badge tone={tone}>{label}</Badge></td>
                    <td>{h.proveedor ?? '—'}</td>
                    <td className="num">
                      {new Intl.NumberFormat('es-AR').format(h.unit_price)} {h.currency}
                    </td>
                    <td className="num">
                      {usd(h.unit_price_usd)}
                      {delta != null && Math.abs(delta) > 0.001 && (
                        <span className={delta > 0 ? 'var-neg' : 'var-pos'}>
                          {' '}{delta > 0 ? '+' : ''}{(delta * 100).toFixed(1)}%
                        </span>
                      )}
                    </td>
                    <td style={{ color: 'var(--text-muted)' }}>{h.detalle ?? '—'}</td>
                  </tr>
                )
              }}
            />
          )}

          <h2 style={{ marginTop: 8 }}>Comparativa de proveedores</h2>
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

      {abierto && (
        <Drawer
          title={abierto === 'nuevo' ? 'Nuevo item' : 'Editar item'}
          submitLabel={abierto === 'nuevo' ? 'Crear' : 'Guardar cambios'}
          onClose={() => setAbierto(null)}
          onSubmit={save}
          submitting={saving}
        >
          {formError && <ErrorBox message={formError} />}

          <Field
            label="Tipo"
            hint="Agrupa el catálogo: insumos de obra, servicios que se repiten todos los meses, y honorarios profesionales."
          >
            <select value={form.kind} onChange={set('kind')}>
              {Object.entries(KINDS).map(([k, l]) => (
                <option key={k} value={k}>{l}</option>
              ))}
            </select>
          </Field>

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

      {precio && (
        <Drawer
          title="Registrar precio"
          submitLabel="Registrar"
          onClose={() => setPrecio(null)}
          onSubmit={guardarPrecio}
          submitting={guardandoPrecio}
        >
          {precio.error && <ErrorBox message={precio.error} />}

          <div className="notice">
            Se agrega un punto al historial. No reemplaza ni borra los anteriores: eso es
            lo que permite ver la tendencia.
          </div>

          <Field label="Fecha">
            <input
              type="date"
              required
              value={precio.price_date}
              onChange={(e) => setPrecio((p) => ({ ...p, price_date: e.target.value }))}
            />
          </Field>

          <Field label="Precio unitario">
            <input
              type="number"
              step="0.0001"
              min="0"
              required
              value={precio.unit_price}
              onChange={(e) => setPrecio((p) => ({ ...p, unit_price: e.target.value }))}
            />
          </Field>

          <Field label="Moneda" hint="Si es en pesos se convierte con el dólar de esa fecha.">
            <select
              value={precio.currency}
              onChange={(e) => setPrecio((p) => ({ ...p, currency: e.target.value }))}
            >
              <option value="ARS">ARS</option>
              <option value="USD">USD</option>
            </select>
          </Field>

          <Field label="Proveedor" hint="Opcional: un precio de lista puede no tener proveedor.">
            <select
              value={precio.supplier_id}
              onChange={(e) => setPrecio((p) => ({ ...p, supplier_id: e.target.value }))}
            >
              <option value="">—</option>
              {(suppliers.data ?? []).map((s) => (
                <option key={s.id} value={s.id}>{s.name}</option>
              ))}
            </select>
          </Field>

          <Field label="Detalle">
            <input
              value={precio.note}
              onChange={(e) => setPrecio((p) => ({ ...p, note: e.target.value }))}
            />
          </Field>
        </Drawer>
      )}
    </div>
  )
}
