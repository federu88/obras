import { useState } from 'react'
import { useAsync } from '../../lib/useAsync'
import {
  listTaskTemplates,
  createTaskTemplate,
  updateTaskTemplate,
  deleteTaskTemplate,
} from '../../lib/queries'
import { useAuth } from '../../context/AuthContext'
import { PageHead, Table, Loading, ErrorBox, Badge, Drawer, Field, Kpi } from '../../components/ui'

/**
 * Etapas de obra: los pasos estandarizados para construir una casa.
 *
 * Es una plantilla, no un cronograma. No tiene fechas: tiene el orden, cuánto
 * dura cada paso y si espera al anterior. Las fechas aparecen recién cuando una
 * obra la aplica con su propia fecha de arranque.
 *
 * Que sea una sola plantilla es a propósito: si cada obra inventa sus etapas,
 * los cronogramas dejan de ser comparables entre casas.
 */

const EMPTY = {
  category: '',
  name: '',
  planned_days: '',
  chained: 'true',
  notes: '',
}

export default function Etapas() {
  const { canManage } = useAuth()
  const [abierto, setAbierto] = useState(null)
  const [form, setForm] = useState(EMPTY)
  const [saving, setSaving] = useState(false)
  const [formError, setFormError] = useState(null)

  const plantilla = useAsync(listTaskTemplates)
  const set = (k) => (e) => setForm((f) => ({ ...f, [k]: e.target.value }))

  const rows = plantilla.data ?? []
  const activas = rows.filter((r) => r.is_active)
  const rubros = new Set(activas.map((r) => r.category))

  /* Duración total de la obra: las etapas en paralelo no suman días propios. */
  const diasCorridos = activas.reduce((t, r) => t + (r.chained ? r.planned_days : 0), 0)
  const diasSumados = activas.reduce((t, r) => t + r.planned_days, 0)

  function abrirNueva() {
    setForm(EMPTY)
    setFormError(null)
    setAbierto('nuevo')
  }

  function abrirEdicion(t) {
    setForm({
      category: t.category ?? '',
      name: t.name ?? '',
      planned_days: String(t.planned_days ?? ''),
      chained: t.chained ? 'true' : 'false',
      notes: t.notes ?? '',
    })
    setFormError(null)
    setAbierto(t)
  }

  async function save() {
    setSaving(true)
    setFormError(null)
    try {
      const payload = {
        category: form.category,
        name: form.name,
        planned_days: Number(form.planned_days),
        chained: form.chained === 'true',
        notes: form.notes || null,
      }
      if (abierto === 'nuevo') {
        /* Va al final: mover una etapa de lugar es reordenar, no crear. */
        const ultimo = rows.reduce((m, r) => Math.max(m, r.sort_order), 0)
        await createTaskTemplate({ ...payload, sort_order: ultimo + 1 })
      } else {
        await updateTaskTemplate(abierto.id, payload)
      }
      setAbierto(null)
      plantilla.reload()
    } catch (err) {
      setFormError(err.message)
    } finally {
      setSaving(false)
    }
  }

  async function eliminar() {
    setSaving(true)
    setFormError(null)
    try {
      await deleteTaskTemplate(abierto.id)
      setAbierto(null)
      plantilla.reload()
    } catch (err) {
      setFormError(err.message)
    } finally {
      setSaving(false)
    }
  }

  /** Sube o baja una etapa intercambiando su orden con la vecina. */
  async function mover(t, delta) {
    const i = rows.findIndex((r) => r.id === t.id)
    const vecina = rows[i + delta]
    if (!vecina) return
    await Promise.all([
      updateTaskTemplate(t.id, { sort_order: vecina.sort_order }),
      updateTaskTemplate(vecina.id, { sort_order: t.sort_order }),
    ])
    plantilla.reload()
  }

  async function alternarActiva(t) {
    await updateTaskTemplate(t.id, { is_active: !t.is_active })
    plantilla.reload()
  }

  return (
    <div>
      <PageHead
        title="Etapas de obra"
        subtitle="Los pasos estándar para construir una casa, en orden, con su duración en días hábiles. Cada obra los instancia con su fecha de arranque y se convierten en su cronograma."
        action={
          canManage && (
            <button className="btn btn-primary" onClick={abrirNueva}>
              + Etapa
            </button>
          )
        }
      />

      {plantilla.error && <ErrorBox message={plantilla.error} />}

      {plantilla.loading ? (
        <Loading />
      ) : (
        <>
          <div className="kpi-grid">
            <Kpi label="Etapas activas" value={activas.length} hint={`en ${rubros.size} rubros`} />
            <Kpi
              label="Duración de la obra"
              value={`${diasCorridos} días hábiles`}
              hint="sumando solo lo que va uno atrás del otro"
            />
            <Kpi
              label="Trabajo total"
              value={`${diasSumados} días hábiles`}
              hint="sumando todo, incluso lo que se solapa"
            />
          </div>

          <p style={{ color: 'var(--text-muted)', fontSize: '0.875rem', margin: '16px 0' }}>
            Una etapa <strong>encadenada</strong> arranca el día hábil siguiente al fin de
            la anterior. Una <strong>en paralelo</strong> arranca el mismo día que la
            anterior, porque no la espera: es lo que hace que la obra dure{' '}
            {diasCorridos} días y no {diasSumados}.
          </p>

          <Table
            columns={[
              { key: 'sort_order', label: '#', num: true },
              { key: 'category', label: 'Rubro' },
              { key: 'name', label: 'Etapa' },
              { key: 'planned_days', label: 'Días hábiles', num: true },
              { key: 'chained', label: 'Arranque' },
              { key: 'is_active', label: 'Estado' },
              { key: 'act', label: '', sort: false },
            ]}
            rows={rows}
            empty="Todavía no hay etapas cargadas."
            renderRow={(t) => {
              /* Posicion real en la plantilla: la tabla puede estar ordenada por
                 otra columna, y subir o bajar siempre se refiere al orden. */
              const i = rows.indexOf(t)
              return (
              <tr key={t.id} style={t.is_active ? undefined : { opacity: 0.5 }}>
                <td className="num" style={{ color: 'var(--text-muted)' }}>{t.sort_order}</td>
                <td style={{ color: 'var(--text-muted)' }}>{t.category}</td>
                <td style={{ fontWeight: 500 }}>{t.name}</td>
                <td className="num">{t.planned_days}</td>
                <td>
                  <Badge tone={t.chained ? null : 'warn'}>
                    {t.chained ? 'Tras la anterior' : 'En paralelo'}
                  </Badge>
                </td>
                <td>
                  <Badge tone={t.is_active ? 'ok' : 'off'}>
                    {t.is_active ? 'Activa' : 'Desactivada'}
                  </Badge>
                </td>
                <td className="nowrap">
                  {canManage && (
                    <>
                      <button className="icon-btn" onClick={() => mover(t, -1)} disabled={i === 0}>
                        ↑
                      </button>
                      <button
                        className="icon-btn"
                        onClick={() => mover(t, 1)}
                        disabled={i === rows.length - 1}
                      >
                        ↓
                      </button>
                      <button className="icon-btn" onClick={() => abrirEdicion(t)}>
                        Editar
                      </button>
                      <button className="icon-btn" onClick={() => alternarActiva(t)}>
                        {t.is_active ? 'Desactivar' : 'Activar'}
                      </button>
                    </>
                  )}
                </td>
              </tr>
              )
            }}
          />

          <p style={{ color: 'var(--text-muted)', fontSize: '0.8125rem', marginTop: 12 }}>
            Desactivar una etapa la saca de las obras nuevas sin tocar las que ya la
            tienen cargada. Cambiar la plantilla nunca modifica un cronograma ya
            generado: esa obra ya hizo su copia.
          </p>
        </>
      )}

      {abierto && (
        <Drawer
          title={abierto === 'nuevo' ? 'Nueva etapa' : 'Editar etapa'}
          submitLabel={abierto === 'nuevo' ? 'Crear' : 'Guardar cambios'}
          onClose={() => setAbierto(null)}
          onSubmit={save}
          submitting={saving}
          onDelete={abierto !== 'nuevo' ? eliminar : undefined}
          deleteLabel="Eliminar etapa"
        >
          {formError && <ErrorBox message={formError} />}

          <Field label="Rubro" hint="Ej: Etapa mampostería, Plomero, Electricista.">
            <input
              required
              list="rubros-obra"
              value={form.category}
              onChange={set('category')}
            />
            <datalist id="rubros-obra">
              {[...new Set(rows.map((r) => r.category))].map((c) => (
                <option key={c} value={c} />
              ))}
            </datalist>
          </Field>

          <Field label="Etapa">
            <input required value={form.name} onChange={set('name')} />
          </Field>

          <Field
            label="Días hábiles"
            hint="Cuánto lleva hacerla. Los fines de semana y feriados no cuentan."
          >
            <input
              type="number"
              min="1"
              step="1"
              required
              value={form.planned_days}
              onChange={set('planned_days')}
            />
          </Field>

          <Field
            label="Arranque"
            hint="Si corre en paralelo, empieza el mismo día que la etapa anterior."
          >
            <select value={form.chained} onChange={set('chained')}>
              <option value="true">Cuando termina la anterior</option>
              <option value="false">En paralelo con la anterior</option>
            </select>
          </Field>

          <Field label="Notas">
            <input value={form.notes} onChange={set('notes')} />
          </Field>
        </Drawer>
      )}
    </div>
  )
}
