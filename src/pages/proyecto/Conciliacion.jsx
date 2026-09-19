import { useState } from 'react'
import { useAsync } from '../../lib/useAsync'
import { listReconciliation, listReferences, createReference } from '../../lib/queries'
import { usd, pct, date } from '../../lib/format'
import { useAuth } from '../../context/AuthContext'
import { Table, Loading, ErrorBox, Badge, Drawer, Field, Kpi } from '../../components/ui'

/**
 * Conciliación: lo que dicen las planillas contra lo que está cargado.
 *
 * Mientras conviven los Excel informales y el sistema, nadie sabe cuál de los
 * dos tiene razón. Esta pantalla no lo resuelve: lo muestra. La diferencia deja
 * de ser una discusión y pasa a ser un número que se achica a medida que se
 * carga lo que falta.
 */

const CONCEPTOS = {
  capital_aportado: 'Capital aportado',
  costo_total: 'Costo de la obra',
  venta: 'Venta',
  utilidad: 'Utilidad',
}

const ESTADOS = {
  ok: ['Coincide', 'ok'],
  menor: ['Diferencia menor', 'warn'],
  revisar: ['Revisar', 'off'],
  sin_referencia: ['Sin referencia', null],
}

const VACIO = {
  concepto: 'costo_total',
  valor_usd: '',
  fuente: '',
  reference_date: new Date().toISOString().slice(0, 10),
  note: '',
}

