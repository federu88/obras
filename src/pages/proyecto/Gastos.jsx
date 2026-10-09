import { Fragment, useState } from 'react'
import { useAsync } from '../../lib/useAsync'
import {
  listExpenses,
  listReceipts,
  createExpense,
  updateExpense,
  deleteExpenses,
  uploadReceiptPhoto,
  getReceiptPhotoUrl,
} from '../../lib/queries'
import { usd, date } from '../../lib/format'
import { COST_TYPES } from '../../lib/costos'
import { useAuth } from '../../context/AuthContext'
import { Table, Loading, ErrorBox, Badge } from '../../components/ui'
import GastoForm from '../../components/GastoForm'
import ComprobanteForm from '../../components/ComprobanteForm'
import DesgloseLinea from '../../components/DesgloseLinea'
import RubrosObra from '../../components/RubrosObra'

/* Los estados definen qué es Actual y qué es Committed. Es la distinción que
   no existe en la planilla, donde todo gasto cargado pesa igual. */
const STATUS = {
  estimado: ['Estimado', null],
  comprometido: ['Comprometido', 'warn'],
  recibido: ['Recibido', 'ok'],
  pagado: ['Pagado', 'ok'],
  anulado: ['Anulado', 'off'],
}

const num = new Intl.NumberFormat('es-AR', { minimumFractionDigits: 0, maximumFractionDigits: 2 })
const importe = (e) => `${num.format(e.qty * e.unit_price)} ${e.currency}`
const clasificacion = (e) => `${e.rubro?.name ?? 'Sin rubro'} · ${COST_TYPES[e.cost_type] ?? e.cost_type ?? '—'}`

/**
 * Gastos de la obra, agrupados por comprobante.
 *
 * Un comprobante es un papel; sus líneas son los gastos, cada una con su rubro
 * y su tipo de costo. Lo que no tiene comprobante (lo estimado, lo
 * comprometido, una orden de compra) va aparte.
 */
