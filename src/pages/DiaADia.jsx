import { useEffect, useRef, useState } from 'react'
import { useAsync } from '../lib/useAsync'
import {
  listProjects,
  listCostCategories,
  listSuppliers,
  listItems,
  listCashBalances,
  listCashAccounts,
  createExpense,
  updateExpense,
  listGastosRecientes,
  getGastoMensual,
  registrarCambio,
  fxRateAt,
} from '../lib/queries'
import { usd, ars, date } from '../lib/format'
import { useAuth } from '../context/AuthContext'
import { PageHead, Table, Loading, ErrorBox, Kpi, Drawer, Field } from '../components/ui'
import GastoForm from '../components/GastoForm'

const hoyIso = () => new Date().toISOString().slice(0, 10)

/* Un solo catálogo con tipo, no tres catálogos. Agrupa sin fragmentar el
   historial de precios ni la comparación de proveedores. */
const TIPOS = {
  insumo: 'Técnicas',
  servicio: 'Gastos del proyecto',
  honorario: 'Honorarios',
}

/**
 * Día a día de obra.
 *
 * Pensada para quien carga veinte gastos seguidos, no para quien consulta.
 * Por eso el formulario está siempre abierto, tiene cinco campos y al guardar
 * conserva la fecha y la categoría: lo único que cambia entre un gasto y el
 * siguiente suele ser el concepto y el importe.
 */
