import { useMemo, useState } from 'react'
import { useAsync } from '../../lib/useAsync'
import {
  listItems,
  createItem,
  updateItem,
  getItem,
  listCostCategories,
  suggestItemCode,
  listItemPriceHistory,
  listSupplierPrices,
  createPricePoint,
  listSuppliers,
  fxRateAt,
} from '../../lib/queries'
import { usd, pct, date } from '../../lib/format'
import { useAuth } from '../../context/AuthContext'
import { PageHead, Table, Loading, ErrorBox, Drawer, Field, Badge } from '../../components/ui'

/* Los tres catálogos son el mismo catálogo con distinto tipo. Así el historial
   de precios y la comparación de proveedores funcionan igual para todos. */
export const KINDS = {
  insumo: {
    titulo: 'Técnicas',
    subtitulo: 'Materiales y mano de obra de la construcción.',
    etiqueta: 'Técnica',
  },
  servicio: {
    titulo: 'Gastos del proyecto',
    subtitulo: 'Expensas, luz, gas, seguros — lo que se repite todos los meses.',
    etiqueta: 'Gasto del proyecto',
  },
  honorario: {
    titulo: 'Honorarios',
    subtitulo: 'Escribanía, gestoría, arquitectura, comisiones.',
    etiqueta: 'Honorario',
  },
}

const UNITS = ['un', 'm', 'm2', 'm3', 'kg', 'tn', 'lt', 'bolsa', 'ml', 'global', 'jornal']

const FUENTE = {
  referencia: ['Referencia', null],
  cotizacion: ['Cotización', 'warn'],
  compra: ['Compra', 'ok'],
}

const vacio = (kind) => ({
  code: '',
  description: '',
  category_id: '',
  unit: 'un',
  spec: '',
  kind,
})

const PRECIO_VACIO = {
  price_date: new Date().toISOString().slice(0, 10),
  unit_price: '',
  currency: 'ARS',
  supplier_id: '',
  note: '',
}

