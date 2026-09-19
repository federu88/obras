import { useState } from 'react'
import { Drawer, Field, ErrorBox } from './ui'

/**
 * Formulario de proyecto, compartido entre alta y edición.
 *
 * Uno solo a propósito: con dos formularios, el día que se agrega un campo
 * queda editable en una pantalla y no en la otra, y nadie se entera hasta que
 * alguien no puede corregir un dato.
 */

/* El orden es el del flujo real de una obra, no alfabético. */
export const PROJECT_STATUS = {
  idea: 'Idea',
  evaluacion: 'Evaluación',
  aprobado: 'Aprobado',
  en_tramite_municipal: 'En trámite municipalidad',
  en_construccion: 'En construcción',
  terminado: 'Terminado',
  en_proceso_venta: 'En proceso de venta',
  vendido: 'Vendido',
  cerrado: 'Cerrado',
}

const NUMERICOS = [
  'lot_m2',
  'covered_m2',
  'semi_covered_m2',
  'budget_usd',
  'capital_required_usd',
  'target_sale_usd',
  'broker_fee_pct',
]

export const PROJECT_KINDS = {
  construccion: 'Construcción desde cero',
  remodelacion: 'Remodelación',
}

export const PROJECT_MODELS = {
  desarrollo: 'Desarrollo propio (se vende y se reparte)',
  encargo: 'Obra por encargo (la paga un cliente)',
}

const VACIO = {
  code: '',
  name: '',
  model: 'desarrollo',
  kind: 'construccion',
  location: '',
  house_type: '',
  lot_m2: '',
  covered_m2: '',
  semi_covered_m2: '',
  status: 'idea',
  planned_start: '',
  planned_finish: '',
  actual_start: '',
  actual_finish: '',
  budget_usd: '',
  capital_required_usd: '',
  target_sale_usd: '',
  broker_fee_pct: '2.5',
  notes: '',
}

/** Del registro de la base al estado del formulario. */
function desdeProyecto(p) {
  if (!p) return VACIO
  const f = { ...VACIO }
  for (const k of Object.keys(VACIO)) {
    const v = p[k]
    f[k] = v == null ? '' : String(v)
  }
  // El porcentaje se guarda como fracción y se edita como número entero.
  f.broker_fee_pct = p.broker_fee_pct == null ? '2.5' : String(Number(p.broker_fee_pct) * 100)
  f.status = p.status ?? 'idea'
  f.model = p.model ?? 'desarrollo'
  f.kind = p.kind ?? 'construccion'
  return f
}

/** Del formulario al payload. '' se convierte en null, nunca en 0. */
function aPayload(form) {
  const out = {}
  for (const [k, v] of Object.entries(form)) {
    if (v === '' || v == null) out[k] = null
    else if (k === 'broker_fee_pct') out[k] = Number(v) / 100
    else if (NUMERICOS.includes(k)) out[k] = Number(v)
    else out[k] = v
  }
  return out
}

export default function ProyectoForm({ project, onClose, onSave }) {
  const [form, setForm] = useState(() => desdeProyecto(project))
  const [saving, setSaving] = useState(false)
  const [error, setError] = useState(null)

  const set = (k) => (e) => setForm((f) => ({ ...f, [k]: e.target.value }))
  const editando = Boolean(project)

  async function submit() {
    setSaving(true)
    setError(null)
    try {
      await onSave(aPayload(form))
      onClose()
    } catch (err) {
      setError(err.message)
    } finally {
      setSaving(false)
    }
  }

  return (
    <Drawer
      title={editando ? 'Editar proyecto' : 'Nuevo proyecto'}
      onClose={onClose}
      onSubmit={submit}
      submitting={saving}
      submitLabel={editando ? 'Guardar cambios' : 'Crear'}
    >
      {error && <ErrorBox message={error} />}

      <Field label="Código" hint="Corto y único. Ej: SR583">
        <input required value={form.code} onChange={set('code')} />
      </Field>

      <Field label="Nombre">
        <input required value={form.name} onChange={set('name')} />
      </Field>

      <Field label="Ubicación">
        <input value={form.location} onChange={set('location')} />
      </Field>

      <Field label="Tipo de casa">
        <input value={form.house_type} onChange={set('house_type')} />
      </Field>

      <Field label="Metros del lote">
        <input type="number" step="0.01" min="0" value={form.lot_m2} onChange={set('lot_m2')} />
      </Field>

      <Field label="Metros cubiertos">
        <input type="number" step="0.01" min="0" value={form.covered_m2} onChange={set('covered_m2')} />
      </Field>

      <Field label="Metros semicubiertos">
        <input type="number" step="0.01" min="0" value={form.semi_covered_m2} onChange={set('semi_covered_m2')} />
      </Field>

      <Field
        label="Modelo"
        hint="Decide cómo entra la plata: capital de socios que se reparte, o un cliente que paga contra avance."
      >
        <select value={form.model} onChange={set('model')}>
          {Object.entries(PROJECT_MODELS).map(([k, label]) => (
            <option key={k} value={k}>{label}</option>
          ))}
        </select>
      </Field>

      <Field
        label="Tipo de obra"
        hint="Una remodelación no tiene pilotes ni encadenado: las etapas que le sirven son otras."
      >
        <select value={form.kind} onChange={set('kind')}>
          {Object.entries(PROJECT_KINDS).map(([k, label]) => (
            <option key={k} value={k}>{label}</option>
          ))}
        </select>
      </Field>

      <Field label="Estado">
        <select value={form.status} onChange={set('status')}>
          {Object.entries(PROJECT_STATUS).map(([k, label]) => (
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

      <Field label="Inicio real">
        <input type="date" value={form.actual_start} onChange={set('actual_start')} />
      </Field>

      <Field label="Fin real">
        <input type="date" value={form.actual_finish} onChange={set('actual_finish')} />
      </Field>

      <Field
        label="Presupuesto (USD)"
        hint="El budget de referencia del proyecto. El detalle por item se carga en la pestaña Presupuesto."
      >
        <input type="number" step="0.01" min="0" value={form.budget_usd} onChange={set('budget_usd')} />
      </Field>

      {/* Capital, venta y comisión son del desarrollo propio. En una obra por
          encargo no hay venta ni inmobiliaria: el precio está en el contrato. */}
      {form.model === 'desarrollo' && (
        <>
          <Field label="Capital requerido (USD)">
            <input
              type="number"
              step="0.01"
              min="0"
              value={form.capital_required_usd}
              onChange={set('capital_required_usd')}
            />
          </Field>

          <Field label="Venta estimada (USD)">
            <input
              type="number"
              step="0.01"
              min="0"
              value={form.target_sale_usd}
              onChange={set('target_sale_usd')}
            />
          </Field>

          <Field label="Comisión inmobiliaria (%)" hint="2,5 según el reparto real.">
            <input
              type="number"
              step="0.1"
              min="0"
              max="100"
              value={form.broker_fee_pct}
              onChange={set('broker_fee_pct')}
            />
          </Field>
        </>
      )}

      {form.model === 'encargo' && (
        <div className="notice">
          El precio, los honorarios y los adicionales se cargan en la pestaña{' '}
          <strong>Contrato</strong> de la obra, una vez creada.
        </div>
      )}

      <Field label="Notas">
        <input value={form.notes} onChange={set('notes')} />
      </Field>
    </Drawer>
  )
}
