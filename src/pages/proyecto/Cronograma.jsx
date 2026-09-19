import { useState } from 'react'
import { useAsync } from '../../lib/useAsync'
import {
  listTasks,
  createTask,
  updateTask,
  deleteTask,
  getProjectProgress,
  listScheduleAlerts,
  listDependencyImpact,
  aplicarPlantillaObra,
} from '../../lib/queries'
import { pct, date } from '../../lib/format'
import { useAuth } from '../../context/AuthContext'
import { Table, Loading, ErrorBox, Badge, Drawer, Field } from '../../components/ui'

const STATUS = {
  no_iniciada: ['No iniciada', null],
  en_curso: ['En curso', 'warn'],
  terminada: ['Terminada', 'ok'],
  demorada: ['Demorada', 'off'],
  bloqueada: ['Bloqueada', 'off'],
}

const ALERTAS = {
  atrasada: 'Atrasada',
  deberia_haber_empezado: 'Debía haber empezado',
  terminada_fuera_de_plazo: 'Terminada fuera de plazo',
  bloqueada: 'Bloqueada',
}

const EMPTY = {
  category: '',
  name: '',
  planned_start: '',
  planned_days: '',
  actual_start: '',
  actual_finish: '',
  responsible: '',
}

const DAY = 86400000
const d = (s) => (s ? new Date(s + 'T00:00:00').getTime() : null)

/** Barras posicionadas en porcentaje sobre la ventana total del proyecto. */
function Gantt({ tasks }) {
  const fechas = tasks
    .flatMap((t) => [t.planned_start, t.planned_finish, t.actual_start, t.actual_finish])
    .filter(Boolean)
    .map(d)
  if (!fechas.length) return null

  const min = Math.min(...fechas)
  const max = Math.max(...fechas, Date.now())
  const span = Math.max(max - min, DAY)
  const posc = (t) => ((t - min) / span) * 100
  const hoy = posc(Date.now())

  /* Marcas de mes a lo largo de la ventana. */
  const meses = []
  const cur = new Date(min)
  cur.setDate(1)
  while (cur.getTime() <= max) {
    meses.push(new Date(cur))
    cur.setMonth(cur.getMonth() + 1)
  }

  return (
    <div className="gantt">
      <div className="gantt-row gantt-head">
        <div className="gantt-label">Actividad</div>
        <div className="gantt-scale">
          {meses.map((m) => (
            <span key={m.getTime()}>
              {m.toLocaleDateString('es-AR', { month: 'short' })}
            </span>
          ))}
        </div>
      </div>

      {tasks.map((t) => {
        const ps = d(t.planned_start)
        const pf = d(t.planned_finish)
        const as = d(t.actual_start)
        const af = d(t.actual_finish) ?? (as ? Date.now() : null)

        return (
          <div className="gantt-row" key={t.task_id}>
            <div className="gantt-label" title={t.name}>
              {t.name}
            </div>
            <div className="gantt-track">
              <div className="gantt-today" style={{ left: `${hoy}%` }} />
              {ps != null && pf != null && (
                <div
                  className="gantt-bar plan"
                  style={{ left: `${posc(ps)}%`, width: `${Math.max(posc(pf) - posc(ps), 0.6)}%` }}
                  title={`Plan: ${date(t.planned_start)} → ${date(t.planned_finish)}`}
                />
              )}
              {as != null && af != null && (
                <div
                  className={`gantt-bar real${
                    t.status === 'terminada' ? ' done' : t.is_late ? ' late' : ''
                  }`}
                  style={{ left: `${posc(as)}%`, width: `${Math.max(posc(af) - posc(as), 0.6)}%` }}
                  title={`Real: ${date(t.actual_start)} → ${
                    t.actual_finish ? date(t.actual_finish) : 'en curso'
                  }`}
                />
              )}
            </div>
          </div>
        )
      })}
    </div>
  )
}