export default function DiaADia() {
  const { canManage } = useAuth()

  const projects = useAsync(listProjects)
  const [projectId, setProjectId] = useState(
    () => localStorage.getItem('obra-activa') ?? ''
  )

  /* La obra elegida se recuerda: es siempre la misma durante meses. */
  useEffect(() => {
    if (projectId) localStorage.setItem('obra-activa', projectId)
  }, [projectId])

  useEffect(() => {
    if (!projectId && projects.data?.length) setProjectId(projects.data[0].id)
  }, [projects.data, projectId])

  const categories = useAsync(listCostCategories)
  const suppliers = useAsync(listSuppliers)
  const items = useAsync(listItems)
  const balances = useAsync(listCashBalances)
  const accounts = useAsync(listCashAccounts)
  const gastos = useAsync(
    () => (projectId ? listGastosRecientes(projectId) : Promise.resolve([])),
    [projectId]
  )
  const mensual = useAsync(
    () => (projectId ? getGastoMensual(projectId) : Promise.resolve([])),
    [projectId]
  )

  /* --- Carga rápida -------------------------------------------------------- */
  const [g, setG] = useState({
    expense_date: hoyIso(),
    kind: 'insumo',
    item_id: '',
    description: '',
    category_id: '',
    supplier_id: '',
    amount: '',
    currency: 'ARS',
  })
  /* Precio de referencia del item elegido. Se guarda aparte del importe para
     poder mostrar de dónde salió y si todavía no fue corregido. */
  const [sugerido, setSugerido] = useState(null)
  const [guardando, setGuardando] = useState(false)
  const [error, setError] = useState(null)
  const conceptoRef = useRef(null)

  const set = (k) => (e) => setG((f) => ({ ...f, [k]: e.target.value }))

  async function agregar(e) {
    e.preventDefault()
    if (!projectId) return
    setGuardando(true)
    setError(null)
    try {
      const fx =
        g.currency === 'ARS' ? await fxRateAt(g.expense_date) : null
      if (g.currency === 'ARS' && !fx) {
        throw new Error(
          'No hay cotización cargada para esa fecha ni anterior. Cargá una en Configuración.'
        )
      }
      await createExpense({
        project_id: projectId,
        description: g.description,
        category_id: g.category_id || null,
        item_id: g.item_id || null,
        supplier_id: g.supplier_id || null,
        expense_date: g.expense_date,
        qty: 1,
        unit_price: Number(g.amount),
        currency: g.currency,
        fx_usd: fx,
        status: 'pagado',
      })
      /* Se conservan fecha, categoría y proveedor: en una jornada se cargan
         varios gastos del mismo rubro y el mismo día. */
      setG((f) => ({ ...f, description: '', amount: '', item_id: '' }))
      setSugerido(null)
      conceptoRef.current?.focus()
      gastos.reload()
      mensual.reload()
    } catch (err) {
      setError(err.message)
    } finally {
      setGuardando(false)
    }
  }

  /* --- Cambio de dólares --------------------------------------------------- */
  const [editando, setEditando] = useState(null)
  const [cambio, setCambio] = useState(null)
  const [cambiando, setCambiando] = useState(false)

  async function guardarCambio() {
    setCambiando(true)
    try {
      await registrarCambio({
        fecha: cambio.fecha,
        usd: Number(cambio.usd),
        cotizacion: Number(cambio.cotizacion),
        cuentaUsd: cambio.cuentaUsd,
        cuentaArs: cambio.cuentaArs,
        projectId: projectId || null,
        nota: cambio.nota || null,
      })
      setCambio(null)
      balances.reload()
    } catch (err) {
      setCambio((c) => ({ ...c, error: err.message }))
    } finally {
      setCambiando(false)
    }
  }

  const filas = gastos.data ?? []
  const hoy = hoyIso()
  const deHoy = filas.filter((x) => x.expense_date === hoy)
  const totalHoy = deHoy.reduce((a, x) => a + Number(x.amount_usd ?? 0), 0)
  const mesActual = (mensual.data ?? [])[0]

  const cajaArs = (balances.data ?? []).filter((b) => b.currency === 'ARS')
  const cajaUsd = (balances.data ?? []).filter((b) => b.currency === 'USD')
  const totalArs = cajaArs.reduce((a, b) => a + Number(b.balance ?? 0), 0)
  const totalUsd = cajaUsd.reduce((a, b) => a + Number(b.balance ?? 0), 0)

  /* Si la migración de tipos todavía no corrió, `kind` no existe en ninguna
     fila: en ese caso no se filtra, para no dejar el selector vacío. */
  const hayTipos = (items.data ?? []).some((i) => i.kind)
  const itemsDelTipo = (items.data ?? []).filter((i) => !hayTipos || i.kind === g.kind)

  const cuentasArs = (accounts.data ?? []).filter((a) => a.currency === 'ARS')
  const cuentasUsd = (accounts.data ?? []).filter((a) => a.currency === 'USD')

  return (
    <div style={{ display: 'grid', gap: 20 }}>
      <PageHead
        title="Día a día"
        subtitle="Carga rápida de los gastos de obra, caja y cambios de moneda."
        action={
          <select
            value={projectId}
            onChange={(e) => setProjectId(e.target.value)}
            style={{
              padding: '9px 12px',
              border: '1px solid var(--border-strong)',
              borderRadius: 'var(--radius-sm)',
              background: 'var(--surface)',
              color: 'var(--text)',
              fontWeight: 500,
            }}
          >
            {(projects.data ?? []).map((p) => (
              <option key={p.id} value={p.id}>{p.code} · {p.name}</option>
            ))}
          </select>
        }
      />

      <div className="kpi-grid">
        <Kpi label="Caja en pesos" value={ars(totalArs)} hint={`${cajaArs.length} cuenta(s)`} />
        <Kpi label="Caja en dólares" value={usd(totalUsd)} hint={`${cajaUsd.length} cuenta(s)`} />
        <Kpi label="Cargado hoy" value={usd(totalHoy)} hint={`${deHoy.length} gasto(s)`} />
        <Kpi
          label="Gastado este mes"
          value={mesActual ? usd(mesActual.total_usd) : usd(0)}
          hint={mesActual ? `${mesActual.cantidad} gastos` : 'sin movimientos'}
        />
      </div>

      {/* --- Carga rápida ---------------------------------------------------- */}
      {canManage && (
        <form className="card" onSubmit={agregar} style={{ display: 'grid', gap: 12 }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', gap: 12, flexWrap: 'wrap' }}>
            <h2 style={{ fontSize: '1rem' }}>Cargar gasto</h2>
            <button
              type="button"
              className="btn"
              onClick={() =>
                setCambio({
                  fecha: hoyIso(),
                  usd: '',
                  cotizacion: '',
                  cuentaUsd: cuentasUsd[0]?.id ?? '',
                  cuentaArs: cuentasArs[0]?.id ?? '',
                  nota: '',
                })
              }
              disabled={!cuentasUsd.length || !cuentasArs.length}
              title={
                !cuentasUsd.length || !cuentasArs.length
                  ? 'Hace falta una cuenta en pesos y una en dólares (Finanzas → Caja)'
                  : undefined
              }
            >
              Cambiar dólares
            </button>
          </div>

          {error && <ErrorBox message={error} />}

          <div
            style={{
              display: 'grid',
              gap: 10,
              gridTemplateColumns:
                'minmax(110px,0.6fr) minmax(130px,0.9fr) minmax(190px,1.6fr) minmax(170px,1.4fr) minmax(150px,1.1fr) minmax(150px,1.1fr) minmax(100px,0.7fr) minmax(85px,0.5fr) auto',
              alignItems: 'end',
            }}
          >
            <div className="field">
              <label>Fecha</label>
              <input type="date" required value={g.expense_date} onChange={set('expense_date')} />
            </div>

            <div className="field">
              <label>Tipo</label>
              <select
                value={g.kind}
                onChange={(e) => setG((f) => ({ ...f, kind: e.target.value, item_id: '' }))}
              >
                <option value="insumo">Técnicas</option>
                <option value="servicio">Gastos del proyecto</option>
                <option value="honorario">Honorarios</option>
              </select>
            </div>

            <div className="field">
              <label>Item del catálogo</label>
              <select
                value={g.item_id}
                onChange={async (e) => {
                  const item_id = e.target.value
                  const it = (items.data ?? []).find((i) => i.item_id === item_id)
                  if (!it) {
                    setSugerido(null)
                    setG((f) => ({ ...f, item_id: '' }))
                    return
                  }

                  /* Referencia: lo último que se pagó vale más que un promedio
                     o que una cotización sin cerrar. */
                  const ref =
                    it.ultimo_precio_comprado_usd != null
                      ? { usd: Number(it.ultimo_precio_comprado_usd), origen: 'última compra' }
                      : it.ultimo_precio_cotizado_usd != null
                        ? { usd: Number(it.ultimo_precio_cotizado_usd), origen: 'última cotización' }
                        : it.precio_promedio_usd != null
                          ? { usd: Number(it.precio_promedio_usd), origen: 'promedio histórico' }
                          : null

                  let monto = ''
                  if (ref) {
                    if (g.currency === 'USD') monto = String(Math.round(ref.usd * 100) / 100)
                    else {
                      const fx = await fxRateAt(g.expense_date)
                      if (fx) monto = String(Math.round(ref.usd * Number(fx)))
                    }
                  }

                  setSugerido(ref ? { ...ref, aplicado: Boolean(monto) } : null)
                  setG((f) => ({
                    ...f,
                    item_id,
                    description: it.description,
                    category_id: it.category_id ?? f.category_id,
                    amount: monto || f.amount,
                  }))
                }}
              >
                <option value="">Sin item — escribir a mano</option>
                {itemsDelTipo.map((i) => (
                  <option key={i.item_id} value={i.item_id}>
                    {i.code} · {i.description}
                  </option>
                ))}
              </select>
            </div>

            <div className="field">
              <label>Concepto</label>
              <input
                ref={conceptoRef}
                required
                placeholder="Ej: Hierro del 8 · 20 barras"
                value={g.description}
                onChange={set('description')}
              />
            </div>

            <div className="field">
              <label>Categoría</label>
              <select value={g.category_id} onChange={set('category_id')}>
                <option value="">Sin categoría</option>
                {(categories.data ?? []).filter((c) => c.parent_id).map((c) => (
                  <option key={c.id} value={c.id}>{c.path}</option>
                ))}
              </select>
            </div>

            <div className="field">
              <label>Proveedor</label>
              <select value={g.supplier_id} onChange={set('supplier_id')}>
                <option value="">—</option>
                {(suppliers.data ?? []).map((s) => (
                  <option key={s.id} value={s.id}>{s.name}</option>
                ))}
              </select>
            </div>

            <div className="field">
              <label>
                Importe
                {sugerido?.aplicado && (
                  <span style={{ color: 'var(--warning)', fontWeight: 600 }}> · sugerido</span>
                )}
              </label>
              <input
                type="number"
                step="0.01"
                min="0.01"
                required
                value={g.amount}
                onChange={(e) => {
                  /* Apenas lo toca deja de ser una sugerencia: pasa a ser lo
                     que realmente gastó. */
                  setSugerido((s) => (s ? { ...s, aplicado: false } : s))
                  setG((f) => ({ ...f, amount: e.target.value }))
                }}
                style={
                  sugerido?.aplicado
                    ? { borderColor: 'var(--warning)', background: 'var(--warning-soft)' }
                    : undefined
                }
              />
            </div>

            <div className="field">
              <label>Moneda</label>
              <select value={g.currency} onChange={set('currency')}>
                <option value="ARS">ARS</option>
                <option value="USD">USD</option>
              </select>
            </div>

            <button className="btn btn-primary" type="submit" disabled={guardando || !projectId}>
              {guardando ? '…' : 'Agregar'}
            </button>
          </div>

          <p style={{ margin: 0, color: 'var(--text-muted)', fontSize: '0.8125rem' }}>
            Elegir un item del catálogo completa el concepto, la categoría y trae el
            <strong> precio de referencia</strong>
            {sugerido ? ` (${sugerido.origen}: ${usd(sugerido.usd)} por unidad)` : ''}. Ese
            importe queda marcado en amarillo hasta que lo pises con lo que gastaste de
            verdad. Si el item no está en el catálogo, dejalo vacío y escribí a mano.
          </p>
        </form>
      )}

      {/* --- Últimos gastos --------------------------------------------------- */}
      <section style={{ display: 'grid', gap: 12 }}>
        <h2>Últimos gastos</h2>
        {gastos.error && <ErrorBox message={gastos.error} />}
        {gastos.loading ? (
          <Loading />
        ) : (
          <Table
            columns={[
              { key: 'expense_date', label: 'Fecha' },
              { key: 'description', label: 'Concepto' },
              { key: 'cat', label: 'Categoría', sort: (x) => x.category?.name },
              { key: 'p', label: 'Proveedor', sort: (x) => x.supplier?.name ?? x.supplier_name },
              { key: 'i', label: 'Importe', num: true, sort: (x) => x.qty * x.unit_price },
              { key: 'amount_usd', label: 'USD', num: true },
              { key: 'a', label: '', sort: false },
            ]}
            rows={filas}
            empty="Todavía no hay gastos cargados en esta obra."
            renderRow={(x) => (
              <tr key={x.id} style={x.expense_date === hoy ? { fontWeight: 500 } : undefined}>
                <td className="nowrap">{date(x.expense_date)}</td>
                <td>{x.description}</td>
                <td style={{ color: 'var(--text-muted)' }}>{x.category?.name ?? '—'}</td>
                <td>{x.supplier?.name ?? x.supplier_name ?? '—'}</td>
                <td className="num">
                  {new Intl.NumberFormat('es-AR').format(x.qty * x.unit_price)} {x.currency}
                </td>
                <td className="num">{usd(x.amount_usd)}</td>
                <td className="nowrap">
                  {canManage && (
                    <>
                      <button className="icon-btn" onClick={() => setEditando(x)}>
                        Editar
                      </button>
                      <button
                        className="icon-btn"
                        onClick={async () => {
                          await updateExpense(x.id, { status: 'anulado' })
                          gastos.reload()
                          mensual.reload()
                        }}
                      >
                        Anular
                      </button>
                    </>
                  )}
                </td>
              </tr>
            )}
          />
        )}
      </section>

      {/* --- Gasto por mes ---------------------------------------------------- */}
      {(mensual.data ?? []).length > 0 && (
        <section style={{ display: 'grid', gap: 12 }}>
          <h2>Últimos meses</h2>
          <Table
            columns={[
              { key: 'month', label: 'Mes' },
              { key: 'cantidad', label: 'Gastos', num: true },
              { key: 'total_usd', label: 'Total USD', num: true },
            ]}
            rows={mensual.data}
            renderRow={(m) => (
              <tr key={m.month}>
                <td className="nowrap">
                  {new Date(m.month + 'T00:00:00').toLocaleDateString('es-AR', {
                    month: 'long',
                    year: 'numeric',
                  })}
                </td>
                <td className="num">{m.cantidad}</td>
                <td className="num">{usd(m.total_usd)}</td>
              </tr>
            )}
          />
        </section>
      )}

      {editando && (
        <GastoForm
          gasto={editando}
          projectId={projectId}
          onClose={() => setEditando(null)}
          onSave={async (payload) => {
            await updateExpense(editando.id, payload)
            gastos.reload()
            mensual.reload()
          }}
        />
      )}

      {/* --- Cambio de dólares ------------------------------------------------ */}
      {cambio && (
        <Drawer
          title="Cambiar dólares a pesos"
          onClose={() => setCambio(null)}
          onSubmit={guardarCambio}
          submitting={cambiando}
          submitLabel="Registrar cambio"
        >
          {cambio.error && <ErrorBox message={cambio.error} />}

          <div className="notice">
            Salen dólares de una caja y entran pesos en otra. Las dos se mueven
            juntas, y queda registrada la cotización que pagaste.
          </div>

          <Field label="Fecha">
            <input
              type="date"
              required
              value={cambio.fecha}
              onChange={(e) => setCambio((c) => ({ ...c, fecha: e.target.value }))}
            />
          </Field>

          <Field label="Dólares a cambiar">
            <input
              type="number"
              step="0.01"
              min="0.01"
              required
              value={cambio.usd}
              onChange={(e) => setCambio((c) => ({ ...c, usd: e.target.value }))}
            />
          </Field>

          <Field label="Cotización (ARS por USD)" hint="La que te pagaron, no la de referencia.">
            <input
              type="number"
              step="0.0001"
              min="0.0001"
              required
              value={cambio.cotizacion}
              onChange={(e) => setCambio((c) => ({ ...c, cotizacion: e.target.value }))}
            />
          </Field>

          {cambio.usd && cambio.cotizacion && (
            <div className="notice notice-warning">
              Entran <strong>{ars(Number(cambio.usd) * Number(cambio.cotizacion))}</strong>
            </div>
          )}

          <Field label="Sale de">
            <select
              required
              value={cambio.cuentaUsd}
              onChange={(e) => setCambio((c) => ({ ...c, cuentaUsd: e.target.value }))}
            >
              {cuentasUsd.map((a) => <option key={a.id} value={a.id}>{a.name}</option>)}
            </select>
          </Field>

          <Field label="Entra en">
            <select
              required
              value={cambio.cuentaArs}
              onChange={(e) => setCambio((c) => ({ ...c, cuentaArs: e.target.value }))}
            >
              {cuentasArs.map((a) => <option key={a.id} value={a.id}>{a.name}</option>)}
            </select>
          </Field>

          <Field label="Nota">
            <input
              value={cambio.nota}
              onChange={(e) => setCambio((c) => ({ ...c, nota: e.target.value }))}
            />
          </Field>
        </Drawer>
      )}
    </div>
  )
}
