import { useAsync } from '../lib/useAsync'
import {
  listProjectHealth,
  listInvestorReport,
  listCashflowConsolidado,
  listPurchases,
  listScheduleAlerts,
} from '../lib/queries'
import { downloadCsv } from '../lib/csv'
import { usd } from '../lib/format'
import { PageHead, Loading, ErrorBox } from '../components/ui'

/**
 * Reportes exportables.
 *
 * Todos salen de las mismas vistas que alimentan las pantallas: un número en
 * un CSV no puede diferir del que se ve en el dashboard, porque viene de la
 * misma consulta.
 */
const REPORTES = [
  {
    key: 'proyectos',
    title: 'Estado de obras',
    detail: 'Budget, forecast, actual, profit proyectado y flags de costo y plazo.',
    load: listProjectHealth,
    columns: [
      { key: 'code', label: 'Código' },
      { key: 'name', label: 'Obra' },
      { key: 'status', label: 'Estado' },
      { key: 'budget_usd', label: 'Budget USD' },
      { key: 'forecast_cost_usd', label: 'Forecast USD' },
      { key: 'actual_cost_usd', label: 'Actual USD' },
      { key: 'committed_cost_usd', label: 'Comprometido USD' },
      { key: 'revenue_usd', label: 'Ingresos USD' },
      { key: 'forecast_profit_usd', label: 'Profit proyectado USD' },
      { key: 'desvio_costo_rel', label: 'Desvío costo' },
      { key: 'avance_real', label: 'Avance real' },
      { key: 'problema_costo', label: 'Problema costo' },
      { key: 'problema_plazo', label: 'Problema plazo' },
    ],
  },
  {
    key: 'inversores',
    title: 'Posición de inversores',
    detail: 'Capital, participación y profit de cada inversor en cada obra.',
    load: () => listInvestorReport(),
    columns: [
      { key: 'investor_name', label: 'Inversor' },
      { key: 'code', label: 'Obra' },
      { key: 'project_name', label: 'Nombre obra' },
      { key: 'project_status', label: 'Estado obra' },
      { key: 'capital_invertido_usd', label: 'Capital USD' },
      { key: 'participacion', label: 'Participación' },
      { key: 'profit_pendiente_usd', label: 'Profit pendiente USD' },
      { key: 'profit_cobrado_usd', label: 'Profit cobrado USD' },
      { key: 'profit_proyectado_usd', label: 'Profit proyectado USD' },
    ],
  },
  {
    key: 'cashflow',
    title: 'Cashflow consolidado',
    detail: 'Entradas, salidas y saldo acumulado por mes, realizado y proyectado.',
    load: listCashflowConsolidado,
    columns: [
      { key: 'month', label: 'Mes' },
      { key: 'inflows', label: 'Entradas USD' },
      { key: 'outflows', label: 'Salidas USD' },
      { key: 'net', label: 'Neto USD' },
      { key: 'net_realizado', label: 'Realizado USD' },
      { key: 'net_proyectado', label: 'Proyectado USD' },
      { key: 'closing_balance', label: 'Saldo USD' },
    ],
  },
  {
    key: 'compras',
    title: 'Órdenes de compra',
    detail: 'Todas las compras con item, proveedor, obra y estado.',
    load: listPurchases,
    flatten: (r) => ({
      expense_date: r.expense_date,
      item: r.item?.code,
      description: r.description,
      supplier: r.supplier?.name,
      project: r.project?.code,
      qty: r.qty,
      unit: r.item?.unit,
      unit_price: r.unit_price,
      currency: r.currency,
      amount_usd: r.amount_usd,
      purchase_stage: r.purchase_stage,
      status: r.status,
    }),
    columns: [
      { key: 'expense_date', label: 'Fecha' },
      { key: 'item', label: 'Item' },
      { key: 'description', label: 'Concepto' },
      { key: 'supplier', label: 'Proveedor' },
      { key: 'project', label: 'Obra' },
      { key: 'qty', label: 'Cantidad' },
      { key: 'unit', label: 'Unidad' },
      { key: 'unit_price', label: 'Precio unitario' },
      { key: 'currency', label: 'Moneda' },
      { key: 'amount_usd', label: 'Total USD' },
      { key: 'purchase_stage', label: 'Estado compra' },
      { key: 'status', label: 'Estado financiero' },
    ],
  },
  {
    key: 'cronograma',
    title: 'Desvíos de cronograma',
    detail: 'Actividades atrasadas, bloqueadas o terminadas fuera de plazo.',
    load: () => listScheduleAlerts(),
    columns: [
      { key: 'code', label: 'Obra' },
      { key: 'name', label: 'Actividad' },
      { key: 'alerta', label: 'Problema' },
      { key: 'planned_start', label: 'Inicio plan' },
      { key: 'planned_finish', label: 'Fin plan' },
      { key: 'actual_finish', label: 'Fin real' },
      { key: 'delay_days', label: 'Atraso (días)' },
    ],
  },
]

function Reporte({ def }) {
  const data = useAsync(def.load)
  const rows = data.data ?? []
  const n = rows.length

  function exportar() {
    const flat = def.flatten ? rows.map(def.flatten) : rows
    downloadCsv(def.key, def.columns, flat)
  }

  return (
    <div className="card" style={{ display: 'grid', gap: 10 }}>
      <div>
        <h2 style={{ fontSize: '1rem' }}>{def.title}</h2>
        <p style={{ margin: '4px 0 0', color: 'var(--text-muted)', fontSize: '0.875rem' }}>
          {def.detail}
        </p>
      </div>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', gap: 12 }}>
        <span style={{ color: 'var(--text-muted)', fontSize: '0.8125rem' }}>
          {data.loading ? 'Cargando…' : data.error ? 'Error' : `${n} ${n === 1 ? 'fila' : 'filas'}`}
        </span>
        <button className="btn" onClick={exportar} disabled={data.loading || n === 0}>
          Exportar CSV
        </button>
      </div>
      {data.error && <ErrorBox message={data.error} />}
    </div>
  )
}

export default function Reportes() {
  return (
    <div style={{ display: 'grid', gap: 20 }}>
      <PageHead
        title="Reportes"
        subtitle="Exportables en CSV, separados por punto y coma para que Excel en español los abra directo."
      />

      <div
        style={{
          display: 'grid',
          gap: 12,
          gridTemplateColumns: 'repeat(auto-fill, minmax(320px, 1fr))',
        }}
      >
        {REPORTES.map((def) => (
          <Reporte key={def.key} def={def} />
        ))}
      </div>

      <p style={{ margin: 0, color: 'var(--text-muted)', fontSize: '0.8125rem' }}>
        Todos los reportes salen de las mismas vistas que alimentan las pantallas. Un
        número en un CSV no puede diferir del que ves en el dashboard, porque viene de la
        misma consulta.
      </p>
    </div>
  )
}
