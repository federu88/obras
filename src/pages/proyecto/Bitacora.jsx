import { useState } from 'react'
import { useAsync } from '../../lib/useAsync'
import {
  listProjectLog,
  createLogEntry,
  updateLogEntry,
  deleteLogEntry,
} from '../../lib/queries'
import { date } from '../../lib/format'
import { useAuth } from '../../context/AuthContext'
import { Table, Loading, ErrorBox, Badge, Drawer, Field } from '../../components/ui'

/**
 * Bitácora de la obra.
 *
 * Pedidos, decisiones, aprobaciones, visitas y reclamos, con fecha y autor. Es
 * lo que convierte "yo te dije en marzo" en un registro que se puede leer en
 * noviembre.
 *
 * La marca "con el cliente" separa la comunicación de la nota interna. Una nota
 * interna nunca sale en un reporte: es la misma regla que el margen.
 */

const KINDS = {
  pedido: 'Pedido',
  decision: 'Decisión',
  aprobacion: 'Aprobación',
  visita: 'Visita de obra',
  reclamo: 'Reclamo',
  pago: 'Pago',
  otro: 'Otro',
}

const VACIO = {
  log_date: new Date().toISOString().slice(0, 10),
  kind: 'pedido',
  summary: '',
  detail: '',
  with_client: 'true',
}

export default function Bitacora({ projectId }) {
  const { canManage } = useAuth()
  const [abierto, setAbierto] = useState(null)
  const [form, setForm] = useState(VACIO)
  const [saving, setSaving] = useState(false)
  const [error, setError] = useState(null)
  const [soloCliente, setSoloCliente] = useState(false)

  const log = useAsync(() => listProjectLog(projectId), [projectId])
  const set = (k) => (e) => setForm((f) => ({ ...f, [k]: e.target.value }))

  function abrir(fila = null) {
    setError(null)
    setForm(
      fila
        ? {
            log_date: fila.log_date,
            kind: fila.kind,
            summary: fila.summary,
            detail: fila.detail ?? '',
            with_client: fila.with_client ? 'true' : 'false',
          }
        : VACIO
    )
    setAbierto(fila ?? 'nuevo')
  }

  async function guardar() {
    setSaving(true)
    setError(null)
    try {
      const payload = {
        log_date: form.log_date,
        kind: form.kind,
        summary: form.summary,
        detail: form.detail || null,
        with_client: form.with_client === 'true',
      }
      if (abierto === 'nuevo') await createLogEntry({ ...payload, project_id: projectId })
      else await updateLogEntry(abierto.id, payload)
      setAbierto(null)
      log.reload()
    } catch (err) {
      setError(err.message)
    } finally {
      setSaving(false)
    }
  }

  async function borrar() {
    setSaving(true)
    try {
      await deleteLogEntry(abierto.id)
      setAbierto(null)
      log.reload()
    } catch (err) {
      setError(err.message)
    } finally {
      setSaving(false)
    }
  }

  const todas = log.data ?? []
  const filas = soloCliente ? todas.filter((l) => l.with_client) : todas
  const internas = todas.length - todas.filter((l) => l.with_client).length

  return (
    <div style={{ display: 'grid', gap: 16 }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', gap: 12, flexWrap: 'wrap' }}>
        <p style={{ margin: 0, color: 'var(--text-muted)', fontSize: '0.9375rem' }}>
          Lo que se habló, se pidió y se decidió, con fecha.
        </p>
        <div style={{ display: 'flex', gap: 8, alignItems: 'center', flexWrap: 'wrap' }}>
          {internas > 0 && (
            <label style={{ fontSize: '0.875rem', display: 'flex', gap: 6, alignItems: 'center' }}>
              <input
                type="checkbox"
                checked={soloCliente}
                onChange={(e) => setSoloCliente(e.target.checked)}
              />
              Ver solo lo del cliente
            </label>
          )}
          {canManage && (
            <button className="btn btn-primary" onClick={() => abrir()}>+ Entrada</button>
          )}
        </div>
      </div>

      {log.error && <ErrorBox message={log.error} />}

      {log.loading ? (
        <Loading />
      ) : (
        <Table
          columns={[
            { key: 'log_date', label: 'Fecha' },
            { key: 'kind', label: 'Tipo' },
            { key: 'summary', label: 'Qué pasó' },
            { key: 'with_client', label: 'Ámbito' },
            { key: 'act', label: '', sort: false },
          ]}
          rows={filas}
          empty="Todavía no hay nada anotado."
          renderRow={(l) => (
            <tr key={l.id}>
              <td className="nowrap">{date(l.log_date)}</td>
              <td style={{ color: 'var(--text-muted)' }}>{KINDS[l.kind] ?? l.kind}</td>
              <td>
                <div style={{ fontWeight: 500 }}>{l.summary}</div>
                {l.detail && (
                  <div style={{ color: 'var(--text-muted)', fontSize: '0.8125rem' }}>{l.detail}</div>
                )}
              </td>
              <td>
                <Badge tone={l.with_client ? null : 'off'}>
                  {l.with_client ? 'Con el cliente' : 'Interna'}
                </Badge>
              </td>
              <td className="nowrap">
                {canManage && (
                  <button className="icon-btn" onClick={() => abrir(l)}>Editar</button>
                )}
              </td>
            </tr>
          )}
        />
      )}

      {abierto && (
        <Drawer
          title={abierto === 'nuevo' ? 'Nueva entrada' : 'Editar entrada'}
          submitLabel={abierto === 'nuevo' ? 'Guardar' : 'Guardar cambios'}
          onClose={() => setAbierto(null)}
          onSubmit={guardar}
          submitting={saving}
          onDelete={abierto !== 'nuevo' ? borrar : undefined}
          deleteLabel="Eliminar entrada"
        >
          {error && <ErrorBox message={error} />}

          <Field label="Fecha">
            <input type="date" required value={form.log_date} onChange={set('log_date')} />
          </Field>

          <Field label="Tipo">
            <select value={form.kind} onChange={set('kind')}>
              {Object.entries(KINDS).map(([k, v]) => (
                <option key={k} value={k}>{v}</option>
              ))}
            </select>
          </Field>

          <Field label="Qué pasó" hint="Una línea. El detalle va abajo.">
            <input required value={form.summary} onChange={set('summary')} />
          </Field>

          <Field label="Detalle">
            <textarea rows="4" value={form.detail} onChange={set('detail')} />
          </Field>

          <Field
            label="Ámbito"
            hint="Una nota interna no aparece en ningún reporte que se le mande al cliente."
          >
            <select value={form.with_client} onChange={set('with_client')}>
              <option value="true">Comunicación con el cliente</option>
              <option value="false">Nota interna</option>
            </select>
          </Field>
        </Drawer>
      )}
    </div>
  )
}
