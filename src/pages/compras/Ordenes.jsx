import { Link } from 'react-router-dom'
import { useAsync } from '../../lib/useAsync'
import { listPurchases, updatePurchaseStage } from '../../lib/queries'
import { usd, date } from '../../lib/format'
import { useAuth } from '../../context/AuthContext'
import { PageHead, Table, Loading, ErrorBox, Badge } from '../../components/ui'

/* El stage es el flujo operativo. El status financiero se deriva de él en la
   base, con un trigger, así nunca pueden contradecirse. */
const STAGES = {
  solicitada: ['Solicitada', null, 'no es costo'],
  cotizada: ['Cotizada', null, 'no es costo'],
  aprobada: ['Aprobada', 'warn', 'comprometido'],
  comprada: ['Comprada', 'warn', 'comprometido'],
  recibida: ['Recibida', 'ok', 'actual'],
  pagada: ['Pagada', 'ok', 'actual'],
}

const ORDEN = Object.keys(STAGES)

export default function Ordenes() {
  const { canManage } = useAuth()
  const purchases = useAsync(listPurchases)

  async function avanzar(p) {
    const i = ORDEN.indexOf(p.purchase_stage)
    const next = ORDEN[i + 1]
    if (!next) return
    await updatePurchaseStage(p.id, next)
    purchases.reload()
  }

  const rows = purchases.data ?? []
  const comprometido = rows
    .filter((p) => ['aprobada', 'comprada'].includes(p.purchase_stage))
    .reduce((a, p) => a + Number(p.amount_usd ?? 0), 0)
  const actual = rows
    .filter((p) => ['recibida', 'pagada'].includes(p.purchase_stage))
    .reduce((a, p) => a + Number(p.amount_usd ?? 0), 0)

  return (
    <div>
      <PageHead
        title="Compras"
        subtitle="Una compra es un gasto: se carga desde la pestaña Gastos del proyecto, vinculada a un item y un proveedor."
      />

      {purchases.error && <ErrorBox message={purchases.error} />}

      {purchases.loading ? (
        <Loading />
      ) : (
        <>
          <div style={{ display: 'flex', gap: 24, marginBottom: 18, flexWrap: 'wrap' }}>
            <div>
              <div style={{ fontSize: '0.8125rem', color: 'var(--text-muted)' }}>Comprometido</div>
              <div className="num" style={{ fontSize: '1.25rem', fontWeight: 600, textAlign: 'left' }}>
                {usd(comprometido)}
              </div>
            </div>
            <div>
              <div style={{ fontSize: '0.8125rem', color: 'var(--text-muted)' }}>Actual</div>
              <div className="num" style={{ fontSize: '1.25rem', fontWeight: 600, textAlign: 'left' }}>
                {usd(actual)}
              </div>
            </div>
          </div>

          <Table
            columns={[
              { key: 'date', label: 'Fecha' },
              { key: 'item', label: 'Item' },
              { key: 'sup', label: 'Proveedor' },
              { key: 'proj', label: 'Obra' },
              { key: 'qty', label: 'Cant.', num: true },
              { key: 'usd', label: 'USD', num: true },
              { key: 'stage', label: 'Estado' },
              { key: 'act', label: '' },
            ]}
            rows={rows}
            empty="Todavía no hay compras. Cargá un gasto con item y proveedor desde el proyecto."
            renderRow={(p) => {
              const [label, tone, efecto] = STAGES[p.purchase_stage] ?? [p.purchase_stage, null, '']
              const siguiente = ORDEN[ORDEN.indexOf(p.purchase_stage) + 1]
              return (
                <tr key={p.id}>
                  <td>{date(p.expense_date)}</td>
                  <td><strong>{p.item?.code}</strong> {p.item?.description}</td>
                  <td>{p.supplier?.name ?? '—'}</td>
                  <td>
                    {p.project && (
                      <Link to={`/proyectos/${p.project.id}`} style={{ color: 'var(--accent)' }}>
                        {p.project.code}
                      </Link>
                    )}
                  </td>
                  <td className="num">{p.qty} {p.item?.unit}</td>
                  <td className="num">{usd(p.amount_usd)}</td>
                  <td>
                    <Badge tone={tone}>{label}</Badge>
                    <div style={{ fontSize: '0.6875rem', color: 'var(--text-muted)', marginTop: 2 }}>
                      {efecto}
                    </div>
                  </td>
                  <td>
                    {canManage && siguiente && (
                      <button className="icon-btn" onClick={() => avanzar(p)}>
                        → {STAGES[siguiente][0]}
                      </button>
                    )}
                  </td>
                </tr>
              )
            }}
          />

          <p style={{ marginTop: 14, color: 'var(--text-muted)', fontSize: '0.8125rem' }}>
            Solicitada y cotizada no son costo. Aprobada y comprada cuentan como
            comprometido. Recibida y pagada son costo real. El estado financiero lo
            calcula la base a partir del estado de compra, no se carga aparte.
          </p>
        </>
      )}
    </div>
  )
}
