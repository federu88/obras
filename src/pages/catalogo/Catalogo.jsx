import { useMemo, useState } from 'react'
import { useAsync } from '../../lib/useAsync'
import {
  listItems,
  createItem,
  updateItem,
  listCatalogCategories,
  createCatalogCategory,
  listItemPriceHistory,
  listSupplierPrices,
  createPricePoint,
  listSuppliers,
  fxRateAt,
  listBrands,
  listItemTypes,
  resolverMarca,
  resolverTipoItem,
} from '../../lib/queries'
import { usd, pct, date, normalizar, titulo } from '../../lib/format'
import { useAuth } from '../../context/AuthContext'
import { PageHead, Table, Loading, ErrorBox, Drawer, Field, Badge } from '../../components/ui'

const UNITS = ['un', 'm', 'm2', 'm3', 'kg', 'tn', 'lt', 'bolsa', 'ml', 'global', 'jornal']

const FUENTE = {
  referencia: ['Referencia', null],
  cotizacion: ['Cotización', 'warn'],
  compra: ['Compra', 'ok'],
}

const vacio = () => ({
  code: '',
  catalog_category_id: '',
  tipo: '',
  marca: '',
  unit: 'un',
  note: '',
})

/* Para mostrar cómo va a quedar el código antes de guardar. Lo arma la base
   (completar_item); esto solo lo anticipa, sin el número. */
const prefijoTipo = (tipo) =>
  normalizar(tipo).replace(/[^a-z]/g, '').slice(0, 3).toUpperCase() || 'ITM'

const NUEVA_CATEGORIA = '__nueva__'

const filtroStyle = {
  padding: '9px 12px',
  border: '1px solid var(--border-strong)',
  borderRadius: 'var(--radius-sm)',
  background: 'var(--surface)',
  color: 'var(--text)',
}

/**
 * Campo de texto que apunta a una lista canonica.
 *
 * El problema que resuelve: si cada uno escribe el nombre a mano, "Bidet" y
 * "bidet" terminan siendo dos cosas distintas y los precios dejan de ser
 * comparables. Acá se compara por la forma normalizada mientras se escribe, y
 * si coincide con algo que ya existe se avisa y se usa ESE, con la grafia
 * original. Lo nuevo se crea solo cuando de verdad es nuevo.
 *
 * El aviso es una cortesia: quien impide el duplicado es el indice unico de la
 * base, que está sobre la forma normalizada y no sobre el texto.
 */
function CampoCanonico({ label, hint, value, onChange, opciones, listId, required }) {
  const n = normalizar(value)
  const existente = n ? opciones.find((o) => normalizar(o.name) === n) : null
  const esNuevo = Boolean(n) && !existente

  return (
    <Field label={label} hint={hint}>
      <input
        list={listId}
        required={required}
        value={value}
        onChange={(e) => onChange(e.target.value)}
        onBlur={() => onChange(titulo(value))}
      />
      <datalist id={listId}>
        {opciones.map((o) => <option key={o.id} value={o.name} />)}
      </datalist>
      {existente && existente.name !== value.trim() && (
        <span style={{ fontSize: '0.75rem', color: 'var(--text-muted)' }}>
          Ya existe como <strong>{existente.name}</strong>: se va a usar ese, no se
          crea uno nuevo.
        </span>
      )}
      {esNuevo && (
        <span style={{ fontSize: '0.75rem', color: 'var(--accent)' }}>
          Es nuevo: se va a agregar a la lista.
        </span>
      )}
    </Field>
  )
}

const PRECIO_VACIO = {
  price_date: new Date().toISOString().slice(0, 10),
  unit_price: '',
  currency: 'ARS',
  supplier_id: '',
  note: '',
}