export default function Gastos({ projectId, encargo = false, onChange }) {
  const { canManage } = useAuth()
  /* null = cerrado · 'nuevo' = alta · un objeto = edición de ese gasto */
  const [abierto, setAbierto] = useState(null)
  const [comprobante, setComprobante] = useState(false)
  const [desglose, setDesglose] = useState(null)
  const [verRubros, setVerRubros] = useState(false)
  const [expandidos, setExpandidos] = useState(() => new Set())
  const [seleccion, setSeleccion] = useState(() => new Set())
  const [borrando, setBorrando] = useState(false)
  const [error, setError] = useState(null)

  const expenses = useAsync(() => listExpenses(projectId), [projectId])
  const receipts = useAsync(() => listReceipts(projectId), [projectId])

  function recargar() {
    expenses.reload()
    receipts.reload()
    onChange?.()
  }

  const gastos = expenses.data ?? []
  const porComprobante = new Map()
  for (const e of gastos) {
    if (!e.receipt_id) continue
    if (!porComprobante.has(e.receipt_id)) porComprobante.set(e.receipt_id, [])
    porComprobante.get(e.receipt_id).push(e)
  }
  const sueltos = gastos.filter((e) => !e.receipt_id)

  /* La selección se cruza con las filas actuales para que un gasto que ya no
     está no quede elegido. */
  const elegidos = gastos.filter((e) => seleccion.has(e.id))
  const todos = gastos.length > 0 && elegidos.length === gastos.length

  /* Elegir varios a la vez: agrega todos si falta alguno, si no los saca. */
  function alternarGastos(ids) {
    setSeleccion((s) => {
      const n = new Set(s)
      const estanTodos = ids.every((id) => n.has(id))
      for (const id of ids) {
        if (estanTodos) n.delete(id)
        else n.add(id)
      }
      return n
    })
  }

  function alternarTodos() {
    setSeleccion(todos ? new Set() : new Set(gastos.map((e) => e.id)))
  }

  async function borrar(lista) {
    if (!lista.length) return
    const aviso =
      lista.length === 1
        ? `¿Borrar el gasto "${lista[0].description}"?`
        : `¿Borrar ${lista.length} gastos?`
    if (
      !window.confirm(
        `${aviso} No se puede deshacer.\n\n` +
          'Si un comprobante se queda sin líneas, se borra también. ' +
          'Si tenían un pago registrado en Caja, ese movimiento no se borra: queda sin gasto asociado.'
      )
    )
      return

    setBorrando(true)
    setError(null)
    try {
      const ids = lista.map((e) => e.id)
      const borrados = await deleteExpenses(ids)
      /* Sin permiso de borrar, la base no siempre da error: puede devolver cero
         filas. Si no se borró lo pedido, hay que decirlo. */
      if ((borrados?.length ?? 0) < ids.length) {
        setError(
          'No se pudieron borrar todos los gastos. Falta aplicar en Supabase la migración ' +
            '0029_borrar_gastos.sql, o tu usuario no tiene permiso para borrar.'
        )
      }
      setSeleccion((s) => {
        const n = new Set(s)
        for (const id of ids) n.delete(id)
        return n
      })
      recargar()
    } catch (err) {
      setError(
        /permission denied/i.test(err.message)
          ? 'La base de datos todavía no permite borrar gastos: falta aplicar en Supabase la migración ' +
              `0029_borrar_gastos.sql. (Detalle: ${err.message})`
          : err.message
      )
    } finally {
      setBorrando(false)
    }
  }

  /* Casilla que marca un grupo de gastos: tildada si están todos, a medias si
     hay algunos. */
  function casilla(ids, etiqueta) {
    const marcados = ids.filter((id) => seleccion.has(id)).length
    return (
      <input
        type="checkbox"
        aria-label={etiqueta}
        disabled={!ids.length}
        checked={ids.length > 0 && marcados === ids.length}
        ref={(el) => { if (el) el.indeterminate = marcados > 0 && marcados < ids.length }}
        onChange={() => alternarGastos(ids)}
      />
    )
  }

  function alternar(id) {
    setExpandidos((s) => {
      const n = new Set(s)
      if (n.has(id)) n.delete(id)
      else n.add(id)
      return n
    })
  }

  async function verFoto(path) {
    try {
      window.open(await getReceiptPhotoUrl(path), '_blank', 'noopener')
    } catch (err) {
      setError(err.message)
    }
  }

  async function subirFoto(receiptId, file) {
    if (!file) return
    try {
      await uploadReceiptPhoto(projectId, receiptId, file)
      receipts.reload()
    } catch (err) {
      setError(`No se pudo subir la foto: ${err.message}`)
    }
  }

  function acciones(e) {
    if (!canManage) return null
    return (
      <>
        <button className="icon-btn" onClick={() => setDesglose(e)}>Desglose</button>
        <button className="icon-btn" onClick={() => setAbierto(e)}>Editar</button>
        <button className="icon-btn" onClick={() => borrar([e])} disabled={borrando}>Borrar</button>
      </>
    )
  }

  return (
    <div style={{ display: 'grid', gap: 16 }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', gap: 12, flexWrap: 'wrap' }}>
        <p style={{ margin: 0, color: 'var(--text-muted)', fontSize: '0.9375rem' }}>
          Recibido y pagado cuentan como <strong>Actual</strong>. Comprometido no: es plata
          reservada que todavía no es costo.
        </p>
        {canManage && (
          <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap' }}>
            <button className="btn" onClick={() => setVerRubros(true)}>Rubros</button>
            <button className="btn" onClick={() => setAbierto('nuevo')}>+ Gasto sin comprobante</button>
            <button className="btn btn-primary" onClick={() => setComprobante(true)}>+ Comprobante</button>
          </div>
        )}
      </div>

      {error && <ErrorBox message={error} />}
      {expenses.error && <ErrorBox message={expenses.error} />}
      {receipts.error && <ErrorBox message={receipts.error} />}

      {canManage && gastos.length > 0 && !expenses.loading && (
        <div
          style={{
            display: 'flex',
            alignItems: 'center',
            gap: 8,
            flexWrap: 'wrap',
            padding: '8px 12px',
            border: '1px solid var(--border)',
            borderRadius: 8,
            background: elegidos.length ? 'var(--accent-soft)' : undefined,
          }}
        >
          {elegidos.length === 0 ? (
            <button className="btn" onClick={alternarTodos}>
              Seleccionar todos ({gastos.length})
            </button>
          ) : (
            <>
              <strong>
                {elegidos.length === 1 ? '1 gasto seleccionado' : `${elegidos.length} gastos seleccionados`}
              </strong>
              <span style={{ color: 'var(--text-muted)' }}>
                · {usd(elegidos.reduce((a, e) => a + Number(e.amount_usd || 0), 0))}
              </span>
              <span style={{ flex: 1 }} />
              {!todos && (
                <button className="btn" onClick={alternarTodos}>
                  Seleccionar todos ({gastos.length})
                </button>
              )}
              <button className="btn" onClick={() => setSeleccion(new Set())} disabled={borrando}>
                Quitar selección
              </button>
              <button className="btn btn-primary" onClick={() => borrar(elegidos)} disabled={borrando}>
                {borrando ? 'Borrando…' : 'Borrar seleccionados'}
              </button>
            </>
          )}
        </div>
      )}

      {expenses.loading || receipts.loading ? (
        <Loading />
      ) : (
        <>
          <section style={{ display: 'grid', gap: 12 }}>
            <h2>Comprobantes</h2>
            <Table
              columns={[
                ...(canManage ? [{ key: 'sel', label: '', sort: false }] : []),
                { key: 'receipt_date', label: 'Fecha' },
                { key: 'proveedor', label: 'Proveedor' },
                { key: 'rubros', label: 'Rubros', sort: false },
                { key: 'total', label: 'Total', num: true },
                { key: 'total_usd', label: 'USD', num: true },
                { key: 'sin_asignar', label: 'Sin asignar', num: true },
                { key: 'foto', label: 'Foto', sort: false },
                { key: 'act', label: '', sort: false },
              ]}
              rows={receipts.data ?? []}
              empty="Todavía no hay comprobantes. Se cargan con «+ Comprobante» o desde Día a día."
              renderRow={(r) => {
                const lineas = porComprobante.get(r.receipt_id) ?? []
                const abiertoR = expandidos.has(r.receipt_id)
                const rubrosR = [...new Set(lineas.map((l) => l.rubro?.name ?? 'Sin rubro'))]
                return (
                  <Fragment key={r.receipt_id}>
                    <tr>
                      {canManage && (
                        <td>{casilla(lineas.map((l) => l.id), `Seleccionar las líneas del comprobante del ${date(r.receipt_date)}`)}</td>
                      )}
                      <td className="nowrap">{date(r.receipt_date)}</td>
                      <td>
                        {r.proveedor ?? '—'}
                        {r.number && <span style={{ color: 'var(--text-muted)' }}> · {r.number}</span>}
                      </td>
                      <td style={{ color: 'var(--text-muted)' }}>{rubrosR.join(', ') || '—'}</td>
                      <td className="num nowrap">{num.format(r.total)} {r.currency}</td>
                      <td className="num">{usd(r.total_usd)}</td>
                      <td className="num">
                        {Number(r.sin_asignar) > 0.009 ? (
                          <Badge tone="warn">{num.format(r.sin_asignar)}</Badge>
                        ) : (
                          <span style={{ color: 'var(--text-muted)' }}>—</span>
                        )}
                      </td>
                      <td className="nowrap">
                        {r.storage_path ? (
                          <button className="icon-btn" onClick={() => verFoto(r.storage_path)}>Ver</button>
                        ) : canManage ? (
                          <label className="icon-btn" style={{ cursor: 'pointer' }}>
                            Subir
                            <input
                              type="file"
                              accept="image/*,application/pdf"
                              capture="environment"
                              hidden
                              onChange={(e) => subirFoto(r.receipt_id, e.target.files?.[0])}
                            />
                          </label>
                        ) : (
                          '—'
                        )}
                      </td>
                      <td className="nowrap">
                        <button className="icon-btn" onClick={() => alternar(r.receipt_id)} aria-expanded={abiertoR}>
                          {abiertoR ? 'Ocultar' : `${lineas.length} ${lineas.length === 1 ? 'línea' : 'líneas'}`}
                        </button>
                      </td>
                    </tr>
                    {abiertoR &&
                      lineas.map((e) => (
                        <tr
                          key={e.id}
                          style={{
                            background: seleccion.has(e.id) ? 'var(--accent-soft)' : 'var(--surface-2)',
                            opacity: e.status === 'anulado' ? 0.5 : 1,
                          }}
                        >
                          {canManage && <td>{casilla([e.id], `Seleccionar ${e.description}`)}</td>}
                          <td />
                          <td colSpan={2}>
                            <strong style={{ fontWeight: 500 }}>{clasificacion(e)}</strong>
                            <span style={{ color: 'var(--text-muted)' }}> — {e.description}</span>
                          </td>
                          <td className="num nowrap">{importe(e)}</td>
                          <td className="num">{usd(e.amount_usd)}</td>
                          <td>
                            <Badge tone={STATUS[e.status]?.[1]}>{STATUS[e.status]?.[0] ?? e.status}</Badge>
                          </td>
                          <td colSpan={2} className="nowrap">{acciones(e)}</td>
                        </tr>
                      ))}
                  </Fragment>
                )
              }}
            />
          </section>

          <section style={{ display: 'grid', gap: 12 }}>
            <h2>Sin comprobante</h2>
            <Table
              columns={[
                ...(canManage
                  ? [{ key: 'sel', sort: false, label: casilla(sueltos.map((e) => e.id), 'Seleccionar todos los gastos sin comprobante') }]
                  : []),
                { key: 'expense_date', label: 'Fecha' },
                { key: 'description', label: 'Concepto' },
                { key: 'rubro', label: 'Rubro · tipo', sort: (e) => e.rubro?.name },
                { key: 'supplier_name', label: 'Proveedor' },
                { key: 'amount', label: 'Importe', num: true, sort: (e) => e.qty * e.unit_price },
                { key: 'amount_usd', label: 'USD', num: true },
                { key: 'status', label: 'Estado' },
                { key: 'act', label: '', sort: false },
              ]}
              rows={sueltos}
              empty="No hay gastos sin comprobante: todo lo cargado tiene su papel."
              renderRow={(e) => (
                <tr
                  key={e.id}
                  style={{
                    opacity: e.status === 'anulado' ? 0.5 : 1,
                    background: seleccion.has(e.id) ? 'var(--accent-soft)' : undefined,
                  }}
                >
                  {canManage && <td>{casilla([e.id], `Seleccionar ${e.description}`)}</td>}
                  <td className="nowrap">{date(e.expense_date)}</td>
                  <td>{e.description}</td>
                  <td style={{ color: 'var(--text-muted)' }}>{clasificacion(e)}</td>
                  <td>{e.supplier_name ?? '—'}</td>
                  <td className="num nowrap">{importe(e)}</td>
                  <td className="num">{usd(e.amount_usd)}</td>
                  <td>
                    <Badge tone={STATUS[e.status]?.[1]}>{STATUS[e.status]?.[0] ?? e.status}</Badge>
                  </td>
                  <td className="nowrap">{acciones(e)}</td>
                </tr>
              )}
            />
          </section>
        </>
      )}

      {abierto && (
        <GastoForm
          gasto={abierto === 'nuevo' ? null : abierto}
          projectId={projectId}
          encargo={encargo}
          onClose={() => setAbierto(null)}
          onSave={async (payload) => {
            if (abierto === 'nuevo') await createExpense({ ...payload, project_id: projectId })
            else await updateExpense(abierto.id, payload)
            recargar()
          }}
        />
      )}

      {comprobante && (
        <ComprobanteForm
          projectId={projectId}
          encargo={encargo}
          onClose={() => setComprobante(false)}
          onSaved={recargar}
        />
      )}

      {desglose && (
        <DesgloseLinea linea={desglose} onClose={() => setDesglose(null)} onSaved={recargar} />
      )}

      {verRubros && (
        <RubrosObra projectId={projectId} onClose={() => setVerRubros(false)} onChange={recargar} />
      )}
    </div>
  )
}
