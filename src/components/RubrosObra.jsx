import { useState } from 'react'
import { useAsync } from '../lib/useAsync'
import {
  listProjectRubros,
  createProjectRubro,
  updateProjectRubro,
  deleteProjectRubro,
} from '../lib/queries'
import { Drawer, ErrorBox } from './ui'

/**
 * Los rubros de una obra.
 *
 * Cada obra arranca con los rubros base y después los ajusta: renombrar,
 * reordenar, ocultar los que no aplican, agregar los propios. Cada cambio se
 * guarda en el momento.
 *
 * Borrar solo se puede si nadie lo usa. Un rubro con gastos o presupuesto se
 * oculta: deja de ofrecerse al cargar, pero lo ya cargado no queda huérfano.
 */
export default function RubrosObra({ projectId, onClose, onChange }) {
  const rubros = useAsync(() => listProjectRubros(projectId), [projectId])
  const [nombres, setNombres] = useState({})
  const [nuevo, setNuevo] = useState('')
  const [error, setError] = useState(null)
  const [ocupado, setOcupado] = useState(false)

  const lista = rubros.data ?? []

  async function hacer(fn) {
    setOcupado(true)
    setError(null)
    try {
      await fn()
      rubros.reload()
      onChange?.()
    } catch (err) {
      setError(
        /foreign key|violates/i.test(err.message)
          ? 'Ese rubro tiene gastos o presupuesto cargados, así que no se puede borrar. Ocultalo.'
          : /duplicate|unique/i.test(err.message)
            ? 'Ya hay un rubro con ese nombre en esta obra.'
            : err.message
      )
    } finally {
      setOcupado(false)
    }
  }

  /* Reordenar es intercambiar el orden con el vecino. */
  function mover(i, delta) {
    const a = lista[i]
    const b = lista[i + delta]
    if (!b) return
    hacer(async () => {
      await updateProjectRubro(a.id, { sort_order: b.sort_order })
      await updateProjectRubro(b.id, { sort_order: a.sort_order === b.sort_order ? a.sort_order + delta : a.sort_order })
    })
  }

  function renombrar(r) {
    const nombre = (nombres[r.id] ?? r.name).trim()
    if (!nombre || nombre === r.name) return
    hacer(() => updateProjectRubro(r.id, { name: nombre }))
  }

  function agregar() {
    const nombre = nuevo.trim()
    if (!nombre) return
    const orden = Math.max(0, ...lista.filter((r) => r.name !== 'Sin clasificar').map((r) => r.sort_order)) + 10
    hacer(async () => {
      await createProjectRubro({ project_id: projectId, name: nombre, sort_order: orden })
      setNuevo('')
    })
  }

  return (
    <Drawer title="Rubros de la obra" submitLabel="Listo" onClose={onClose} onSubmit={onClose} submitting={ocupado}>
      {error && <ErrorBox message={error} />}
      {rubros.error && <ErrorBox message={rubros.error} />}

      <div className="campos" style={{ display: 'grid', gap: 6 }}>
        {lista.map((r, i) => (
          <div key={r.id} style={{ display: 'flex', gap: 6, alignItems: 'center', opacity: r.is_active ? 1 : 0.55 }}>
            <input
              value={nombres[r.id] ?? r.name}
              onChange={(e) => setNombres((n) => ({ ...n, [r.id]: e.target.value }))}
              onBlur={() => renombrar(r)}
              onKeyDown={(e) => { if (e.key === 'Enter') { e.preventDefault(); e.currentTarget.blur() } }}
              aria-label={`Nombre del rubro ${r.name}`}
              style={{ flex: 1, minWidth: 0 }}
            />
            <button type="button" className="icon-btn" disabled={i === 0 || ocupado} onClick={() => mover(i, -1)} aria-label="Subir">↑</button>
            <button type="button" className="icon-btn" disabled={i === lista.length - 1 || ocupado} onClick={() => mover(i, 1)} aria-label="Bajar">↓</button>
            <button type="button" className="icon-btn" disabled={ocupado} onClick={() => hacer(() => updateProjectRubro(r.id, { is_active: !r.is_active }))}>
              {r.is_active ? 'Ocultar' : 'Mostrar'}
            </button>
            <button type="button" className="icon-btn" disabled={ocupado} onClick={() => hacer(() => deleteProjectRubro(r.id))}>
              Borrar
            </button>
          </div>
        ))}
      </div>

      <div className="campos" style={{ display: 'flex', gap: 8 }}>
        <input
          placeholder="Nuevo rubro"
          value={nuevo}
          onChange={(e) => setNuevo(e.target.value)}
          onKeyDown={(e) => { if (e.key === 'Enter') { e.preventDefault(); agregar() } }}
          style={{ flex: 1 }}
        />
        <button type="button" className="btn" disabled={ocupado || !nuevo.trim()} onClick={agregar}>
          Agregar
        </button>
      </div>
    </Drawer>
  )
}
