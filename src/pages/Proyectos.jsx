import { useState } from 'react'
import { useAsync } from '../lib/useAsync'
import { listProjects, createProject, listProjectCapital } from '../lib/queries'
import { usd, date } from '../lib/format'
import { useAuth } from '../context/AuthContext'
import { PageHead, Table, Loading, ErrorBox, Badge, Drawer, Field } from '../components/ui'

const STATUS = {
  idea: ['Idea', null],
  evaluacion: ['Evaluación', null],
  aprobado: ['Aprobado', 'warn'],
  en_construccion: ['En construcción', 'warn'],
  terminado: ['Terminado', 'ok'],
  vendido: ['Vendido', 'ok'],
  cerrado: ['Cerrado', null],
}

const ACTIVOS = ['aprobado', 'en_construccion']
const TERMINADOS = ['terminado', 'vendido', 'cerrado']

const EMPTY = {
  code: '',
  name: '',
  location: '',
  surface_m2: '',
  status: 'idea',
  planned_start: '',
  planned_finish: '',
  budget_usd: '',
  target_sale_usd: '',
}

/** Convierte '' a null y numérico a Number. Evita mandar strings vacíos a Postgres. */
function clean(form) {
  const out = {}
  for (const [k, v] of Object.entries(form)) {
    if (v === '' || v == null) {
      out[k] = null
    } else if (['surface_m2', 'budget_usd', 'target_sale_usd'].includes(k)) {
      out[k] = Number(v)
    } else {
      out[k] = v
    }
  }
  return out
}

export default function Proyectos({ filter }) {
  const { canManage } = useAuth()
  const [open, setOpen] = useState(false)
  const [form, setForm] = useState(EMPTY)
  const [saving, setSaving] = useState(false)
  const [formError, setFormError] = useState(null)

  const projects = useAsync(listProjects)
  const capital = useAsync(listProjectCapital)

  const set = (k) => (e) => setForm((f) => ({ ...f, [k]: e.target.value }))

  async function save() {
    setSaving(true)
    setFormError(null)
    try {
      await createProject(clean(form))
      setForm(EMPTY)
      setOpen(false)
      projects.reload()
      capital.reload()
    } catch (err) {
      setFormError(err.message)
    } finally {
      setSaving(false)
    }
  }

  const title =
    filter === 'activos' ? 'Proyectos activos'
    : filter === 'terminados' ? 'Proyectos terminados'
    : 'Proyectos'

  let rows = projects.data ?? []
  if (filter === 'activos') rows = rows.filter((p) => ACTIVOS.includes(p.status))
  if (filter === 'terminados') rows = rows.filter((p) => TERMINADOS.includes(p.status))

  const capitalByProject = Object.fromEntries(
    (capital.data ?? []).map((c) => [c.project_id, c])
  )

  const columns = [
    { key: 'code', label: 'Código' },
    { key: 'name', label: 'Proyecto' },
    { key: 'status', label: 'Estado' },
    { key: 'budget', label: 'Presupuesto', num: true },
    { key: 'capital', label: 'Capital aportado', num: true },
    { key: 'sale', label: 'Venta estimada', num: true },
    { key: 'finish', label: 'Fin previsto' },
  ]

  return (
    <div>
      <PageHead
        title={title}
        subtitle="Cada casa es un proyecto. Importes en USD."
        action={
          canManage && (
            <button className="btn btn-primary" onClick={() => setOpen(true)}>
              + Nuevo proyecto
            </button>
          )
        }
      />

      {projects.error && <ErrorBox message={projects.error} />}

      {projects.loading ? (
        <Loading />
      ) : (
        <Table
          columns={columns}
          rows={rows}
          empty={
            filter
              ? 'Ningún proyecto en este estado.'
              : 'Todavía no hay proyectos. Creá el primero con “Nuevo proyecto”.'
          }
          renderRow={(p) => (
            <tr key={p.id}>
              <td style={{ fontWeight: 500 }}>{p.code}</td>
              <td>
                {p.name}
                {p.is_demo && <> <span className="tag-demo">demo</span></>}
              </td>
              <td>
                <Badge tone={STATUS[p.status]?.[1]}>
                  {STATUS[p.status]?.[0] ?? p.status}
                </Badge>
              </td>
              <td className="num">{usd(p.budget_usd)}</td>
              <td className="num">
                {usd(capitalByProject[p.id]?.capital_aportado_usd)}
              </td>
              <td className="num">{usd(p.target_sale_usd)}</td>
              <td>{date(p.planned_finish)}</td>
            </tr>
          )}
        />
      )}

      {open && (
        <Drawer
          title="Nuevo proyecto"
          onClose={() => setOpen(false)}
          onSubmit={save}
          submitting={saving}
        >
          {formError && <ErrorBox message={formError} />}

          <Field label="Código" hint="Corto y único. Ej: SR583">
            <input required value={form.code} onChange={set('code')} />
          </Field>

          <Field label="Nombre">
            <input required value={form.name} onChange={set('name')} />
          </Field>

          <Field label="Ubicación">
            <input value={form.location} onChange={set('location')} />
          </Field>

          <Field label="Superficie (m²)">
            <input type="number" step="0.01" min="0" value={form.surface_m2} onChange={set('surface_m2')} />
          </Field>

          <Field label="Estado">
            <select value={form.status} onChange={set('status')}>
              {Object.entries(STATUS).map(([k, [label]]) => (
                <option key={k} value={k}>{label}</option>
              ))}
            </select>
          </Field>

          <Field label="Inicio previsto">
            <input type="date" value={form.planned_start} onChange={set('planned_start')} />
          </Field>

          <Field label="Fin previsto">
            <input type="date" value={form.planned_finish} onChange={set('planned_finish')} />
          </Field>

          <Field label="Presupuesto (USD)" hint="El budget original. Queda congelado como referencia.">
            <input type="number" step="0.01" min="0" value={form.budget_usd} onChange={set('budget_usd')} />
          </Field>

          <Field label="Venta estimada (USD)">
            <input type="number" step="0.01" min="0" value={form.target_sale_usd} onChange={set('target_sale_usd')} />
          </Field>
        </Drawer>
      )}
    </div>
  )
}