export default function Catalogo({ kind = 'insumo' }) {
  const { canManage } = useAuth()
  const cfg = KINDS[kind] ?? KINDS.insumo

  const [abierto, setAbierto] = useState(null)
  const [form, setForm] = useState(() => vacio(kind))
  const [saving, setSaving] = useState(false)
  const [formError, setFormError] = useState(null)
  const [busqueda, setBusqueda] = useState('')
  const [abierto_id, setAbiertoId] = useState(null)

  const [precio, setPrecio] = useState(null)
  const [guardandoPrecio, setGuardandoPrecio] = useState(false)

  const items = useAsync(listItems)
  const categories = useAsync(listCostCategories)
  const suppliers = useAsync(listSuppliers)
  const historial = useAsync(
    () => (abierto_id ? listItemPriceHistory(abierto_id) : Promise.resolve(null)),
    [abierto_id]
  )
  const porProveedor = useAsync(
    () => (abierto_id ? listSupplierPrices(abierto_id) : Promise.resolve(null)),
    [abierto_id]
  )

  const set = (k) => (e) => setForm((f) => ({ ...f, [k]: e.target.value }))

  /* Mientras la migración de tipos no esté aplicada, `kind` no existe en
     ninguna fila: en ese caso se muestra todo en vez de nada. */
  const hayTipos = (items.data ?? []).some((i) => i.kind)

  const filas = useMemo(() => {
    const q = busqueda.trim().toLowerCase()
    return (items.data ?? []).filter((i) => {
      if (hayTipos && i.kind !== kind) return false
      if (!q) return true
      return (
        String(i.code).toLowerCase().includes(q) ||
        String(i.description).toLowerCase().includes(q) ||
        String(i.categoria ?? '').toLowerCase().includes(q)
      )
    })
  }, [items.data, busqueda, kind, hayTipos])

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
      setForm(vacio(kind))
      setAbierto(null)
      items.reload()
    } catch (err) {
      setFormError(err.message)
    } finally {
      setSaving(false)
    }
  }

  async function guardarPrecio() {
    setGuardandoPrecio(true)
    try {
      const fx = precio.currency === 'ARS' ? await fxRateAt(precio.price_date) : null
      if (precio.currency === 'ARS' && !fx) {
        throw new Error('No hay cotización del dólar para esa fecha ni anterior.')
      }
      await createPricePoint({
        item_id: precio.item_id,
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

  const sinPrecio = filas.filter((i) => i.precio_actual_usd == null).length

  return (
    <div>
      <PageHead
        title={cfg.titulo}
        subtitle={cfg.subtitulo}
        action={
          <div style={{ display: 'flex', gap: 8, alignItems: 'center', flexWrap: 'wrap' }}>
            <input
              placeholder="Buscar…"
              value={busqueda}
              onChange={(e) => setBusqueda(e.target.value)}
              style={{
                padding: '9px 12px',
                border: '1px solid var(--border-strong)',
                borderRadius: 'var(--radius-sm)',
                background: 'var(--surface)',
                color: 'var(--text)',
                minWidth: 180,
              }}
            />
            {canManage && (
              <button
                className="btn btn-primary"
                onClick={() => {
                  setForm(vacio(kind))
                  setAbierto('nuevo')
                }}
              >
                + Nuevo
              </button>
            )}
          </div>
        }
      />

      {items.error && <ErrorBox message={items.error} />}

      {!items.loading && sinPrecio > 0 && (
        <div className="notice notice-warning" style={{ marginBottom: 14 }}>
          {sinPrecio} de {filas.length} items todavía no tienen ningún precio cargado.
          Abrí uno y usá <strong>Registrar precio</strong>.
        </div>
      )}

      {items.loading ? (
        <Loading />
      ) : (
        <Table
          columns={[
            { key: 'code', label: 'Código' },
            { key: 'description', label: 'Item' },
            { key: 'categoria', label: 'Categoría' },
            { key: 'unit', label: 'Unidad' },
            { key: 'precio_actual_usd', label: 'Precio vigente', num: true },
            { key: 'fecha_precio', label: 'Actualizado' },
            { key: 'origen_precio', label: 'Origen' },
            { key: 'variacion', label: 'Variación', num: true },
            { key: 'precios_registrados', label: 'Registros', num: true },
            { key: 'act', label: '', sort: false },
          ]}
          rows={filas}
          empty="Todavía no hay items de este tipo."
          renderRow={(i) => {
            const [label, tone] = FUENTE[i.origen_precio] ?? [i.origen_precio ?? '—', null]
            return (
              <tr
                key={i.item_id}
                onClick={() => setAbiertoId(abierto_id === i.item_id ? null : i.item_id)}
                style={{
                  cursor: 'pointer',
                  background: abierto_id === i.item_id ? 'var(--accent-soft)' : undefined,
                }}
              >
                <td style={{ fontWeight: 500 }}>{i.code}</td>
                <td>{i.description}</td>
                <td style={{ color: 'var(--text-muted)' }}>{i.categoria ?? '—'}</td>
                <td>{i.unit}</td>
                <td className="num" style={{ fontWeight: 600 }}>
                  {usd(i.precio_actual_usd)}
                </td>
                <td className="nowrap">{date(i.fecha_precio)}</td>
                <td>{i.origen_precio ? <Badge tone={tone}>{label}</Badge> : '—'}</td>
                <td
                  className={`num ${
                    i.variacion > 0 ? 'var-neg' : i.variacion < 0 ? 'var-pos' : ''
                  }`}
                >
                  {i.variacion == null
                    ? '—'
                    : `${i.variacion > 0 ? '+' : ''}${pct(i.variacion)}`}
                </td>
                <td className="num">{i.precios_registrados ?? 0}</td>
                <td className="nowrap">
                  {canManage && (
                    <>
                      <button
                        className="icon-btn"
                        onClick={(e) => {
                          e.stopPropagation()
                          setPrecio({ ...PRECIO_VACIO, item_id: i.item_id, code: i.code })
                        }}
                      >
                        Precio
                      </button>
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
                            kind: full.kind ?? kind,
                          })
                          setAbierto(i)
                        }}
                      >
                        Editar
                      </button>
                    </>
                  )}
                </td>
              </tr>
            )
          }}
        />
      )}

      {abierto_id && (
        <section style={{ marginTop: 20, display: 'grid', gap: 12 }}>
          <h2>Historial de precios</h2>
          <p style={{ margin: 0, color: 'var(--text-muted)', fontSize: '0.875rem' }}>
            Cada precio nuevo es un punto más; nada se pisa. Por eso se puede ver hacia
            dónde va el valor.
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
              renderRow={(h, idx) => {
                const [label, tone] = FUENTE[h.fuente] ?? [h.fuente, null]
                const prev = (historial.data ?? [])[idx + 1]
                const delta =
                  prev && Number(prev.unit_price_usd) > 0
                    ? (Number(h.unit_price_usd) - Number(prev.unit_price_usd)) /
                      Number(prev.unit_price_usd)
                    : null
                return (
                  <tr key={`${h.fuente}-${h.fecha}-${idx}`}>
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

          {(porProveedor.data ?? []).length > 0 && (
            <>
              <h2 style={{ marginTop: 8 }}>Por proveedor</h2>
              <Table
                columns={[
                  { key: 'supplier_name', label: 'Proveedor' },
                  { key: 'mejor_precio_usd', label: 'Mejor precio', num: true },
                  { key: 'precio_vigente_usd', label: 'Precio vigente', num: true },
                  { key: 'cotizaciones', label: 'Cotizaciones', num: true },
                  { key: 'ultima_cotizacion', label: 'Última' },
                ]}
                rows={porProveedor.data}
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
            </>
          )}
        </section>
      )}

      {abierto && (
        <Drawer
          title={abierto === 'nuevo' ? `Nueva ${cfg.etiqueta.toLowerCase()}` : 'Editar item'}
          submitLabel={abierto === 'nuevo' ? 'Crear' : 'Guardar cambios'}
          onClose={() => setAbierto(null)}
          onSubmit={save}
          submitting={saving}
        >
          {formError && <ErrorBox message={formError} />}

          <div className="notice">
            Acá se define <strong>qué</strong> es el item. El precio no se carga en el
            alta: se registra con su fecha y así queda el historial.
          </div>

          <Field label="Categoría">
            <select value={form.category_id} onChange={onCategory}>
              <option value="">Sin categoría</option>
              {(categories.data ?? []).filter((c) => c.parent_id).map((c) => (
                <option key={c.id} value={c.id}>{c.path}</option>
              ))}
            </select>
          </Field>

          <Field label="Código" hint="Se sugiere solo al elegir categoría.">
            <input required value={form.code} onChange={set('code')} />
          </Field>

          <Field label="Descripción">
            <input required value={form.description} onChange={set('description')} />
          </Field>

          <Field
            label="Unidad"
            hint="Elegí la real. Si todo queda en “un” no se pueden comparar precios."
          >
            <select value={form.unit} onChange={set('unit')}>
              {UNITS.map((u) => <option key={u} value={u}>{u}</option>)}
            </select>
          </Field>

          <Field label="Tipo">
            <select value={form.kind} onChange={set('kind')}>
              {Object.entries(KINDS).map(([k, v]) => (
                <option key={k} value={k}>{v.titulo}</option>
              ))}
            </select>
          </Field>

          <Field label="Especificación">
            <input value={form.spec} onChange={set('spec')} />
          </Field>
        </Drawer>
      )}

      {precio && (
        <Drawer
          title={`Registrar precio · ${precio.code}`}
          submitLabel="Registrar"
          onClose={() => setPrecio(null)}
          onSubmit={guardarPrecio}
          submitting={guardandoPrecio}
        >
          {precio.error && <ErrorBox message={precio.error} />}

          <div className="notice">
            Se agrega un punto al historial con su fecha. No reemplaza los anteriores:
            eso es lo que permite ver la tendencia.
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
