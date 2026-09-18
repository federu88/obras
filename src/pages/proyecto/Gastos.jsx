import { useState } from 'react'
import { useAsync } from '../../lib/useAsync'
import { listExpenses, createExpense, updateExpense } from '../../lib/queries'
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

export default function Gastos({ projectId, onChange }) {
  const { canManage } = useAuth()
  /* null = cerrado · 'nuevo' = alta · un objeto = edición de ese gasto */
  const [abierto, setAbierto] = useState(null)

  const expenses = useAsync(() => listExpenses(projectId), [projectId])

  function recargar() {
    expenses.reload()
    onChange?.()
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

      {expenses.loading ? (
        <Loading />
      ) : (
        <Table
          columns={[
            { key: 'date', label: 'Fecha' },
            { key: 'desc', label: 'Concepto' },
            { key: 'cat', label: 'Categoría' },
            { key: 'sup', label: 'Proveedor' },
            { key: 'amount', label: 'Importe', num: true },
            { key: 'usd', label: 'USD', num: true },
            { key: 'status', label: 'Estado' },
            { key: 'act', label: '' },
          ]}
          rows={expenses.data ?? []}
          empty="Todavía no hay gastos cargados."
          renderRow={(e) => (
            <tr key={e.id} style={{ opacity: e.status === 'anulado' ? 0.5 : 1 }}>
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
                    {e.status !== 'anulado' && (
                      <button
                        className="icon-btn"
                        onClick={async () => {
                          await updateExpense(e.id, { status: 'anulado' })
                          recargar()
                        }}
                      >
                        Anular
                      </button>
                    )}
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
