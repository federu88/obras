import { useEffect, useState } from 'react'
import { useAsync } from '../lib/useAsync'
import {
  listProjects,
  listCashBalances,
  listCashAccounts,
  updateExpense,
  listGastosRecientes,
  getGastoMensual,
  registrarCambio,
} from '../lib/queries'
import { usd, ars, date } from '../lib/format'
import { useAuth } from '../context/AuthContext'
import { PageHead, Table, Loading, ErrorBox, Kpi, Drawer, Field } from '../components/ui'
import GastoForm from '../components/GastoForm'
import CargaRapida from '../components/CargaRapida'
import { COST_TYPES } from '../lib/costos'

const hoyIso = () => new Date().toISOString().slice(0, 10)

/**
 * Día a día de obra.
 *
 * Pensada para quien carga veinte gastos seguidos, no para quien consulta.
 * Por eso la carga está siempre abierta y se resuelve en cuatro toques
 * (rubro, tipo, monto, guardar), y al guardar conserva rubro, tipo y fecha:
 * lo único que cambia entre un gasto y el siguiente suele ser el importe.
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

  const obra = (projects.data ?? []).find((p) => p.id === projectId)
  const filas = gastos.data ?? []
  const hoy = hoyIso()
  const deHoy = filas.filter((x) => x.expense_date === hoy)
  const totalHoy = deHoy.reduce((a, x) => a + Number(x.amount_usd ?? 0), 0)
  const mesActual = (mensual.data ?? [])[0]

  const cajaArs = (balances.data ?? []).filter((b) => b.currency === 'ARS')
  const cajaUsd = (balances.data ?? []).filter((b) => b.currency === 'USD')
  const totalArs = cajaArs.reduce((a, b) => a + Number(b.balance ?? 0), 0)
  const totalUsd = cajaUsd.reduce((a, b) => a + Number(b.balance ?? 0), 0)

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
        <div style={{ display: 'grid', gap: 8 }}>
          <CargaRapida
            key={projectId}
            projectId={projectId}
            encargo={obra?.model === 'encargo'}
            onSaved={() => {
              gastos.reload()
              mensual.reload()
            }}
          />
          <button
            type="button"
            className="btn"
            style={{ justifySelf: 'start' }}
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
              { key: 'rubro', label: 'Rubro', sort: (x) => x.rubro?.name },
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
                <td style={{ color: 'var(--text-muted)' }}>
                  {x.rubro?.name ?? '—'}
                  {x.cost_type && <> · {COST_TYPES[x.cost_type] ?? x.cost_type}</>}
                </td>
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