export default function Conciliacion({ projectId }) {
  const { canManage } = useAuth()
  const [abierto, setAbierto] = useState(false)
  const [form, setForm] = useState(VACIO)
  const [saving, setSaving] = useState(false)
  const [error, setError] = useState(null)

  const filas = useAsync(() => listReconciliation(projectId), [projectId])
  const refs = useAsync(() => listReferences(projectId), [projectId])

  const set = (k) => (e) => setForm((f) => ({ ...f, [k]: e.target.value }))

  async function guardar() {
    setSaving(true)
    setError(null)
    try {
      await createReference({
        project_id: projectId,
        concepto: form.concepto,
        valor_usd: Number(form.valor_usd),
        fuente: form.fuente,
        reference_date: form.reference_date,
        note: form.note || null,
      })
      setForm(VACIO)
      setAbierto(false)
      filas.reload()
      refs.reload()
    } catch (err) {
      setError(err.message)
    } finally {
      setSaving(false)
    }
  }

  const datos = filas.data ?? []
  const aRevisar = datos.filter((f) => f.estado === 'revisar')
  const costo = datos.find((f) => f.concepto === 'costo_total')

  return (
    <div style={{ display: 'grid', gap: 20 }}>
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
          Lo que dicen las planillas contra lo que está cargado en el sistema.
        </p>
        {canManage && (
          <button className="btn btn-primary" onClick={() => setAbierto(true)}>
            + Valor de referencia
          </button>
        )}
      </div>

      {filas.error && <ErrorBox message={filas.error} />}

      {filas.loading ? (
        <Loading />
      ) : (
        <>
          {costo && costo.diferencia_usd > 0 && (
            <div className="notice notice-warning">
              <strong>Falta cargar {usd(costo.diferencia_usd)} de gastos.</strong> La
              planilla dice que la obra costó {usd(costo.referencia_usd)} y en el sistema
              hay {usd(costo.cargado_usd)}. A medida que se carguen los gastos que faltan,
              esta diferencia se va a achicar sola.
            </div>
          )}

          {costo && costo.diferencia_usd < -1 && (
            <div className="notice notice-error">
              <strong>Hay {usd(Math.abs(costo.diferencia_usd))} cargados de más.</strong> El
              sistema tiene más gastos que los que declara la planilla. Puede haber un
              gasto duplicado, o la planilla estar desactualizada.
            </div>
          )}

          <div className="kpi-grid">
            {datos.map((f) => (
              <Kpi
                key={f.concepto}
                label={CONCEPTOS[f.concepto] ?? f.concepto}
                value={usd(f.cargado_usd)}
                hint={
                  f.referencia_usd == null
                    ? 'sin referencia cargada'
                    : `planilla: ${usd(f.referencia_usd)}`
                }
              />
            ))}
          </div>

          <Table
            columns={[
              { key: 'concepto', label: 'Concepto' },
              { key: 'referencia_usd', label: 'Según la planilla', num: true },
              { key: 'cargado_usd', label: 'En el sistema', num: true },
              { key: 'diferencia_usd', label: 'Diferencia', num: true },
              { key: 'diferencia_rel', label: '%', num: true },
              { key: 'estado', label: 'Estado' },
              { key: 'fuente', label: 'Fuente' },
            ]}
            rows={datos}
            empty="Todavía no hay conceptos para conciliar."
            renderRow={(f) => {
              const [label, tone] = ESTADOS[f.estado] ?? [f.estado, null]
              return (
                <tr key={f.concepto}>
                  <td style={{ fontWeight: 500 }}>{CONCEPTOS[f.concepto] ?? f.concepto}</td>
                  <td className="num">{usd(f.referencia_usd)}</td>
                  <td className="num">{usd(f.cargado_usd)}</td>
                  <td
                    className={`num ${
                      f.diferencia_usd == null || Math.abs(f.diferencia_usd) < 1
                        ? ''
                        : 'var-neg'
                    }`}
                  >
                    {f.diferencia_usd == null ? '—' : usd(f.diferencia_usd)}
                  </td>
                  <td className="num">
                    {f.diferencia_rel == null ? '—' : pct(f.diferencia_rel)}
                  </td>
                  <td><Badge tone={tone}>{label}</Badge></td>
                  <td style={{ color: 'var(--text-muted)' }}>{f.fuente ?? '—'}</td>
                </tr>
              )
            }}
          />

          <p style={{ margin: 0, color: 'var(--text-muted)', fontSize: '0.8125rem' }}>
            Una diferencia no quiere decir que algo esté mal: casi siempre quiere decir
            que falta cargar gastos. <strong>Coincide</strong> es menos de un dólar de
            diferencia; <strong>diferencia menor</strong> es hasta 1% o USD 50.
          </p>

          {aRevisar.length === 0 && datos.some((f) => f.referencia_usd != null) && (
            <div className="notice">
              <strong>Todo cuadra.</strong> Los valores cargados coinciden con la planilla
              en todos los conceptos que tienen referencia.
            </div>
          )}
        </>
      )}

      <section style={{ display: 'grid', gap: 12 }}>
        <h2>Referencias cargadas</h2>
        <p style={{ margin: 0, color: 'var(--text-muted)', fontSize: '0.875rem' }}>
          Una referencia no se corrige: se carga una nueva con fecha posterior. Las
          viejas quedan como historia de cómo fue cambiando el número oficial.
        </p>
        {refs.loading ? (
          <Loading />
        ) : (
          <Table
            columns={[
              { key: 'reference_date', label: 'Fecha' },
              { key: 'concepto', label: 'Concepto' },
              { key: 'valor_usd', label: 'Valor', num: true },
              { key: 'fuente', label: 'Fuente' },
              { key: 'note', label: 'Detalle' },
            ]}
            rows={refs.data ?? []}
            empty="Todavía no hay valores de referencia cargados."
            renderRow={(r) => (
              <tr key={r.id}>
                <td className="nowrap">{date(r.reference_date)}</td>
                <td>{CONCEPTOS[r.concepto] ?? r.concepto}</td>
                <td className="num">{usd(r.valor_usd)}</td>
                <td>{r.fuente}</td>
                <td style={{ color: 'var(--text-muted)' }}>{r.note ?? '—'}</td>
              </tr>
            )}
          />
        )}
      </section>

      {abierto && (
        <Drawer
          title="Valor de referencia"
          submitLabel="Guardar"
          onClose={() => setAbierto(false)}
          onSubmit={guardar}
          submitting={saving}
        >
          {error && <ErrorBox message={error} />}

          <div className="notice">
            Cargá acá lo que dice la planilla. El sistema lo compara contra lo que tiene
            cargado y muestra la diferencia.
          </div>

          <Field label="Concepto">
            <select value={form.concepto} onChange={set('concepto')}>
              {Object.entries(CONCEPTOS).map(([k, l]) => (
                <option key={k} value={k}>{l}</option>
              ))}
            </select>
          </Field>

          <Field label="Valor según la planilla (USD)">
            <input
              type="number"
              step="0.01"
              required
              value={form.valor_usd}
              onChange={set('valor_usd')}
            />
          </Field>

          <Field label="Fuente" hint="De qué archivo salió. Ej: REPARTO UTILIDAD CASAS SR084.xlsx">
            <input required value={form.fuente} onChange={set('fuente')} />
          </Field>

          <Field label="Fecha de la referencia" hint="A qué momento corresponde ese número.">
            <input type="date" required value={form.reference_date} onChange={set('reference_date')} />
          </Field>

          <Field label="Detalle">
            <input value={form.note} onChange={set('note')} />
          </Field>
        </Drawer>
      )}
    </div>
  )
}
