import { useState } from 'react'
import { useAsync } from '../../lib/useAsync'
import { listExpenses, createExpense, updateExpense, deleteExpenses } from '../../lib/queries'
import { usd, date } from '../../lib/format'
import { useAuth } from '../../context/AuthContext'
import { Table, Loading, ErrorBox, Badge } from '../../components/ui'
import GastoForm from '../../components/GastoForm'

/* Los estados definen qué es Actual y qué es Committed. Es la distinción que
   no existe en la planilla, donde todo gasto cargado pesa igual. */
const STATUS = {
  estimado: ['Estimado', null],
  comprometido: ['Comprometido', 'warn'],
  recibido: ['Recibido', 'ok'],
  pagado: ['Pagado', 'ok'],
  anulado: ['Anulado', 'off'],
}

export default function Gastos({ projectId, encargo = false, onChange }) {
  const { canManage } = useAuth()
  /* null = cerrado · 'nuevo' = alta · un objeto = edición de ese gasto */
  const [abierto, setAbierto] = useState(null)
  const [seleccion, setSeleccion] = useState(() => new Set())
  const [borrando, setBorrando] = useState(false)
  const [borrarError, setBorrarError] = useState(null)

  const expenses = useAsync(() => listExpenses(projectId), [projectId])

  function recargar() {
    expenses.reload()
    onChange?.()
  }

  const rows = expenses.data ?? []

  /* La selección se cruza con las filas actuales para que un gasto que ya no
     está no quede elegido. */
  const elegidos = rows.filter((e) => seleccion.has(e.id))
  const todos = rows.length > 0 && elegidos.length === rows.length

  function alternarGasto(id) {
    setSeleccion((s) => {
      const n = new Set(s)
      if (n.has(id)) n.delete(id)
      else n.add(id)
      return n
    })
  }

  function alternarTodos() {
    setSeleccion(todos ? new Set() : new Set(rows.map((e) => e.id)))
  }

  async function borrar(gastos) {
    if (!gastos.length) return
    const aviso =
      gastos.length === 1
        ? `¿Borrar el gasto "${gastos[0].description}"?`
        : `¿Borrar ${gastos.length} gastos?`
    if (
      !window.confirm(
        `${aviso} No se puede deshacer.\n\n` +
          'Si tenían un pago registrado en Caja, ese movimiento no se borra: queda sin gasto asociado.'
      )
    )
      return

    setBorrando(true)
    setBorrarError(null)
    try {
      const ids = gastos.map((e) => e.id)
      const borrados = await deleteExpenses(ids)
      /* Sin permiso de borrar, la base no siempre da error: puede devolver cero
         filas. Si no se borró lo pedido, hay que decirlo. */
      if ((borrados?.length ?? 0) < ids.length) {
        setBorrarError(
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
      setBorrarError(
        /permission denied/i.test(err.message)
          ? 'La base de datos todavía no permite borrar gastos: falta aplicar en Supabase la migración 0029_borrar_gastos.sql.'
          : err.message
      )
    } finally {
      setBorrando(false)
    }
  }

  return (
    <div style={{ display: 'grid', gap: 16 }}>
      <div
        style={{
          display: 'flex',
          justifyContent: 'space-between',
          alignItems: 'center',
          gap: 12,
          flexWrap: 'wrap',
        }}
      >
        <p style={{ margin: 0, color: 'var(--text-muted)', fontSize: '0.9375rem' }}>
          Recibido y pagado cuentan como <strong>Actual</strong>. Comprometido no: es plata
          reservada que todavía no es costo.
        </p>
        {canManage && (
          <button className="btn btn-primary" onClick={() => setAbierto('nuevo')}>
            + Nuevo gasto
          </button>
        )}
      </div>

      {expenses.error && <ErrorBox message={expenses.error} />}

      {canManage && rows.length > 0 && !expenses.loading && (
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
              Seleccionar todos ({rows.length})
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
                  Seleccionar todos ({rows.length})
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

      {borrarError && <ErrorBox message={borrarError} />}

      {expenses.loading ? (
        <Loading />
      ) : (
        <Table
          columns={[
            ...(canManage
              ? [
                  {
                    key: 'sel',
                    sort: false,
                    label: (
                      <input
                        type="checkbox"
                        aria-label="Seleccionar todos los gastos"
                        checked={todos}
                        ref={(el) => { if (el) el.indeterminate = elegidos.length > 0 && !todos }}
                        onChange={alternarTodos}
                      />
                    ),
                  },
                ]
              : []),
            { key: 'expense_date', label: 'Fecha' },
            { key: 'description', label: 'Concepto' },
            { key: 'cat', label: 'Categoría', sort: (e) => e.category?.name },
            { key: 'supplier_name', label: 'Proveedor' },
            { key: 'amount', label: 'Importe', num: true, sort: (e) => e.qty * e.unit_price },
            { key: 'amount_usd', label: 'USD', num: true },
            { key: 'status', label: 'Estado' },
            { key: 'act', label: '', sort: false },
          ]}
          rows={rows}
          empty="Todavía no hay gastos cargados."
          renderRow={(e) => (
            <tr
              key={e.id}
              style={{
                opacity: e.status === 'anulado' ? 0.5 : 1,
                background: seleccion.has(e.id) ? 'var(--accent-soft)' : undefined,
              }}
            >
              {canManage && (
                <td>
                  <input
                    type="checkbox"
                    aria-label={`Seleccionar ${e.description}`}
                    checked={seleccion.has(e.id)}
                    onChange={() => alternarGasto(e.id)}
                  />
                </td>
              )}
              <td className="nowrap">{date(e.expense_date)}</td>
              <td>{e.description}</td>
              <td style={{ color: 'var(--text-muted)' }}>{e.category?.name ?? '—'}</td>
              <td>{e.supplier_name ?? '—'}</td>
              <td className="num">
                {new Intl.NumberFormat('es-AR').format(e.qty * e.unit_price)} {e.currency}
              </td>
              <td className="num">{usd(e.amount_usd)}</td>
              <td>
                <Badge tone={STATUS[e.status]?.[1]}>
                  {STATUS[e.status]?.[0] ?? e.status}
                </Badge>
              </td>
              <td className="nowrap">
                {canManage && (
                  <>
                    <button className="icon-btn" onClick={() => setAbierto(e)}>
                      Editar
                    </button>
                    <button className="icon-btn" onClick={() => borrar([e])} disabled={borrando}>
                      Borrar
                    </button>
                  </>
                )}
              </td>
            </tr>
          )}
        />
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
    </div>
  )
}