export default function Cronograma({ projectId }) {
  const { canManage } = useAuth()
  const [abierto, setAbierto] = useState(null)
  const [form, setForm] = useState(EMPTY)
  const [saving, setSaving] = useState(false)
  const [formError, setFormError] = useState(null)
  /* Alta masiva desde la plantilla de etapas del catálogo. */
  const [plantilla, setPlantilla] = useState(null)
  const [inicio, setInicio] = useState(new Date().toISOString().slice(0, 10))

  const tasks = useAsync(() => listTasks(projectId), [projectId])
  const progress = useAsync(() => getProjectProgress(projectId), [projectId])
  const alerts = useAsync(() => listScheduleAlerts(projectId), [projectId])
  const impact = useAsync(() => listDependencyImpact(projectId), [projectId])

  const set = (k) => (e) => setForm((f) => ({ ...f, [k]: e.target.value }))

  function reload() {
    tasks.reload()
    progress.reload()
    alerts.reload()
    impact.reload()
  }

  async function save() {
    setSaving(true)
    setFormError(null)
    try {
      const payload = {
        category: form.category || null,
        name: form.name,
        planned_start: form.planned_start || null,
        planned_days: form.planned_days ? Number(form.planned_days) : null,
        actual_start: form.actual_start || null,
        actual_finish: form.actual_finish || null,
        responsible: form.responsible || null,
      }
      if (abierto === 'nuevo') {
        await createTask({
          ...payload,
          project_id: projectId,
          sort_order: (tasks.data?.length ?? 0) + 1,
        })
      } else {
        await updateTask(abierto.task_id, payload)
      }
      setForm(EMPTY)
      setAbierto(null)
      reload()
    } catch (err) {
      setFormError(err.message)
    } finally {
      setSaving(false)
    }
  }

  async function marcar(t, patch) {
    await updateTask(t.task_id, patch)
    reload()
  }

  /**
   * Genera el cronograma entero desde la plantilla de etapas.
   *
   * Las fechas las calcula la base, no el navegador: es la misma función de días
   * hábiles que usa el resto del sistema, con los feriados argentinos cargados.
   */
  async function aplicarPlantilla() {
    setSaving(true)
    setFormError(null)
    try {
      await aplicarPlantillaObra(projectId, inicio)
      setPlantilla(null)
      reload()
    } catch (err) {
      setFormError(err.message)
    } finally {
      setSaving(false)
    }
  }

  const rows = tasks.data ?? []
  const p = progress.data ?? {}
  const hoy = new Date().toISOString().slice(0, 10)

  return (
    <div style={{ display: 'grid', gap: 24 }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', gap: 12, flexWrap: 'wrap' }}>
        <p style={{ margin: 0, color: 'var(--text-muted)', fontSize: '0.9375rem' }}>
          Días hábiles con feriados argentinos. El fin planificado se calcula solo.
        </p>
        {canManage && (
          <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap' }}>
            <button
              className="btn"
              onClick={() => { setFormError(null); setPlantilla(true) }}
            >
              Cargar etapas estándar
            </button>
            <button className="btn btn-primary" onClick={() => { setForm(EMPTY); setAbierto('nuevo') }}>+ Actividad</button>
          </div>
        )}
      </div>

      {canManage && rows.length === 0 && !tasks.loading && (
        <div className="notice">
          Esta obra todavía no tiene cronograma. <strong>Cargar etapas estándar</strong>{' '}
          genera las 50 etapas de una casa con sus fechas ya calculadas, a partir de la
          fecha en que arranca la obra. Después se ajusta lo que haga falta.
        </div>
      )}

      {(tasks.error || progress.error) && <ErrorBox message={tasks.error || progress.error} />}

      {tasks.loading ? (
        <Loading />
      ) : (
        <>
          {rows.length > 0 && (
            <section className="card" style={{ display: 'grid', gap: 12 }}>
              <h2>Avance físico</h2>
              <div style={{ display: 'grid', gap: 10 }}>
                <div>
                  <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '0.875rem' }}>
                    <span style={{ color: 'var(--text-muted)' }}>Planificado a hoy</span>
                    <span className="num">{pct(p.avance_planificado ?? 0)}</span>
                  </div>
                  <div className="bar"><span style={{ width: `${(p.avance_planificado ?? 0) * 100}%` }} /></div>
                </div>
                <div>
                  <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '0.875rem' }}>
                    <span style={{ color: 'var(--text-muted)' }}>Real</span>
                    <span className="num">{pct(p.avance_real ?? 0)}</span>
                  </div>
                  <div
                    className={`bar${
                      (p.avance_real ?? 0) < (p.avance_planificado ?? 0) ? ' over' : ''
                    }`}
                  >
                    <span style={{ width: `${(p.avance_real ?? 0) * 100}%` }} />
                  </div>
                </div>
              </div>
              <p style={{ margin: 0, fontSize: '0.8125rem', color: 'var(--text-muted)' }}>
                Ponderado por días hábiles planificados. Mide avance físico, no económico:
                una tarea larga y barata pesa más que una corta y cara.
                {p.fin_proyectado && p.fin_plan && p.fin_proyectado > p.fin_plan && (
                  <>
                    {' '}El fin proyectado es {date(p.fin_proyectado)}, contra{' '}
                    {date(p.fin_plan)} planificado.
                  </>
                )}
              </p>
            </section>
          )}

          {(alerts.data ?? []).length > 0 && (
            <div className="notice notice-warning">
              <strong>
                {alerts.data.length === 1 ? '1 actividad con problema' : `${alerts.data.length} actividades con problemas`}
                :
              </strong>{' '}
              {alerts.data.slice(0, 4).map((a) => `${a.name} (${ALERTAS[a.alerta] ?? a.alerta})`).join(' · ')}
              {alerts.data.length > 4 && ` y ${alerts.data.length - 4} más`}
            </div>
          )}

          {rows.length > 0 && <Gantt tasks={rows} />}

          <Table
            columns={[
              { key: 'cat', label: 'Categoría' },
              { key: 'name', label: 'Actividad' },
              { key: 'ps', label: 'Inicio plan' },
              { key: 'pf', label: 'Fin plan' },
              { key: 'pd', label: 'Días plan', num: true },
              { key: 'as', label: 'Inicio real' },
              { key: 'af', label: 'Fin real' },
              { key: 'ad', label: 'Días real', num: true },
              { key: 'delay', label: 'Atraso', num: true },
              { key: 'st', label: 'Estado' },
              { key: 'act', label: '' },
            ]}
            rows={rows}
            empty="Todavía no hay actividades cargadas."
            renderRow={(t) => (
              <tr key={t.task_id}>
                <td style={{ color: 'var(--text-muted)' }}>{t.category ?? '—'}</td>
                <td>{t.name}</td>
                <td>{date(t.planned_start)}</td>
                <td>{date(t.planned_finish)}</td>
                <td className="num">{t.planned_days ?? '—'}</td>
                <td>{date(t.actual_start)}</td>
                <td>{date(t.actual_finish)}</td>
                <td className="num">{t.actual_days ?? '—'}</td>
                <td className={`num ${t.delay_days > 0 ? 'var-neg' : ''}`}>
                  {t.delay_days == null ? '—' : `${t.delay_days > 0 ? '+' : ''}${t.delay_days} d`}
                </td>
                <td>
                  <Badge tone={STATUS[t.status]?.[1]}>{STATUS[t.status]?.[0] ?? t.status}</Badge>
                </td>
                <td className="nowrap">
                  {canManage && (
                    <button
                      className="icon-btn"
                      onClick={() => {
                        setForm({
                          category: t.category ?? '',
                          name: t.name ?? '',
                          planned_start: t.planned_start ?? '',
                          planned_days: t.planned_days == null ? '' : String(t.planned_days),
                          actual_start: t.actual_start ?? '',
                          actual_finish: t.actual_finish ?? '',
                          responsible: t.responsible ?? '',
                        })
                        setAbierto(t)
                      }}
                    >
                      Editar
                    </button>
                  )}
                  {canManage && !t.actual_start && (
                    <button className="icon-btn" onClick={() => marcar(t, { actual_start: hoy })}>
                      Iniciar
                    </button>
                  )}
                  {canManage && t.actual_start && !t.actual_finish && (
                    <button className="icon-btn" onClick={() => marcar(t, { actual_finish: hoy })}>
                      Terminar
                    </button>
                  )}
                  {canManage && (
                    <button
                      className="icon-btn"
                      onClick={async () => {
                        await deleteTask(t.task_id)
                        reload()
                      }}
                    >
                      Borrar
                    </button>
                  )}
                </td>
              </tr>
            )}
          />

          {(impact.data ?? []).length > 0 && (
            <section style={{ display: 'grid', gap: 12 }}>
              <h2>Impacto de los atrasos</h2>
              <Table
                columns={[
                  { key: 'a', label: 'Actividad atrasada' },
                  { key: 'd', label: 'Atraso', num: true },
                  { key: 'b', label: 'Afecta a' },
                  { key: 'i', label: 'Inicio previsto' },
                ]}
                rows={impact.data}
                renderRow={(i) => (
                  <tr key={`${i.tarea_atrasada}-${i.tarea_afectada}`}>
                    <td>{i.nombre_atrasada}</td>
                    <td className="num var-neg">+{i.delay_days} d</td>
                    <td>{i.nombre_afectada}</td>
                    <td>{date(i.inicio_previsto_afectada)}</td>
                  </tr>
                )}
              />
            </section>
          )}
        </>
      )}

      {plantilla && (
        <Drawer
          title="Cargar etapas estándar"
          submitLabel="Generar cronograma"
          onClose={() => setPlantilla(null)}
          onSubmit={aplicarPlantilla}
          submitting={saving}
        >
          {formError && <ErrorBox message={formError} />}

          <div className="notice">
            Toma las etapas de <strong>Catálogo › Etapas de obra</strong> y las convierte
            en el cronograma de esta obra, encadenando las fechas en días hábiles desde
            la fecha de arranque. Después son actividades de esta obra como cualquier
            otra: editarlas no toca la plantilla.
          </div>

          <Field
            label="Fecha de arranque de la obra"
            hint="Es el inicio de la primera etapa. Todo lo demás se calcula a partir de ahí."
          >
            <input
              type="date"
              required
              value={inicio}
              onChange={(e) => setInicio(e.target.value)}
            />
          </Field>

          {rows.length > 0 && (
            <div className="notice notice-warning">
              Esta obra ya tiene {rows.length}{' '}
              {rows.length === 1 ? 'actividad cargada' : 'actividades cargadas'}. Las
              etapas se agregan al final, no reemplazan lo que ya está.
            </div>
          )}
        </Drawer>
      )}

      {abierto && (
        <Drawer
          title={abierto === 'nuevo' ? 'Nueva actividad' : 'Editar actividad'}
          submitLabel={abierto === 'nuevo' ? 'Crear' : 'Guardar cambios'}
          onClose={() => setAbierto(null)}
          onSubmit={save}
          submitting={saving}
        >
          {formError && <ErrorBox message={formError} />}

          <Field label="Categoría" hint="Ej: Tareas preliminares, Estructura, Terminaciones">
            <input value={form.category} onChange={set('category')} />
          </Field>

          <Field label="Actividad">
            <input required value={form.name} onChange={set('name')} />
          </Field>

          <Field label="Inicio planificado">
            <input type="date" value={form.planned_start} onChange={set('planned_start')} />
          </Field>

          <Field
            label="Días hábiles planificados"
            hint="El fin se calcula solo, salteando fines de semana y feriados."
          >
            <input type="number" min="1" step="1" value={form.planned_days} onChange={set('planned_days')} />
          </Field>

          <Field label="Inicio real"><input type="date" value={form.actual_start} onChange={set('actual_start')} /></Field>
          <Field label="Fin real"><input type="date" value={form.actual_finish} onChange={set('actual_finish')} /></Field>
          <Field label="Responsable"><input value={form.responsible} onChange={set('responsible')} /></Field>
        </Drawer>
      )}
    </div>
  )
}