export default function Catalogo() {
  const { canManage } = useAuth()

  const [abierto, setAbierto] = useState(null)
  const [form, setForm] = useState(vacio)
  const [saving, setSaving] = useState(false)
  const [formError, setFormError] = useState(null)
  const [busqueda, setBusqueda] = useState('')
  const [filtroCategoria, setFiltroCategoria] = useState('')
  const [nuevaCategoria, setNuevaCategoria] = useState(null)
  const [abierto_id, setAbiertoId] = useState(null)

  const [precio, setPrecio] = useState(null)
  const [guardandoPrecio, setGuardandoPrecio] = useState(false)

  const items = useAsync(listItems)
  const categories = useAsync(listCatalogCategories)
  const suppliers = useAsync(listSuppliers)
  const marcas = useAsync(listBrands)
  const tipos = useAsync(listItemTypes)
  const historial = useAsync(
    () => (abierto_id ? listItemPriceHistory(abierto_id) : Promise.resolve(null)),
    [abierto_id]
  )
  const porProveedor = useAsync(
    () => (abierto_id ? listSupplierPrices(abierto_id) : Promise.resolve(null)),
    [abierto_id]
  )

  const set = (k) => (e) => setForm((f) => ({ ...f, [k]: e.target.value }))

  const filas = useMemo(() => {
    const q = normalizar(busqueda)
    return (items.data ?? [])
      .filter((i) => {
        if (filtroCategoria && i.catalog_category_id !== filtroCategoria) return false
        if (!q) return true
        return [i.code, i.tipo, i.marca, i.categoria, i.nota].some((v) =>
          normalizar(v).includes(q)
        )
      })
      .sort(
        (a, b) =>
          (a.categoria_orden ?? 9999) - (b.categoria_orden ?? 9999) ||
          String(a.code).localeCompare(String(b.code))
      )
  }, [items.data, busqueda, filtroCategoria])

  const categoriaElegida = (categories.data ?? []).find(
    (c) => c.id === form.catalog_category_id
  )
  let codigo = form.code
  if (categoriaElegida && form.tipo.trim()) {
    const base = `${categoriaElegida.code}-${prefijoTipo(form.tipo)}-`
    if (!codigo.startsWith(base)) codigo = `${base}…`
  }

  function onCategory(e) {
    const v = e.target.value
    if (v === NUEVA_CATEGORIA) {
      setNuevaCategoria({ name: '', error: null })
      return
    }
    setForm((f) => ({ ...f, catalog_category_id: v }))
  }

  async function agregarCategoria() {
    const name = titulo(nuevaCategoria.name)
    if (!name) return
    const existente = (categories.data ?? []).find(
      (c) => normalizar(c.name) === normalizar(name)
    )
    try {
      const c = existente ?? (await createCatalogCategory(name))
      if (!existente) categories.reload()
      setForm((f) => ({ ...f, catalog_category_id: c.id }))
      setNuevaCategoria(null)
    } catch (err) {
      setNuevaCategoria((n) => ({ ...n, error: err.message }))
    }
  }

  async function save() {
    setSaving(true)
    setFormError(null)
    try {
      /* Resolver primero: devuelve el id del que ya existe si el nombre
         normalizado coincide, y solo crea cuando de verdad es nuevo. */
      const [brand_id, item_type_id] = await Promise.all([
        form.marca.trim() ? resolverMarca(titulo(form.marca)) : null,
        resolverTipoItem(titulo(form.tipo)),
      ])

      /* code y description los completa la base: el código sale de la
         categoría y el "qué es"; la descripción, del "qué es" y la marca. */
      const payload = {
        catalog_category_id: form.catalog_category_id || null,
        item_type_id,
        brand_id,
        unit: form.unit,
        note: form.note.trim() || null,
      }
      if (abierto === 'nuevo') await createItem(payload)
      else await updateItem(abierto.item_id, payload)
      setForm(vacio())
      setAbierto(null)
      items.reload()
      marcas.reload()
      tipos.reload()
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
        title="Gastos y compras"
        subtitle="Todo lo que se compra o se paga en una obra, ordenado por categoría."
        action={
          <div style={{ display: 'flex', gap: 8, alignItems: 'center', flexWrap: 'wrap' }}>
            <select
              value={filtroCategoria}
              onChange={(e) => setFiltroCategoria(e.target.value)}
              style={filtroStyle}
            >
              <option value="">Todas las categorías</option>
              {(categories.data ?? []).map((c) => (
                <option key={c.id} value={c.id}>{c.name}</option>
              ))}
            </select>
            <input
              placeholder="Buscar…"
              value={busqueda}
              onChange={(e) => setBusqueda(e.target.value)}
              style={{ ...filtroStyle, minWidth: 180 }}
            />
            {canManage && (
              <button
                className="btn btn-primary"
                onClick={() => {
                  setForm({ ...vacio(), catalog_category_id: filtroCategoria })
                  setNuevaCategoria(null)
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
            { key: 'categoria', label: 'Categoría' },
            { key: 'tipo', label: 'Qué es' },
            { key: 'marca', label: 'Marca' },
            { key: 'unit', label: 'Unidad' },
            { key: 'precio_actual_usd', label: 'Precio vigente', num: true },
            { key: 'fecha_precio', label: 'Actualizado' },
            { key: 'origen_precio', label: 'Origen' },
            { key: 'variacion', label: 'Variación', num: true },
            { key: 'precios_registrados', label: 'Registros', num: true },
            { key: 'act', label: '', sort: false },
          ]}
          rows={filas}
          empty="Todavía no hay nada cargado. Empezá con + Nuevo."
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
                <td className="nowrap" style={{ fontWeight: 500 }}>{i.code}</td>
                <td style={{ color: 'var(--text-muted)' }}>{i.categoria ?? '—'}</td>
                <td>
                  {i.tipo ?? i.description}
                  {i.nota && (
                    <div style={{ fontSize: '0.75rem', color: 'var(--text-muted)' }}>
                      {i.nota}
                    </div>
                  )}
                </td>
                <td style={{ color: 'var(--text-muted)' }}>{i.marca ?? '—'}</td>
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
                        onClick={(e) => {
                          e.stopPropagation()
                          /* La fila del listado ya trae los nombres resueltos. */
                          setForm({
                            code: i.code ?? '',
                            catalog_category_id: i.catalog_category_id ?? '',
                            tipo: i.tipo ?? '',
                            marca: i.marca ?? '',
                            unit: i.unit ?? 'un',
                            note: i.nota ?? '',
                          })
                          setNuevaCategoria(null)
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
          title={abierto === 'nuevo' ? 'Nuevo item' : 'Editar item'}
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
            <select required value={form.catalog_category_id} onChange={onCategory}>
              <option value="">Elegí una categoría</option>
              {(categories.data ?? []).map((c) => (
                <option key={c.id} value={c.id}>
                  {c.name}{c.examples ? ` (${c.examples})` : ''}
                </option>
              ))}
              <option value={NUEVA_CATEGORIA}>+ Agregar categoría…</option>
            </select>
          </Field>

          {nuevaCategoria && (
            <Field label="Nueva categoría">
              <div style={{ display: 'flex', gap: 8 }}>
                <input
                  autoFocus
                  value={nuevaCategoria.name}
                  onChange={(e) => setNuevaCategoria({ name: e.target.value, error: null })}
                  onBlur={() => setNuevaCategoria((n) => n && { ...n, name: titulo(n.name) })}
                  onKeyDown={(e) => {
                    if (e.key === 'Enter') {
                      e.preventDefault()
                      agregarCategoria()
                    }
                  }}
                  style={{ flex: 1 }}
                />
                <button type="button" className="btn" onClick={agregarCategoria}>
                  Agregar
                </button>
                <button type="button" className="btn" onClick={() => setNuevaCategoria(null)}>
                  Cancelar
                </button>
              </div>
              {nuevaCategoria.error && <ErrorBox message={nuevaCategoria.error} />}
            </Field>
          )}

          <CampoCanonico
            label="Qué es"
            hint="El nombre genérico: Lava Manos, Bolsa De Cemento, Volquete. Elegí de la lista o escribí uno nuevo."
            required
            value={form.tipo}
            onChange={(v) => setForm((f) => ({ ...f, tipo: v }))}
            opciones={tipos.data ?? []}
            listId="lista-tipos"
          />

          <CampoCanonico
            label="Marca"
            hint="Opcional. El fabricante, no el proveedor: Ferrum hace el lavamanos, Panamericana te lo vende."
            value={form.marca}
            onChange={(v) => setForm((f) => ({ ...f, marca: v }))}
            opciones={marcas.data ?? []}
            listId="lista-marcas"
          />

          <Field label="Código" hint="Se genera solo con la categoría y el “qué es”.">
            <input readOnly tabIndex={-1} value={codigo} style={{ color: 'var(--text-muted)' }} />
          </Field>

          <Field
            label="Unidad"
            hint="Elegí la real. Si todo queda en “un” no se pueden comparar precios."
          >
            <select value={form.unit} onChange={set('unit')}>
              {UNITS.map((u) => <option key={u} value={u}>{u}</option>)}
            </select>
          </Field>

          <Field label="Nota">
            <textarea rows={3} value={form.note} onChange={set('note')} />
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
